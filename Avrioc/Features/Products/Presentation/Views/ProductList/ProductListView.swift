//
//  ProductListView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Main product browsing screen with grid/list toggle, search, filtering, and pagination.
//

import SwiftUI

struct ProductListView: View {
    @ObservedObject var viewModel: ProductsViewModel
    @State private var showFilterSheet = false
    @State private var isGridLayout = true

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .idle, .loading:
                    LoadingView()
                case .loaded:
                    productContent
                case .empty:
                    EmptyProductsView()
                case .error(let message):
                    ErrorView(message: message) {
                        viewModel.fetchProducts()
                    }
                }
            }
            .navigationTitle(Strings.productsTitle)
            // Placed on the NavigationStack (not inside the grid/list) to avoid
            // duplicate navigation destinations when switching between layouts.
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .searchable(text: $viewModel.searchText, prompt: Strings.searchPrompt)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation { isGridLayout.toggle() }
                        } label: {
                            Image(systemName: isGridLayout ? Strings.Icons.listBullet : Strings.Icons.grid)
                        }

                        Button {
                            showFilterSheet = true
                        } label: {
                            Image(systemName: viewModel.hasActiveFilters ? Strings.Icons.filterActive : Strings.Icons.filterInactive)
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.refreshProducts()
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSortView(
                    categories: viewModel.categories,
                    selectedCategory: $viewModel.selectedCategory,
                    sortOption: $viewModel.sortOption
                )
                .presentationDetents([.medium])
            }
        }
        .task {
            // Guard against re-fetching if data is already loaded (e.g., after
            // returning from a detail view). Only fetch on first appearance.
            if viewModel.viewState == .idle {
                viewModel.fetchProducts()
            }
        }
    }

    // MARK: - Content

    private var productContent: some View {
        Group {
            if viewModel.filteredProducts.isEmpty {
                ContentUnavailableView(
                    Strings.noResults,
                    systemImage: Strings.Icons.search,
                    description: Text(Strings.noResultsDescription)
                )
            } else {
                ScrollView {
                    if viewModel.isOfflineData {
                        OfflineBannerView {
                            viewModel.fetchProducts()
                        }
                    }

                    if isGridLayout {
                        gridView
                    } else {
                        listView
                    }

                    if viewModel.isLoadingMore {
                        ProgressView()
                            .padding()
                    }
                }
            }
        }
    }

    private var gridView: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(viewModel.filteredProducts) { product in
                NavigationLink(value: product) {
                    ProductCardView(product: product)
                }
                .buttonStyle(.plain)
                .onAppear { loadMoreIfNeeded(currentProduct: product) }
            }
        }
        .padding(.horizontal)
    }

    private var listView: some View {
        LazyVStack(spacing: 8) {
            ForEach(viewModel.filteredProducts) { product in
                NavigationLink(value: product) {
                    ProductRowView(product: product)
                }
                .buttonStyle(.plain)
                .onAppear { loadMoreIfNeeded(currentProduct: product) }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Pagination

    /// Triggers pagination when the user scrolls within 3 items of the end.
    /// Uses suffix(3) which is O(1) on Array, avoiding a full-list scan per cell.
    private func loadMoreIfNeeded(currentProduct: Product) {
        guard viewModel.hasMorePages else { return }
        let items = viewModel.filteredProducts
        guard items.suffix(3).contains(where: { $0.id == currentProduct.id }) else { return }
        viewModel.loadMoreProducts()
    }
}
