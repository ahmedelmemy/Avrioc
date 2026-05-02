//
//  ProductRepository.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Fetches products from the API with disk cache fallback for offline support.
//

import Foundation
import Combine

final class ProductRepository: ProductRepositoryProtocol {
    private let httpClient: HTTPClientProtocol
    private let cache: ProductCacheServiceProtocol

    init(httpClient: HTTPClientProtocol, cache: ProductCacheServiceProtocol) {
        self.httpClient = httpClient
        self.cache = cache
    }

    func fetchProducts(limit: Int, skip: Int) -> AnyPublisher<PaginatedProducts, NetworkError> {
        let isFirstPage = skip == 0
        let publisher: AnyPublisher<ProductResponseDTO, NetworkError> = httpClient.request(
            .products(limit: limit, skip: skip)
        )

        return publisher
            // Capture [cache] (not [weak self]) so cache writes complete even if
            // the repository is deallocated mid-flight (e.g., during a dependency swap).
            .handleEvents(receiveOutput: { [cache] response in
                cache.save(response, isFirstPage: isFirstPage)
            })
            .map { response -> PaginatedProducts in
                PaginatedProducts(
                    products: ProductMapper.mapToDomain(response.products),
                    total: response.total,
                    isFromCache: false
                )
            }
            .catch { [cache] error -> AnyPublisher<PaginatedProducts, NetworkError> in
                // Only fall back to cache on first-page failures to avoid duplicate products
                guard isFirstPage, let cached = cache.load() else {
                    return Fail(error: error).eraseToAnyPublisher()
                }
                let result = PaginatedProducts(
                    products: ProductMapper.mapToDomain(cached.products),
                    total: cached.total,
                    isFromCache: true
                )
                return Just(result)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
