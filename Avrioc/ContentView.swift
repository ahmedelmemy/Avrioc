//
//  ContentView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Root view that owns the ProductsViewModel and hosts the product list.
//

import SwiftUI

struct ContentView: View {
    // @StateObject ensures the ViewModel survives view re-creation cycles.
    // Initialized via _viewModel wrapper because the dependency comes from init params.
    @StateObject private var viewModel: ProductsViewModel

    init(container: DependencyContainer) {
        _viewModel = StateObject(wrappedValue:
            ProductsViewModel(repository: container.productRepository)
        )
    }

    var body: some View {
        ProductListView(viewModel: viewModel)
    }
}
