//
//  APIEndpointTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Tests for URL construction and query parameter encoding.
//

import XCTest
@testable import Avrioc

final class APIEndpointTests: XCTestCase {

    /// Verifies the products endpoint constructs the correct base URL (scheme, host, path).
    func testProductsEndpointBaseURL() {
        let endpoint = APIEndpoint.products(limit: 20, skip: 0)
        let url = endpoint.url

        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "https")
        XCTAssertEqual(url?.host, "dummyjson.com")
        XCTAssertEqual(url?.path, "/products")
    }

    /// Verifies limit and skip are encoded as query parameters with correct values.
    func testProductsEndpointQueryParameters() {
        let endpoint = APIEndpoint.products(limit: 10, skip: 30)
        let url = endpoint.url
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)!
        let queryItems = components.queryItems!

        XCTAssertEqual(queryItems.count, 2)
        XCTAssertEqual(queryItems.first(where: { $0.name == "limit" })?.value, "10")
        XCTAssertEqual(queryItems.first(where: { $0.name == "skip" })?.value, "30")
    }

    /// Verifies urlRequest is non-nil for a valid endpoint.
    func testURLRequestIsNonNil() {
        let endpoint = APIEndpoint.products(limit: 20, skip: 0)
        XCTAssertNotNil(endpoint.urlRequest)
    }

    /// Verifies urlRequest wraps the same URL as the url property.
    func testURLRequestContainsCorrectURL() {
        let endpoint = APIEndpoint.products(limit: 5, skip: 10)
        let request = endpoint.urlRequest

        XCTAssertEqual(request?.url, endpoint.url)
    }
}
