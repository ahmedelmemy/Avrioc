//
//  PriceLabel.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Compact price display with optional strikethrough original price.
//

import SwiftUI

/// Compact price display with optional strikethrough original price.
/// Used in product cards and row items for consistent pricing presentation.
struct PriceLabel: View {
    let price: Double
    let discountedPrice: Double
    let discountPercentage: Double

    var body: some View {
        HStack(spacing: 4) {
            Text(Strings.price(discountedPrice))
                .font(.subheadline)
                .fontWeight(.bold)

            if discountPercentage > 0 {
                Text(Strings.price(price))
                    .font(.caption2)
                    .strikethrough()
                    .foregroundStyle(.secondary)
            }
        }
    }
}
