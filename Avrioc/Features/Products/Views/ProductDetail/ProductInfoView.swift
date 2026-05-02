//
//  ProductInfoView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Displays product category badge, rating summary, title, and brand.
//

import SwiftUI

struct ProductInfoView: View {
    let category: String
    let rating: Double
    let reviewsCount: Int
    let title: String
    let brand: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.capitalized)
                    .font(.caption)
                    .capsuleBadge(foreground: AppColors.accent, background: AppColors.accentLight)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: Strings.Icons.starFill)
                        .foregroundStyle(AppColors.rating)
                    Text(Strings.rating(rating))
                        .fontWeight(.semibold)
                    Text(Strings.reviewsCount(reviewsCount))
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }

            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            if let brand = brand {
                Text(Strings.byBrand(brand))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
