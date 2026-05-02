//
//  MockProductRepository.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Configurable repository mock with optional delay for pagination double-fire tests.
//

import Foundation
import Combine
@testable import Avrioc

final class MockProductRepository: ProductRepositoryProtocol, @unchecked Sendable {
    var mockProducts: [Product] = []
    var mockTotal: Int?
    var mockIsFromCache = false
    var mockError: NetworkError?
    var mockDelay: TimeInterval?

    private(set) var fetchCallArgs: [(limit: Int, skip: Int)] = []
    var fetchCallCount: Int { fetchCallArgs.count }

    func fetchProducts(limit: Int, skip: Int) -> AnyPublisher<PaginatedProducts, NetworkError> {
        fetchCallArgs.append((limit: limit, skip: skip))

        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }

        let result = PaginatedProducts(
            products: mockProducts,
            total: mockTotal ?? mockProducts.count,
            isFromCache: mockIsFromCache
        )

        let publisher = Just(result).setFailureType(to: NetworkError.self)

        if let delay = mockDelay {
            return publisher
                .delay(for: .seconds(delay), scheduler: DispatchQueue.main)
                .eraseToAnyPublisher()
        }

        return publisher.eraseToAnyPublisher()
    }

    func resetCallTracking() {
        fetchCallArgs.removeAll()
    }
}
