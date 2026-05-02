//
//  PriceSectionView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Price card showing current price, discount badge, and stock availability.
//

import SwiftUI

struct PriceSectionView: View {
    let price: Double
    let discountedPrice: Double
    let discountPercentage: Double
    let availabilityStatus: String
    let isInStock: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(Strings.price(discountedPrice))
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.price)

            if discountPercentage > 0 {
                Text(Strings.price(price))
                    .font(.body)
                    .strikethrough()
                    .foregroundStyle(.secondary)

                Text(Strings.discount(discountPercentage))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .capsuleBadge(foreground: AppColors.discount, background: AppColors.discountBackground)
            }

            Spacer()

            Label(availabilityStatus, systemImage: isInStock ? Strings.Icons.checkmarkCircleFill : Strings.Icons.warningFill)
                .font(.caption)
                .foregroundStyle(AppColors.stockForeground(inStock: isInStock))
        }
        .sectionCard()
    }
}
