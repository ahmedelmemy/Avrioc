//
//  StringsTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Tests for string formatting helpers used across the app.
//

import XCTest
@testable import Avrioc

final class StringsTests: XCTestCase {

    /// Verifies price formatting with dollar sign and two decimal places.
    func testPriceFormatting() {
        XCTAssertEqual(Strings.price(9.99), "$9.99")
        XCTAssertEqual(Strings.price(1000), "$1000.00")
        XCTAssertEqual(Strings.price(0), "$0.00")
    }

    /// Verifies rating formatting with one decimal place.
    func testRatingFormatting() {
        XCTAssertEqual(Strings.rating(4.5), "4.5")
        XCTAssertEqual(Strings.rating(3.0), "3.0")
    }

    /// Verifies discount formatting with minus sign and no decimal places.
    func testDiscountFormatting() {
        XCTAssertEqual(Strings.discount(25.0), "-25%")
        XCTAssertEqual(Strings.discount(10.0), "-10%")
    }

    /// Verifies weight formatting with gram suffix.
    func testWeightFormatting() {
        XCTAssertEqual(Strings.weight(500), "500g")
    }

    /// Verifies stock formatting with units suffix.
    func testStockFormatting() {
        XCTAssertEqual(Strings.stock(42), "42 units")
    }

    /// Verifies dimensions formatting with "W x H x D cm" pattern.
    func testDimensionsFormatting() {
        XCTAssertEqual(Strings.dimensions(w: 10.0, h: 20.5, d: 3.0), "10.0 x 20.5 x 3.0 cm")
    }

    /// Verifies review count formatting in both header and inline styles.
    func testReviewsFormatting() {
        XCTAssertEqual(Strings.reviews(count: 5), "Reviews (5)")
        XCTAssertEqual(Strings.reviewsCount(3), "(3 reviews)")
    }

    /// Verifies brand attribution formatting.
    func testByBrandFormatting() {
        XCTAssertEqual(Strings.byBrand("Apple"), "by Apple")
    }
}
