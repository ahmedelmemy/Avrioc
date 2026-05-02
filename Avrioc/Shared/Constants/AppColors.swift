//
//  AppColors.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Centralized color palette for backgrounds, accents, badges, and shadows.
//

import SwiftUI

enum AppColors {

    // MARK: - Backgrounds

    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.systemGray6)

    // MARK: - Accent

    static let accent = Color.blue
    static let accentLight = Color.blue.opacity(0.12)
    static let tagBackground = Color.blue.opacity(0.1)

    // MARK: - Rating

    static let rating = Color.orange

    // MARK: - Price & Discount

    static let price = Color.green
    static let discount = Color.red
    static let discountBackground = Color.red.opacity(0.15)

    // MARK: - Stock Status

    static let offlineBanner = Color.yellow.opacity(0.2)

    static func stockBackground(inStock: Bool) -> Color {
        inStock ? Color.green.opacity(0.15) : Color.orange.opacity(0.15)
    }

    static func stockForeground(inStock: Bool) -> Color {
        inStock ? .green : .orange
    }

    // MARK: - Shadows

    static let cardShadow = Color.black.opacity(0.08)
    static let rowShadow = Color.black.opacity(0.05)

    // MARK: - Destructive

    static let destructive = Color.red
}
