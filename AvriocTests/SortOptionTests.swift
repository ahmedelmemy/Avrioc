//
//  SortOptionTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Tests for sort option display names and identifiers.
//

import XCTest
@testable import Avrioc

final class SortOptionTests: XCTestCase {

    /// Verifies each sort option returns the correct user-facing display name.
    func testDisplayNames() {
        XCTAssertEqual(SortOption.none.displayName, "Default")
        XCTAssertEqual(SortOption.priceLowToHigh.displayName, "Price: Low to High")
        XCTAssertEqual(SortOption.priceHighToLow.displayName, "Price: High to Low")
        XCTAssertEqual(SortOption.ratingHighToLow.displayName, "Rating: High to Low")
        XCTAssertEqual(SortOption.ratingLowToHigh.displayName, "Rating: Low to High")
    }

    /// Verifies id returns the rawValue for Identifiable conformance.
    func testIdMatchesRawValue() {
        for option in SortOption.allCases {
            XCTAssertEqual(option.id, option.rawValue)
        }
    }

    /// Verifies CaseIterable includes all 5 sort options.
    func testAllCasesCount() {
        XCTAssertEqual(SortOption.allCases.count, 5)
    }
}
