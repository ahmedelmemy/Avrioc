//
//  DependencyContainer.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Assembles and provides shared dependencies for the application.
//

import Foundation

final class DependencyContainer {
    let productRepository: ProductRepositoryProtocol

    init(
        httpClient: HTTPClientProtocol = HTTPClient(),
        cache: ProductCacheServiceProtocol = ProductCacheService()
    ) {
        self.productRepository = ProductRepository(httpClient: httpClient, cache: cache)
    }
}
