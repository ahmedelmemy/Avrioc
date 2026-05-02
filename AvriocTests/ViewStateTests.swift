//
//  ViewStateTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Tests for ViewState equality and all case variants.
//

import XCTest
@testable import Avrioc

final class ViewStateTests: XCTestCase {

    /// Verifies all simple cases (no associated values) are equal to themselves.
    func testSimpleCasesAreEqual() {
        XCTAssertEqual(ViewState.idle, .idle)
        XCTAssertEqual(ViewState.loading, .loading)
        XCTAssertEqual(ViewState.loaded, .loaded)
        XCTAssertEqual(ViewState.empty, .empty)
    }

    /// Verifies error cases with the same message string are equal.
    func testErrorCasesWithSameMessageAreEqual() {
        XCTAssertEqual(ViewState.error("fail"), .error("fail"))
    }

    /// Verifies error cases with different messages are not equal.
    func testErrorCasesWithDifferentMessagesAreNotEqual() {
        XCTAssertNotEqual(ViewState.error("a"), .error("b"))
    }

    /// Verifies different case variants are not equal to each other.
    func testDifferentCasesAreNotEqual() {
        XCTAssertNotEqual(ViewState.idle, .loading)
        XCTAssertNotEqual(ViewState.loading, .loaded)
        XCTAssertNotEqual(ViewState.loaded, .empty)
        XCTAssertNotEqual(ViewState.empty, .error("x"))
    }
}
