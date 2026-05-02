//
//  MockProductCacheService.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  In-memory cache mock for testing repository cache interactions.
//

import Foundation
@testable import Avrioc

final class MockProductCacheService: ProductCacheServiceProtocol, @unchecked Sendable {
    var cachedResponse: ProductResponseDTO?

    private(set) var saveCallCount = 0
    private(set) var lastSavedResponse: ProductResponseDTO?
    private(set) var lastSavedIsFirstPage: Bool?

    func save(_ response: ProductResponseDTO, isFirstPage: Bool) {
        saveCallCount += 1
        lastSavedResponse = response
        lastSavedIsFirstPage = isFirstPage
    }

    func load() -> ProductResponseDTO? {
        cachedResponse
    }

    func clear() {
        cachedResponse = nil
        lastSavedResponse = nil
        lastSavedIsFirstPage = nil
        saveCallCount = 0
    }
}
