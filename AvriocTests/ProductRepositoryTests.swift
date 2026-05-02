//
//  ProductRepositoryTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Tests for network-to-cache fallback, DTO mapping, and pagination caching.
//

import XCTest
import Combine
@testable import Avrioc

final class ProductRepositoryTests: XCTestCase {
    private var sut: ProductRepository!
    private var mockHTTP: MockHTTPClient!
    private var mockCache: MockProductCacheService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockHTTP = MockHTTPClient()
        mockCache = MockProductCacheService()
        sut = ProductRepository(httpClient: mockHTTP, cache: mockCache)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockHTTP = nil
        mockCache = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeResponse(ids: [Int], total: Int? = nil) -> ProductResponseDTO {
        let products = ids.map { MockData.makeProductDTO(id: $0, title: "Product \($0)") }
        return ProductResponseDTO(products: products, total: total ?? ids.count, skip: 0, limit: 20)
    }

    /// Subscribes to the repository publisher and waits for completion, returning the Result.
    private func awaitResult(
        limit: Int = 20,
        skip: Int = 0,
        timeout: TimeInterval = 2.0
    ) -> Result<PaginatedProducts, NetworkError> {
        let exp = XCTestExpectation(description: "Await fetch")
        var result: Result<PaginatedProducts, NetworkError>!

        sut.fetchProducts(limit: limit, skip: skip)
            .sink { completion in
                if case .failure(let error) = completion {
                    result = .failure(error)
                }
                exp.fulfill()
            } receiveValue: { value in
                result = .success(value)
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: timeout)
        return result
    }

    // MARK: - Success Path

    /// Verifies successful fetch maps DTOs to domain, returns correct total, and caches as first page.
    func testSuccessfulFetchMapsProductsAndCaches() {
        let response = makeResponse(ids: [1, 2, 3], total: 100)
        mockHTTP.result = .success(response)

        guard case .success(let result) = awaitResult() else {
            return XCTFail("Expected success")
        }

        XCTAssertEqual(result.products.count, 3)
        XCTAssertEqual(result.products.map(\.id), [1, 2, 3])
        XCTAssertEqual(result.total, 100)
        XCTAssertFalse(result.isFromCache)

        XCTAssertEqual(mockCache.saveCallCount, 1)
        XCTAssertEqual(mockCache.lastSavedIsFirstPage, true)
        XCTAssertEqual(mockCache.lastSavedResponse?.products.count, 3)
    }

    /// Verifies fetching with skip > 0 marks the cache save as non-first page.
    func testSuccessfulFetchOnSubsequentPageMarksNotFirstPage() {
        let response = makeResponse(ids: [21, 22])
        mockHTTP.result = .success(response)

        guard case .success = awaitResult(skip: 20) else {
            return XCTFail("Expected success")
        }

        XCTAssertEqual(mockCache.lastSavedIsFirstPage, false)
    }

    // MARK: - Cache Fallback

    /// Verifies first-page failure falls back to cached data with isFromCache = true.
    func testFirstPageFailureFallsBackToCache() {
        mockHTTP.result = .failure(.invalidResponse)
        mockCache.cachedResponse = makeResponse(ids: [10, 11], total: 50)

        guard case .success(let result) = awaitResult(skip: 0) else {
            return XCTFail("Expected cache fallback, got failure")
        }

        XCTAssertTrue(result.isFromCache)
        XCTAssertEqual(result.products.count, 2)
        XCTAssertEqual(result.products.map(\.id), [10, 11])
        XCTAssertEqual(result.total, 50)
    }

    /// Verifies non-first-page failure propagates error (no cache fallback to avoid duplicates).
    func testSubsequentPageFailureDoesNotFallBackToCache() {
        mockHTTP.result = .failure(.invalidResponse)
        mockCache.cachedResponse = makeResponse(ids: [10, 11])

        guard case .failure(let error) = awaitResult(skip: 20) else {
            return XCTFail("Expected failure for non-first page, got success")
        }

        XCTAssertEqual(error, .invalidResponse)
    }

    /// Verifies first-page failure with empty cache propagates the original error.
    func testFirstPageFailureWithNoCachePropagatestError() {
        mockHTTP.result = .failure(.httpError(statusCode: 500))
        mockCache.cachedResponse = nil

        guard case .failure(let error) = awaitResult(skip: 0) else {
            return XCTFail("Expected failure when no cache available")
        }

        XCTAssertEqual(error, .httpError(statusCode: 500))
    }

    // MARK: - DTO Mapping

    /// Verifies discountedPrice is correctly computed during DTO-to-domain mapping.
    func testDiscountedPriceIsCalculatedDuringMapping() throws {
        let dto = MockData.makeProductDTO(price: 200.0, discountPercentage: 25.0)
        let response = ProductResponseDTO(products: [dto], total: 1, skip: 0, limit: 20)
        mockHTTP.result = .success(response)

        guard case .success(let result) = awaitResult() else {
            return XCTFail("Expected success")
        }

        let discountedPrice = try XCTUnwrap(result.products.first?.discountedPrice)
        XCTAssertEqual(discountedPrice, 150.0, accuracy: 0.01)
    }

    /// Verifies cache fallback also maps DTOs to domain models (not raw DTOs).
    func testCacheFallbackAlsoMapsDTOsToDomain() {
        mockHTTP.result = .failure(.invalidResponse)
        let dto = MockData.makeProductDTO(id: 5, title: "Cached Product", brand: "CachedBrand")
        mockCache.cachedResponse = ProductResponseDTO(products: [dto], total: 1, skip: 0, limit: 20)

        guard case .success(let result) = awaitResult() else {
            return XCTFail("Expected cache fallback")
        }

        XCTAssertEqual(result.products.first?.title, "Cached Product")
        XCTAssertEqual(result.products.first?.brand, "CachedBrand")
    }
}
