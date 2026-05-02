//
//  NetworkErrorTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Tests for error descriptions and Equatable conformance.
//

import XCTest
@testable import Avrioc

final class NetworkErrorTests: XCTestCase {

    // MARK: - Error Descriptions

    /// Verifies invalidURL returns the expected user-facing message.
    func testInvalidURLDescription() {
        let error = NetworkError.invalidURL
        XCTAssertEqual(error.errorDescription, "Invalid URL")
    }

    /// Verifies invalidResponse returns the expected user-facing message.
    func testInvalidResponseDescription() {
        let error = NetworkError.invalidResponse
        XCTAssertEqual(error.errorDescription, "Invalid server response")
    }

    /// Verifies httpError includes the status code in the message.
    func testHTTPErrorDescription() {
        let error = NetworkError.httpError(statusCode: 404)
        XCTAssertEqual(error.errorDescription, "Server error (status: 404)")
    }

    /// Verifies decodingError returns a generic message (not the underlying error).
    func testDecodingErrorDescription() {
        let underlying = NSError(domain: "test", code: 0)
        let error = NetworkError.decodingError(underlying)
        XCTAssertEqual(error.errorDescription, "Failed to process server data")
    }

    /// Verifies unknown error forwards the underlying error's localizedDescription.
    func testUnknownErrorUsesUnderlyingDescription() {
        let underlying = NSError(domain: "TestDomain", code: 42, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
        let error = NetworkError.unknown(underlying)
        XCTAssertEqual(error.errorDescription, "Something went wrong")
    }

    // MARK: - Equatable

    /// Verifies same cases are equal (wrapped errors are compared by case identity only).
    func testSameCasesAreEqual() {
        XCTAssertEqual(NetworkError.invalidURL, .invalidURL)
        XCTAssertEqual(NetworkError.invalidResponse, .invalidResponse)
        XCTAssertEqual(NetworkError.httpError(statusCode: 500), .httpError(statusCode: 500))
        // Wrapped errors are NOT compared — only case identity matters.
        XCTAssertEqual(NetworkError.decodingError(NSError(domain: "", code: 0)), .decodingError(NSError(domain: "other", code: 1)))
        XCTAssertEqual(NetworkError.unknown(NSError(domain: "", code: 0)), .unknown(NSError(domain: "other", code: 1)))
    }

    /// Verifies httpError cases with different status codes are not equal.
    func testDifferentHTTPStatusCodesAreNotEqual() {
        XCTAssertNotEqual(NetworkError.httpError(statusCode: 404), .httpError(statusCode: 500))
    }

    /// Verifies different error cases are not equal to each other.
    func testDifferentCasesAreNotEqual() {
        XCTAssertNotEqual(NetworkError.invalidURL, .invalidResponse)
        XCTAssertNotEqual(NetworkError.invalidURL, .httpError(statusCode: 400))
        XCTAssertNotEqual(NetworkError.invalidResponse, .decodingError(NSError(domain: "", code: 0)))
        XCTAssertNotEqual(NetworkError.decodingError(NSError(domain: "", code: 0)), .unknown(NSError(domain: "", code: 0)))
    }
}
