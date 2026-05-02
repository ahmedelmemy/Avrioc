# Smart Product Explorer - Avrioc

A SwiftUI iOS application that fetches product data from the DummyJSON API and allows users to browse, search, filter, and sort products.

## Architecture Overview

The project follows **MVVM + Clean Architecture** with clear separation of concerns across three layers:

```
Avrioc/
├── Core/                              # Reusable infrastructure
│   ├── Network/
│   │   ├── HTTPClient.swift           # Generic Combine-based HTTP client (protocol + impl)
│   │   ├── APIEndpoint.swift          # Type-safe endpoint builder using URLComponents
│   │   ├── NetworkError.swift         # Typed error handling
│   │   └── NetworkMonitor.swift       # NWPathMonitor wrapper for connectivity detection
│   ├── Cache/
│   │   ├── ProductCacheService.swift  # Thread-safe disk-based JSON cache (serial queue)
│   │   └── ImageCacheService.swift    # Two-layer image cache (NSCache + async disk I/O)
│   └── DI/
│       └── DependencyContainer.swift  # Dependency injection container
│
├── Features/Products/
│   ├── Data/                          # Data layer (how we get data)
│   │   ├── DTOs/ProductDTO.swift      # API response models (Codable)
│   │   ├── Mappers/ProductMapper.swift # DTO -> Domain transformation
│   │   └── Repository/ProductRepository.swift  # Network + cache orchestration
│   │
│   ├── Domain/                        # Domain layer (what the app works with)
│   │   └── ProductRepositoryProtocol.swift     # PaginatedProducts + protocol
│   │
│   ├── Models/
│   │   ├── Product.swift              # Domain models (not Codable)
│   │   └── SortOption.swift           # Sort options with display names
│   │
│   ├── ViewModels/
│   │   ├── ProductsViewModel.swift  # @MainActor, Combine pipeline + state
│   │   └── ViewState.swift          # Reusable UI state machine enum
│   └── Views/
│       ├── ProductList/                 # Product listing screens
│       │   ├── ProductListView.swift    # Grid/list with search, pagination
│       │   ├── ProductCardView.swift    # Grid card component
│       │   └── ProductRowView.swift     # List row component
│       └── ProductDetail/               # Product detail screens
│           ├── ProductDetailView.swift  # Detail page composing sub-views
│           ├── ImageCarouselView.swift  # Swipeable image carousel with cache fallback
│           ├── ProductInfoView.swift    # Category badge, rating, title, brand
│           ├── PriceSectionView.swift   # Price, discount, stock status
│           ├── DescriptionSectionView.swift # Product description
│           ├── DetailsSectionView.swift # Specs, dimensions, tags
│           ├── ReviewsSectionView.swift # Star ratings and review comments
│           └── DetailRow.swift          # Reusable key-value detail row
│
├── Shared/
│   ├── Constants/                       # Centralized strings, icons & colors
│   │   ├── AppColors.swift              # Single source of truth for all app colors
│   │   ├── Strings.swift                # Base enum + shared formatting helpers
│   │   ├── Strings+ProductList.swift    # Product list, states, offline strings
│   │   ├── Strings+ProductDetail.swift  # Detail labels (SKU, weight, etc.)
│   │   ├── Strings+FilterSort.swift     # Filter & sort sheet strings
│   │   ├── Strings+Errors.swift         # Network error messages
│   │   └── Strings+Icons.swift          # SF Symbol names
│   └── Views/
│       ├── Components/                  # Reusable UI components
│       │   ├── FilterSortView.swift     # Filter & sort sheet
│       │   ├── CachedAsyncImage.swift   # AsyncImage replacement with disk cache
│       │   ├── FlowLayout.swift         # Custom layout for tags
│       │   ├── PriceLabel.swift         # Compact price with strikethrough original
│       │   ├── RatingLabel.swift        # Star icon + numeric rating
│       │   └── StarRatingView.swift     # 1-to-5 filled/empty star row
│       ├── Modifiers/                   # Reusable view modifiers
│       │   ├── CapsuleBadge.swift       # Capsule badge styling (category, stock, tags)
│       │   └── SectionCard.swift        # Padded rounded card for detail sections
│       └── StateViews/                  # App state screens
│           ├── LoadingView.swift        # Loading state with spinner
│           ├── EmptyProductsView.swift  # Empty state placeholder
│           ├── ErrorView.swift          # Error state with retry button
│           └── OfflineBannerView.swift  # Offline/cached data banner with retry
│
├── AvriocApp.swift                    # App entry with DI setup
└── ContentView.swift                  # Root view with @StateObject ownership
```

## Key Architectural Decisions

### 1. DTO / Domain Model Separation
- **ProductDTO**: Raw `Codable` structs matching the API response exactly (also used for disk caching)
- **Product**: Domain model used throughout the app (not `Codable`)
- **ProductMapper**: Stateless enum that transforms DTOs into domain models, pre-computing values like `discountedPrice`
- **Why**: Decouples the app from API changes. If the API response format changes, only the DTO and mapper need updating - views and ViewModel remain untouched.

### 2. Generic HTTP Client
- `HTTPClientProtocol` with a single generic `request<T>(_ endpoint:)` method
- `APIEndpoint` enum builds URLs with `URLComponents` (proper encoding, no string concatenation)
- **Why**: Reusable across features. Adding a new API endpoint means adding one case to the enum, not writing a new method.

### 3. Repository Pattern
- `ProductRepositoryProtocol` defines what the ViewModel needs (domain types)
- `ProductRepository` implementation uses HTTPClient + Mapper + Cache internally
- On success: caches the first page to disk, returns `isFromCache: false`
- On failure: falls back to cached data if available, returns `isFromCache: true`
- **Why**: ViewModel has no knowledge of DTOs, networking, caching, or mapping. Testing the ViewModel only requires a mock repository.

### 4. Combine Pipeline with Debounce
```
searchText ──> debounce(300ms) ──┐
selectedCategory ────────────────┤
sortOption ──────────────────────┼──> CombineLatest ──> applyFilters() ──> filteredProducts
allProducts ─────────────────────┘
```
- Search text is debounced (300ms) to avoid filtering on every keystroke
- Category and sort changes apply immediately (no debounce)
- Initial search value bypasses debounce via `Publishers.Merge` with `.first()`
- The debounce interval is injectable for testing (`searchDebounceInterval: 0`)
- **Why**: True reactive pipeline. Any input change automatically triggers re-filtering without manual calls.

### 5. Static Filter Logic
- `ProductsViewModel.applyFilters(products:searchText:category:sortOption:)` is a **static pure function**
- **Why**: Can be tested with simple input/output assertions without any ViewModel setup, Combine subscriptions, or async waiting.

### 6. Dependency Injection
- `DependencyContainer` wires all dependencies at app launch
- Injected through initializers (constructor injection), not singletons
- `ContentView` owns the ViewModel via `@StateObject` to ensure proper lifecycle
- **Why**: Every component declares its dependencies explicitly, making the dependency graph visible and testable.

### 7. Local Caching & Offline Support
- `ProductCacheService` accumulates ALL loaded pages to disk — not just page 1. If the user scrolled through 60 products online, all 60 are available offline. A fresh fetch (skip == 0) replaces the cache; subsequent pages merge with deduplication by ID. Writes are dispatched asynchronously on a serial `DispatchQueue` (non-blocking for callers), while reads use `sync` to guarantee the latest data.
- `ImageCacheService` caches product images in two layers: instant NSCache memory hits and async disk reads on a background queue (no main-thread blocking during scroll). Original download bytes are stored to preserve PNG transparency.
- `CachedAsyncImage` is a drop-in `AsyncImage` replacement that checks cache before downloading, with proper Task cancellation handling
- On network failure during the initial fetch, the repository falls back to cached data and sets `isFromCache: true`. Pagination failures propagate silently — no cache fallback, preventing duplicate products in the list.
- The ViewModel reads `isFromCache` directly from the data layer (no guessing)
- An offline banner with retry button appears when serving cached data
- Smart retry: tapping retry while showing cached data keeps the current data visible during the request. If the retry fails, the cached data stays on screen (no error screen replacing usable content). If it succeeds, fresh data replaces the cache seamlessly.
- `NetworkMonitor` (NWPathMonitor) detects when connectivity returns and automatically triggers a fresh fetch — no manual retry needed
- **Why**: Users see every product and image they've previously browsed — even offline. Auto-reload on reconnect means the app self-heals without user intervention. Cache is stored in `Caches/` so the OS can reclaim it under storage pressure.

### 8. Pagination (Infinite Scrolling)
- Products load in pages of 20 using the API's `limit`/`skip` parameters
- `loadMoreProducts()` triggers when the user scrolls within 3 items of the bottom (threshold-based, works with active filters)
- `PaginatedProducts` wrapper carries `total` count so the ViewModel knows when all pages are loaded
- Dedicated `paginationCancellable` prevents double-firing and is cancelled on fresh fetch
- A loading indicator appears at the bottom while fetching the next page
- **Why**: Reduces initial load time and bandwidth. The API natively supports skip/limit, so pagination adds minimal complexity.

### 9. Request Lifecycle & Auto-Reload
- `fetchProducts()` cancels any in-flight fetch and pagination requests before starting
- `refreshProducts()` async wrapper uses `CheckedContinuation` to bridge Combine with `.refreshable`
- Separate `fetchCancellable` and `paginationCancellable` prevent race conditions
- `NetworkMonitor` observes NWPathMonitor and auto-triggers `fetchProducts()` when the device goes from offline → online while showing cached data or an error state
- Injectable `networkMonitor: nil` in tests to disable auto-reload and keep tests isolated
- **Why**: Rapid retry taps or pull-to-refresh won't cause overlapping requests or state corruption. The pull-to-refresh spinner stays visible until the network response actually arrives. Auto-reload ensures the freshest data as soon as connectivity returns.

### 10. Centralized Strings & Colors
- All user-facing strings and SF Symbol names live in `Shared/Constants/Strings*.swift`
- Split by feature via extensions: `Strings+ProductList`, `Strings+ProductDetail`, `Strings+FilterSort`, `Strings+Errors`, `Strings+Icons`
- Formatting helpers (`price()`, `rating()`, `dimensions()`) keep format logic out of views
- All app colors are defined in `AppColors.swift` — accent, rating, price, discount, stock status, backgrounds, shadows, and destructive colors
- **Why**: Single source of truth for copy and theming. Changing a color or preparing for dark mode only requires editing `AppColors.swift`. Makes future localization (NSLocalizedString) a one-file-at-a-time migration instead of a codebase-wide hunt.

## Data Flow

```
API Response (JSON)
    ↓ URLSession.dataTaskPublisher
ProductResponseDTO (Codable)
    ├──> Cache (disk write, all pages accumulated)
    ↓ ProductMapper.mapToDomain
PaginatedProducts { products, total, isFromCache }
    ↓ Repository → ViewModel
@Published allProducts
    ↓ Combine pipeline (filter + sort)
@Published filteredProducts
    ↓ SwiftUI binding
View renders

Network Failure:
    Cache (disk read, all previously loaded pages)
    → PaginatedProducts { isFromCache: true }
    → ViewModel shows offline banner with all cached products

Connectivity Restored (NetworkMonitor):
    NWPathMonitor detects online → ViewModel.fetchProducts()
    → Fresh data replaces cached data, offline banner dismissed
```

## Testing Strategy

### Test Structure (99 tests)
- **ProductsViewModelTests** (22): Integration tests with `MockProductRepository` — fetch (success, error, empty), pagination (loadMore append, correct skip/limit args, double-fire prevention, no-more-pages guard, categories update on new pages), offline flag (set on cache, cleared on retry), smart retry (keeps cached data on failure, replaces with fresh on success), async refresh, request cancellation, categories extraction, clear filters, initial idle state
- **ProductFilterTests** (17): Pure function tests for `applyFilters()` — search (title, brand, description, case-insensitive), category filtering, all sort options, combined filters, edge cases
- **ProductMapperTests** (10): DTO-to-domain mapping, discount calculation, zero discount, dimensions, reviews, batch mapping, category extraction, nil brand
- **ProductModelTests** (9): Identity-based equality and hashing, `isInStock` status checking (in stock, low stock, out of stock), Set deduplication by ID, `Review.id` composite key
- **NetworkErrorTests** (8): Error descriptions for all 5 cases, Equatable conformance (same cases, different cases, different HTTP status codes)
- **StringsTests** (8): Formatting helpers — price, rating, discount, weight, stock, dimensions, reviews count, brand
- **ProductRepositoryTests** (7): Network-to-cache integration with `MockHTTPClient` + `MockProductCacheService` — success path maps DTOs and caches, subsequent page marks not-first-page, first-page failure falls back to cache, non-first-page failure propagates error, no-cache failure propagates error, discounted price calculated during mapping, cache fallback maps DTOs to domain
- **ProductCacheServiceTests** (7): Save/load round-trip, load returns nil when empty, clear removes cache, first page replaces existing cache, subsequent pages accumulate, duplicate ID deduplication, concurrent saves thread-safety
- **APIEndpointTests** (4): URL construction (scheme, host, path), query parameter encoding (limit, skip), `urlRequest` property
- **ViewStateTests** (4): Equatable conformance for all cases, error message comparison, cross-case inequality
- **SortOptionTests** (3): Display name mapping for all 5 options, `id` matches `rawValue`, `CaseIterable` count

### Test Structure
```
AvriocTests/
├── ProductsViewModelTests.swift      # ViewModel + filter logic (22 + 17 tests)
├── ProductRepositoryTests.swift      # Network-to-cache integration (7 tests)
├── ProductMapperTests.swift          # DTO-to-domain mapping (10 tests)
├── ProductCacheServiceTests.swift    # Disk cache operations (7 tests)
├── ProductModelTests.swift           # Domain model equality, hashing, isInStock (9 tests)
├── NetworkErrorTests.swift           # Error descriptions + Equatable (8 tests)
├── StringsTests.swift                # Formatting helpers (8 tests)
├── APIEndpointTests.swift            # URL construction + query params (4 tests)
├── ViewStateTests.swift              # State enum equality (4 tests)
├── SortOptionTests.swift             # Display names + identifiers (3 tests)
└── Mocks/
    ├── MockProductRepository.swift   # Configurable repository with delay support
    ├── MockHTTPClient.swift          # Returns configurable Result<Any, NetworkError>
    ├── MockProductCacheService.swift # In-memory cache mock with call tracking
    └── MockData.swift                # Factory methods with sensible defaults
```

### Mocks
- `MockProductRepository` — configurable products, total, cache flag, error, delay; tracks call args
- `MockHTTPClient` — returns configurable `Result<Any, NetworkError>`
- `MockProductCacheService` — in-memory cache mock; tracks save calls and first-page flag
- `MockData` — factory methods with defaults for `Product`, `ProductDTO`, and sample fixtures

### Key Testing Decisions
- **DRY helpers**: `awaitState()`, `awaitPublished()`, `loadInitialProducts()` eliminate boilerplate Combine subscription patterns
- **No timing hacks**: Inverted expectations prove something does NOT happen, replacing fragile `DispatchQueue.main.asyncAfter` delays
- **Factory methods**: `MockData.makeProduct()` and `makeProductDTO()` with defaults — tests only specify fields they're testing
- **Unique cache files**: Each cache test uses a UUID-based filename to prevent cross-test interference
- Filter/sort logic is tested as pure functions (fast, deterministic)
- ViewModel uses injectable `searchDebounceInterval: 0` and `networkMonitor: nil` for isolation
- `MockProductRepository` supports `mockDelay` for realistic async behavior in double-fire tests
- Smart retry test uses inverted expectation to verify no `.error` state transition occurs

## Core Features

- Product grid/list with thumbnail, price, rating, availability badge
- Product detail with image carousel, discount pricing, reviews, specs
- Debounced search across title, description, category, and brand
- Sort by price (asc/desc) and rating (asc/desc)
- Filter by category with dynamic category extraction
- Grid/list layout toggle
- Loading, empty, and error states with retry
- Pull-to-refresh (async — spinner stays until response arrives)
- Local disk caching with offline fallback and retry banner
- Two-layer image caching (memory + disk) — images display offline
- Auto-reload when connectivity returns (NWPathMonitor)
- Smart retry: keeps cached data visible during retry, doesn't replace with error on failure
- Infinite scrolling with threshold-based page loading (20 products per page)
- Centralized string constants for localization readiness
- Centralized color definitions in `AppColors` for easy theming

## Potential Improvements

- **Coordinator Pattern**: Extract navigation logic for deeper navigation flows
- **Accessibility**: Enhanced VoiceOver labels and dynamic type support
- **SwiftData Persistence**: Migrate from JSON file cache to SwiftData for richer queries
- **Cache Expiry**: Add TTL-based cache invalidation
- **Localization**: Convert `Strings` constants to `NSLocalizedString` with `.strings` files

## Requirements

- Xcode 26.2+
- iOS 26.2+
- Swift 5.0+ with Swift 6 concurrency

## API

Uses [DummyJSON Products API](https://dummyjson.com/products)
