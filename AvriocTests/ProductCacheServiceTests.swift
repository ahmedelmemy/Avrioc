//
//  ProductCacheServiceTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Tests for disk-based cache: save/load, page accumulation, deduplication, and thread safety.
//

import XCTest
@testable import Avrioc

final class ProductCacheServiceTests: XCTestCase {
    private var sut: ProductCacheService!

    override func setUp() {
        super.setUp()
        // UUID-based filename prevents cross-test interference when running in parallel.
        sut = ProductCacheService(fileName: "test_cache_\(UUID().uuidString).json")
    }

    override func tearDown() {
        sut.clear()
        sut = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeResponse(
        ids: [Int],
        total: Int? = nil,
        skip: Int = 0,
        limit: Int = 20
    ) -> ProductResponseDTO {
        let products = ids.map { MockData.makeProductDTO(id: $0, title: "Product \($0)") }
        return ProductResponseDTO(
            products: products,
            total: total ?? ids.count,
            skip: skip,
            limit: limit
        )
    }

    // MARK: - Basic Operations

    /// Verifies a saved response can be loaded back with correct data.
    func testSaveAndLoad() {
        sut.save(makeResponse(ids: [1]), isFirstPage: true)
        let loaded = sut.load()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded?.products.count, 1)
        XCTAssertEqual(loaded?.products.first?.id, 1)
    }

    /// Verifies load returns nil when no cache file exists.
    func testLoadReturnsNilWhenEmpty() {
        XCTAssertNil(sut.load())
    }

    /// Verifies clear removes the cache file so load returns nil.
    func testClearRemovesCache() {
        sut.save(makeResponse(ids: [1]), isFirstPage: true)
        XCTAssertNotNil(sut.load())

        sut.clear()
        XCTAssertNil(sut.load())
    }

    // MARK: - Page Accumulation

    /// Verifies saving a first page replaces the entire cache (no leftover data).
    func testFirstPageReplacesExistingCache() {
        sut.save(makeResponse(ids: [1, 2, 3], total: 100), isFirstPage: true)
        XCTAssertEqual(sut.load()?.products.count, 3)

        sut.save(makeResponse(ids: [99], total: 50), isFirstPage: true)

        let loaded = sut.load()
        XCTAssertEqual(loaded?.products.count, 1)
        XCTAssertEqual(loaded?.products.first?.id, 99)
        XCTAssertEqual(loaded?.total, 50)
    }

    /// Verifies subsequent pages are merged with existing cached products.
    func testSubsequentPagesAccumulate() {
        sut.save(makeResponse(ids: [1], total: 100), isFirstPage: true)
        sut.save(makeResponse(ids: [42], total: 100, skip: 20), isFirstPage: false)

        let loaded = sut.load()
        XCTAssertEqual(loaded?.products.count, 2)
        XCTAssertEqual(loaded?.products.map(\.id), [1, 42])
        XCTAssertEqual(loaded?.total, 100)
    }

    /// Verifies duplicate product IDs are deduplicated during page merging.
    func testDuplicateIDsAreNotAppended() {
        sut.save(makeResponse(ids: [1, 2], total: 100), isFirstPage: true)
        sut.save(makeResponse(ids: [1, 3], total: 100, skip: 20), isFirstPage: false)

        let loaded = sut.load()
        XCTAssertEqual(loaded?.products.count, 3)
        XCTAssertEqual(Set(loaded?.products.map(\.id) ?? []), [1, 2, 3])
    }

    // MARK: - Thread Safety

    /// Verifies concurrent saves on different queues don't crash or lose data.
    func testConcurrentSavesDoNotLosePages() {
        sut.save(makeResponse(ids: [1], total: 100), isFirstPage: true)

        let expectation = XCTestExpectation(description: "Concurrent saves")
        expectation.expectedFulfillmentCount = 2

        DispatchQueue.global().async {
            self.sut.save(self.makeResponse(ids: [50], total: 100, skip: 20), isFirstPage: false)
            expectation.fulfill()
        }
        DispatchQueue.global().async {
            self.sut.save(self.makeResponse(ids: [51], total: 100, skip: 40), isFirstPage: false)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)

        let loaded = sut.load()
        XCTAssertEqual(loaded?.products.count, 3)
        XCTAssertEqual(Set(loaded?.products.map(\.id) ?? []), [1, 50, 51])
    }
}
