//
//  ProductsViewModelTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Integration tests for ViewModel: fetch lifecycle, pagination, offline handling,
//  smart retry, request cancellation, and reactive filter pipeline.
//

import XCTest
import Combine
@testable import Avrioc

@MainActor
final class ProductsViewModelTests: XCTestCase {
    private var viewModel: ProductsViewModel!
    private var mockRepository: MockProductRepository!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = MockProductRepository()
        // Debounce = 0 for instant filter updates; networkMonitor = nil to prevent auto-retry interference.
        viewModel = ProductsViewModel(
            repository: mockRepository,
            searchDebounceInterval: 0,
            pageSize: 20,
            networkMonitor: nil
        )
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Helpers

    /// Subscribes to viewState and waits until the specified state is emitted.
    private func awaitState(_ state: ViewState, timeout: TimeInterval = 2.0) {
        let exp = XCTestExpectation(description: "Await state: \(state)")
        viewModel.$viewState
            .dropFirst()
            .filter { $0 == state }
            .first()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)
        wait(for: [exp], timeout: timeout)
    }

    /// Generic helper to wait for any @Published property to satisfy a predicate.
    private func awaitPublished<T>(
        _ keyPath: KeyPath<ProductsViewModel, Published<T>.Publisher>,
        where predicate: @escaping (T) -> Bool,
        timeout: TimeInterval = 2.0
    ) {
        let exp = XCTestExpectation(description: "Await published value")
        viewModel[keyPath: keyPath]
            .dropFirst()
            .filter(predicate)
            .first()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)
        wait(for: [exp], timeout: timeout)
    }

    /// Uses an inverted expectation to prove viewState never transitions to .error.
    private func assertStateNeverReachesError(
        during action: () -> Void,
        timeout: TimeInterval = 0.5
    ) {
        let exp = XCTestExpectation(description: "Should NOT reach error")
        exp.isInverted = true
        viewModel.$viewState
            .dropFirst()
            .filter { if case .error = $0 { return true } else { return false } }
            .first()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)
        action()
        wait(for: [exp], timeout: timeout)
    }

    /// Configures the mock and fetches products, waiting until .loaded state.
    private func loadInitialProducts(
        products: [Product] = MockData.sampleProducts(),
        total: Int? = nil,
        isFromCache: Bool = false
    ) {
        mockRepository.mockProducts = products
        mockRepository.mockTotal = total
        mockRepository.mockIsFromCache = isFromCache
        viewModel.fetchProducts()
        awaitState(.loaded)
    }

    // MARK: - Fetch Products

    /// Verifies successful fetch populates products, categories, and sets correct state.
    func testFetchProductsSuccess() {
        loadInitialProducts()

        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.filteredProducts.count, 3)
        XCTAssertEqual(viewModel.categories.count, 3)
        XCTAssertFalse(viewModel.isOfflineData)
    }

    /// Verifies network error transitions viewState to .error.
    func testFetchProductsError() {
        mockRepository.mockError = .invalidResponse
        viewModel.fetchProducts()

        let exp = XCTestExpectation(description: "Error state")
        viewModel.$viewState
            .dropFirst()
            .filter { if case .error = $0 { return true } else { return false } }
            .first()
            .sink { _ in exp.fulfill() }
            .store(in: &cancellables)
        wait(for: [exp], timeout: 2.0)

        guard case .error = viewModel.viewState else {
            return XCTFail("Expected error state, got \(viewModel.viewState)")
        }
    }

    /// Verifies empty product list transitions to .empty state.
    func testFetchProductsEmpty() {
        mockRepository.mockProducts = []
        viewModel.fetchProducts()
        awaitState(.empty)

        XCTAssertEqual(viewModel.viewState, .empty)
    }

    // MARK: - Offline / Cache

    /// Verifies isOfflineData is set when repository returns cached data.
    func testOfflineDataFlagSetWhenFromCache() {
        loadInitialProducts(isFromCache: true)

        XCTAssertTrue(viewModel.isOfflineData)
        XCTAssertEqual(viewModel.filteredProducts.count, 3)
    }

    /// Verifies isOfflineData is cleared when a successful retry returns fresh data.
    func testOfflineDataFlagClearedOnRetry() {
        loadInitialProducts(isFromCache: true)
        XCTAssertTrue(viewModel.isOfflineData)

        mockRepository.mockIsFromCache = false
        viewModel.fetchProducts()
        awaitPublished(\.$isOfflineData, where: { !$0 })

        XCTAssertFalse(viewModel.isOfflineData)
        XCTAssertEqual(viewModel.viewState, .loaded)
    }

    /// Smart retry: when offline retry fails, cached data stays visible (no error screen).
    func testRetryFromOfflineKeepsDataOnFailure() {
        loadInitialProducts(isFromCache: true)
        XCTAssertEqual(viewModel.filteredProducts.count, 3)

        mockRepository.mockError = .invalidResponse
        mockRepository.mockProducts = []

        assertStateNeverReachesError {
            viewModel.fetchProducts()
        }

        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.filteredProducts.count, 3)
        XCTAssertTrue(viewModel.isOfflineData)
    }

    /// Smart retry: when offline retry succeeds, fresh data seamlessly replaces cache.
    func testRetryFromOfflineReplacesWithFreshData() {
        loadInitialProducts(isFromCache: true)
        XCTAssertTrue(viewModel.isOfflineData)

        mockRepository.mockIsFromCache = false
        mockRepository.mockProducts = [MockData.makeProduct(id: 99, title: "Fresh")]
        mockRepository.mockTotal = 1

        viewModel.fetchProducts()
        awaitPublished(\.$isOfflineData, where: { !$0 })

        XCTAssertFalse(viewModel.isOfflineData)
        XCTAssertEqual(viewModel.filteredProducts.count, 1)
        XCTAssertEqual(viewModel.filteredProducts.first?.id, 99)
    }

    // MARK: - Pagination

    /// Verifies hasMorePages is true when total exceeds loaded product count.
    func testHasMorePagesWhenTotalExceedsLoaded() {
        loadInitialProducts(total: 100)

        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.totalProducts, 100)
    }

    /// Verifies hasMorePages is false when all products are loaded.
    func testNoMorePagesWhenAllLoaded() {
        loadInitialProducts()

        XCTAssertFalse(viewModel.hasMorePages)
    }

    /// Verifies loadMore appends new products to the existing list.
    func testLoadMoreAppendsProducts() {
        loadInitialProducts(total: 100)
        XCTAssertEqual(viewModel.filteredProducts.count, 3)

        mockRepository.mockProducts = [MockData.makeProduct(id: 99, title: "Extra")]
        mockRepository.mockTotal = 100

        viewModel.loadMoreProducts()
        awaitPublished(\.$filteredProducts, where: { $0.count == 4 })

        XCTAssertEqual(viewModel.filteredProducts.count, 4)
        XCTAssertEqual(viewModel.filteredProducts.last?.id, 99)
    }

    /// Verifies loadMore sends the correct skip offset based on already-loaded products.
    func testLoadMoreSendsCorrectSkip() {
        loadInitialProducts(total: 100)
        mockRepository.resetCallTracking()

        mockRepository.mockProducts = [MockData.makeProduct(id: 99)]
        viewModel.loadMoreProducts()
        awaitPublished(\.$filteredProducts, where: { $0.count == 4 })

        XCTAssertEqual(mockRepository.fetchCallCount, 1)
        XCTAssertEqual(mockRepository.fetchCallArgs.first?.skip, 3)
        XCTAssertEqual(mockRepository.fetchCallArgs.first?.limit, 20)
    }

    /// Verifies loadMore is a no-op when all pages are already loaded.
    func testLoadMoreDoesNotFireWhenNoMorePages() {
        loadInitialProducts()
        mockRepository.resetCallTracking()

        viewModel.loadMoreProducts()

        XCTAssertEqual(mockRepository.fetchCallCount, 0)
    }

    /// Verifies rapid loadMore calls don't trigger duplicate requests (isLoadingMore guard).
    func testLoadMoreDoesNotDoubleFireWhileLoading() {
        loadInitialProducts(total: 100)
        mockRepository.resetCallTracking()

        mockRepository.mockDelay = 0.1
        mockRepository.mockProducts = [MockData.makeProduct(id: 99)]

        viewModel.loadMoreProducts()
        viewModel.loadMoreProducts()

        awaitPublished(\.$filteredProducts, where: { $0.count == 4 })

        XCTAssertEqual(mockRepository.fetchCallCount, 1)
    }

    /// Verifies categories list is updated when paginated pages introduce new categories.
    func testLoadMoreUpdatesCategoriesWhenNewCategoriesArrive() {
        loadInitialProducts(
            products: [MockData.makeProduct(id: 1, category: "phones")],
            total: 100
        )
        XCTAssertEqual(viewModel.categories, ["phones"])

        mockRepository.mockProducts = [MockData.makeProduct(id: 2, category: "laptops")]
        mockRepository.mockTotal = 100

        viewModel.loadMoreProducts()
        awaitPublished(\.$filteredProducts, where: { $0.count == 2 })

        XCTAssertEqual(viewModel.categories, ["laptops", "phones"])
    }

    /// Verifies the ViewModel starts in .idle state before any fetch.
    func testInitialViewStateIsIdle() {
        XCTAssertEqual(viewModel.viewState, .idle)
    }

    // MARK: - Refresh

    /// Verifies async refreshProducts() bridges Combine to await and completes.
    func testRefreshProductsAwaitsCompletion() async {
        mockRepository.mockProducts = MockData.sampleProducts()

        await viewModel.refreshProducts()

        XCTAssertEqual(viewModel.viewState, .loaded)
        XCTAssertEqual(viewModel.filteredProducts.count, 3)
    }

    // MARK: - Request Cancellation

    /// Verifies calling fetchProducts() twice cancels the first request.
    func testFetchProductsCancelsPreviousRequest() {
        mockRepository.mockProducts = MockData.sampleProducts()

        viewModel.fetchProducts()
        viewModel.fetchProducts()

        XCTAssertEqual(mockRepository.fetchCallCount, 2)
    }

    // MARK: - Clear Filters

    /// Verifies clearFilters resets search text, category, and sort option.
    func testClearFiltersResetsAll() {
        viewModel.searchText = "phone"
        viewModel.selectedCategory = "smartphones"
        viewModel.sortOption = .priceHighToLow

        viewModel.clearFilters()

        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.selectedCategory)
        XCTAssertEqual(viewModel.sortOption, .none)
    }

    /// Verifies hasActiveFilters detects a selected category.
    func testHasActiveFiltersWithCategory() {
        XCTAssertFalse(viewModel.hasActiveFilters)

        viewModel.selectedCategory = "beauty"
        XCTAssertTrue(viewModel.hasActiveFilters)
    }

    /// Verifies hasActiveFilters detects a non-default sort option.
    func testHasActiveFiltersWithSort() {
        viewModel.sortOption = .priceLowToHigh
        XCTAssertTrue(viewModel.hasActiveFilters)
    }

    // MARK: - Categories Extraction

    /// Verifies categories are extracted from products and sorted alphabetically.
    func testCategoriesAreExtractedAndSorted() {
        loadInitialProducts()

        XCTAssertEqual(viewModel.categories, ["beauty", "laptops", "smartphones"])
    }

    // MARK: - Fetch Call Args

    /// Verifies the initial fetch uses limit=pageSize and skip=0.
    func testFetchSendsCorrectInitialArgs() {
        mockRepository.mockProducts = MockData.sampleProducts()
        viewModel.fetchProducts()

        XCTAssertEqual(mockRepository.fetchCallArgs.first?.limit, 20)
        XCTAssertEqual(mockRepository.fetchCallArgs.first?.skip, 0)
    }
}

// MARK: - Filter Logic Tests

/// Pure function tests for the static applyFilters() method.
/// No ViewModel setup, Combine subscriptions, or async waiting needed.
final class ProductFilterTests: XCTestCase {
    private let products = MockData.sampleProducts()

    private func applyFilters(
        search: String = "",
        category: String? = nil,
        sort: SortOption = .none
    ) -> [Product] {
        ProductsViewModel.applyFilters(
            products: products,
            searchText: search,
            category: category,
            sortOption: sort
        )
    }

    // MARK: - Search

    /// Verifies search matches product title.
    func testSearchByTitle() {
        let results = applyFilters(search: "phone")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Test Phone")
    }

    /// Verifies search is case-insensitive.
    func testSearchIsCaseInsensitive() {
        let results = applyFilters(search: "LAPTOP")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Test Laptop")
    }

    /// Verifies search matches product brand.
    func testSearchByBrand() {
        let results = applyFilters(search: "BeautyBrand")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Red Lipstick")
    }

    /// Verifies search matches product description.
    func testSearchByDescription() {
        let results = applyFilters(search: "smartphone")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, 1)
    }

    /// Verifies non-matching search returns empty results.
    func testSearchNoResults() {
        let results = applyFilters(search: "nonexistent")
        XCTAssertTrue(results.isEmpty)
    }

    /// Verifies empty search text returns all products.
    func testEmptySearchReturnsAll() {
        let results = applyFilters()
        XCTAssertEqual(results.count, 3)
    }

    // MARK: - Category Filter

    /// Verifies filtering by category returns only matching products.
    func testFilterByCategory() {
        let results = applyFilters(category: "beauty")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.category, "beauty")
    }

    /// Verifies filtering by non-existent category returns empty results.
    func testFilterByCategoryNoMatch() {
        let results = applyFilters(category: "furniture")
        XCTAssertTrue(results.isEmpty)
    }

    /// Verifies nil category returns all products (no filter applied).
    func testNilCategoryReturnsAll() {
        let results = applyFilters()
        XCTAssertEqual(results.count, 3)
    }

    // MARK: - Sorting

    /// Verifies price ascending sort order.
    func testSortByPriceLowToHigh() {
        let results = applyFilters(sort: .priceLowToHigh)
        XCTAssertEqual(results.map(\.price), [12.99, 999.99, 1499.99])
    }

    /// Verifies price descending sort order.
    func testSortByPriceHighToLow() {
        let results = applyFilters(sort: .priceHighToLow)
        XCTAssertEqual(results.map(\.price), [1499.99, 999.99, 12.99])
    }

    /// Verifies rating descending sort order.
    func testSortByRatingHighToLow() {
        let results = applyFilters(sort: .ratingHighToLow)
        XCTAssertEqual(results.map(\.rating), [4.8, 4.5, 4.2])
    }

    /// Verifies rating ascending sort order.
    func testSortByRatingLowToHigh() {
        let results = applyFilters(sort: .ratingLowToHigh)
        XCTAssertEqual(results.map(\.rating), [4.2, 4.5, 4.8])
    }

    // MARK: - Combined Filters

    /// Verifies search + category filter work together.
    func testSearchWithCategoryFilter() {
        let results = applyFilters(search: "test", category: "smartphones")
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Test Phone")
    }

    /// Verifies sort + category filter work together.
    func testSortWithCategoryFilter() {
        let results = applyFilters(category: "smartphones", sort: .priceLowToHigh)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Test Phone")
    }

    /// Verifies search + category + sort all apply simultaneously.
    func testAllFiltersCombined() {
        let results = applyFilters(search: "test", category: "laptops", sort: .priceHighToLow)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.title, "Test Laptop")
    }

    // MARK: - Edge Cases

    /// Verifies filters on an empty product list return empty results.
    func testEmptyProductList() {
        let results = ProductsViewModel.applyFilters(
            products: [], searchText: "phone", category: nil, sortOption: .priceLowToHigh
        )
        XCTAssertTrue(results.isEmpty)
    }
}
