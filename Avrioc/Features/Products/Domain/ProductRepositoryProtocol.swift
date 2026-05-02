//
//  ProductRepositoryProtocol.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Repository contract and paginated result type for product fetching.
//

import Foundation
import Combine

struct PaginatedProducts: Sendable {
    let products: [Product]
    let total: Int
    let isFromCache: Bool
}

protocol ProductRepositoryProtocol: Sendable {
    func fetchProducts(limit: Int, skip: Int) -> AnyPublisher<PaginatedProducts, NetworkError>
}
