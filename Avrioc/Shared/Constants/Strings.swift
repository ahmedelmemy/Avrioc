//
//  Strings.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Core string constants and formatting helpers shared across the app.
//

import Foundation

enum Strings {

    // MARK: - Formatting

    static func weight(_ value: Int) -> String { "\(value)g" }
    static func stock(_ value: Int) -> String { "\(value) units" }
    static func dimensions(w: Double, h: Double, d: Double) -> String {
        String(format: "%.1f x %.1f x %.1f cm", w, h, d)
    }
    static func reviews(count: Int) -> String { "Reviews (\(count))" }
    static func reviewsCount(_ count: Int) -> String { "(\(count) reviews)" }
    static func price(_ value: Double) -> String { String(format: "$%.2f", value) }
    static func discount(_ percentage: Double) -> String { String(format: "-%.0f%%", percentage) }
    static func byBrand(_ brand: String) -> String { "by \(brand)" }
    static func rating(_ value: Double) -> String { String(format: "%.1f", value) }
}
