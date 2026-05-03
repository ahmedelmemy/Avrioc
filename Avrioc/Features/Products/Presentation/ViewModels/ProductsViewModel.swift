//
//  ProductsViewModel.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Drives the product list with reactive filtering, pagination, and offline handling.
//

import Foundation
import Combine

@MainActor
final class ProductsViewModel: ObservableObject {

    // MARK: - Outputs

    @Published private(set) var filteredProducts: [Product] = []
    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var categories: [String] = []
    @Published private(set) var isLoadingMore = false
    @Published private(set) var isOfflineData = false

    // MARK: - Inputs

    @Published var searchText = ""
    @Published var selectedCategory: String?
    @Published var sortOption: SortOption = .none

    // MARK: - Pagination

    private(set) var totalProducts = 0
    private let pageSize: Int

    var hasMorePages: Bool {
        allProducts.count < totalProducts
    }

    var hasActiveFilters: Bool {
        selectedCategory != nil || sortOption != .none
    }

    // MARK: - Private

    @Published private var allProducts: [Product] = []
    private var fetchCancellable: AnyCancellable?
    private var paginationCancellable: AnyCancellable?
    private var networkMonitorCancellable: AnyCancellable?
    private var refreshContinuation: CheckedContinuation<Void, Never>?

    private let repository: ProductRepositoryProtocol
    private let searchDebounceInterval: TimeInterval
    private let networkMonitor: NetworkMonitor?

    // MARK: - Init

    init(
        repository: ProductRepositoryProtocol,
        searchDebounceInterval: TimeInterval = 0.3,
        pageSize: Int = 20,
        networkMonitor: NetworkMonitor? = NetworkMonitor.shared
    ) {
        self.repository = repository
        self.searchDebounceInterval = searchDebounceInterval
        self.pageSize = pageSize
        self.networkMonitor = networkMonitor
        setupPipeline()
        observeNetworkChanges()
    }

    // MARK: - Combine Pipeline

    private func setupPipeline() {
        // Merge trick: emit the initial searchText immediately so the filter pipeline
        // produces results on first load, while debouncing subsequent keystrokes to
        // avoid re-filtering on every character typed.
        let debouncedSearch = Publishers.Merge(
            $searchText.first(),
            $searchText
                .dropFirst()
                .debounce(for: .seconds(searchDebounceInterval), scheduler: DispatchQueue.main)
        )
        .removeDuplicates()

        // Reactively recompute filtered results whenever any filter input or the
        // product list changes. Uses assign(to:) to bind directly to $filteredProducts
        // without creating a stored AnyCancellable (Combine manages the subscription lifecycle).
        Publishers.CombineLatest(
            Publishers.CombineLatest3(debouncedSearch, $selectedCategory, $sortOption),
            $allProducts
        )
        .map { filters, products in
            Self.applyFilters(
                products: products,
                searchText: filters.0,
                category: filters.1,
                sortOption: filters.2
            )
        }
        .assign(to: &$filteredProducts)
    }

    /// Auto-retry when connectivity is restored. dropFirst() skips the initial value
    /// to avoid a redundant fetch on launch. Only retries if we're showing cached data
    /// or haven't successfully loaded yet.
    private func observeNetworkChanges() {
        networkMonitorCancellable = networkMonitor?.$isConnected
            .removeDuplicates()
            .dropFirst()
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self, self.isOfflineData || self.viewState != .loaded else { return }
                self.fetchProducts()
            }
    }

    // MARK: - Actions

    func fetchProducts() {
        fetchCancellable?.cancel()
        paginationCancellable?.cancel()

        // When retrying from offline/cached state, keep showing stale data instead
        // of flashing a loading spinner — only show .loading on a fresh fetch.
        let wasOffline = isOfflineData
        if !wasOffline {
            viewState = .loading
        }

        fetchCancellable = repository.fetchProducts(limit: pageSize, skip: 0)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    // If we were showing cached data and the retry fails, silently
                    // keep the stale data rather than replacing it with an error screen.
                    if wasOffline {
                        self.isOfflineData = true
                    } else {
                        self.viewState = .error(error.localizedDescription)
                    }
                }
                self.refreshContinuation?.resume()
                self.refreshContinuation = nil
            } receiveValue: { [weak self] result in
                guard let self else { return }
                self.allProducts = result.products
                self.totalProducts = result.total
                self.categories = ProductMapper.extractCategories(from: result.products)
                self.viewState = result.products.isEmpty ? .empty : .loaded
                self.isOfflineData = result.isFromCache
            }
    }

    /// Bridges the Combine-based fetchProducts() with async/await for SwiftUI's
    /// .refreshable modifier, which requires an async function to know when to
    /// dismiss the pull-to-refresh spinner.
    func refreshProducts() async {
        // Resume any pending continuation before replacing it, otherwise
        // a rapid double pull-to-refresh would leak the first continuation
        // and trigger a CheckedContinuation fatal error in debug builds.
        refreshContinuation?.resume()
        await withCheckedContinuation { continuation in
            refreshContinuation = continuation
            fetchProducts()
        }
    }

    func loadMoreProducts() {
        guard hasMorePages, !isLoadingMore else { return }
        isLoadingMore = true

        paginationCancellable = repository.fetchProducts(limit: pageSize, skip: allProducts.count)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isLoadingMore = false
            } receiveValue: { [weak self] result in
                guard let self else { return }
                self.allProducts.append(contentsOf: result.products)
                self.totalProducts = result.total
                let updatedCategories = ProductMapper.extractCategories(from: self.allProducts)
                if updatedCategories != self.categories {
                    self.categories = updatedCategories
                }
            }
    }

    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        sortOption = .none
    }

    // MARK: - Filtering (static pure function — no side effects, easily unit-testable)

    static func applyFilters(
        products: [Product],
        searchText: String,
        category: String?,
        sortOption: SortOption
    ) -> [Product] {
        var result = products

        if let category {
            result = result.filter { $0.category == category }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.description.lowercased().contains(query) ||
                $0.category.lowercased().contains(query) ||
                ($0.brand?.lowercased().contains(query) ?? false)
            }
        }

        switch sortOption {
        case .none: break
        case .priceLowToHigh:  result.sort { $0.price < $1.price }
        case .priceHighToLow:  result.sort { $0.price > $1.price }
        case .ratingHighToLow: result.sort { $0.rating > $1.rating }
        case .ratingLowToHigh: result.sort { $0.rating < $1.rating }
        }

        return result
    }
}
