//
//  ProductModelTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Tests for Product domain model: identity equality, hashing, isInStock, and Review.id.
//

import XCTest
@testable import Avrioc

final class ProductModelTests: XCTestCase {

    // MARK: - isInStock

    /// Verifies isInStock returns true when availabilityStatus matches "In Stock".
    func testIsInStockWhenStatusMatches() {
        let product = MockData.makeProduct(availabilityStatus: "In Stock")
        XCTAssertTrue(product.isInStock)
    }

    /// Verifies isInStock returns false for "Low Stock" status.
    func testIsNotInStockWhenStatusDiffers() {
        let product = MockData.makeProduct(availabilityStatus: "Low Stock")
        XCTAssertFalse(product.isInStock)
    }

    /// Verifies isInStock returns false for "Out of Stock" status.
    func testIsNotInStockWhenOutOfStock() {
        let product = MockData.makeProduct(availabilityStatus: "Out of Stock")
        XCTAssertFalse(product.isInStock)
    }

    // MARK: - Identity-based Equality

    /// Verifies two products with the same ID are equal regardless of other fields.
    func testProductsWithSameIdAreEqual() {
        let a = MockData.makeProduct(id: 1, title: "Product A", price: 10)
        let b = MockData.makeProduct(id: 1, title: "Product B", price: 99)
        XCTAssertEqual(a, b)
    }

    /// Verifies two products with different IDs are not equal.
    func testProductsWithDifferentIdsAreNotEqual() {
        let a = MockData.makeProduct(id: 1)
        let b = MockData.makeProduct(id: 2)
        XCTAssertNotEqual(a, b)
    }

    // MARK: - Identity-based Hashing

    /// Verifies products with the same ID produce the same hash value.
    func testProductsWithSameIdHaveSameHash() {
        let a = MockData.makeProduct(id: 5, title: "A")
        let b = MockData.makeProduct(id: 5, title: "B")
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    /// Verifies identity-based hashing enables correct Set deduplication.
    func testProductsCanBeUsedInSet() {
        let a = MockData.makeProduct(id: 1)
        let b = MockData.makeProduct(id: 1, title: "Different")
        let c = MockData.makeProduct(id: 2)
        let set: Set<Product> = [a, b, c]
        XCTAssertEqual(set.count, 2)
    }

    // MARK: - Review.id

    /// Verifies Review.id is a composite key of reviewerEmail + date.
    func testReviewIdIsCompositeKey() {
        let review = Review(rating: 5, comment: "Great", date: "2025-01-01", reviewerName: "Ahmed Elmemy", reviewerEmail: "ahmedelmemy@test.com")
        XCTAssertEqual(review.id, "ahmedelmemy@test.com-2025-01-01")
    }

    /// Verifies different reviews produce different composite IDs.
    func testDifferentReviewsHaveDifferentIds() {
        let a = Review(rating: 5, comment: "A", date: "2025-01-01", reviewerName: "Ahmed Elmemy", reviewerEmail: "ahmedelmemy@test.com")
        let b = Review(rating: 5, comment: "B", date: "2025-01-02", reviewerName: "Ahmed E.", reviewerEmail: "ahmed.e@test.com")
        XCTAssertNotEqual(a.id, b.id)
    }
}
