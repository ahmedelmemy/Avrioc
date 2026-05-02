//
//  ProductRowView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Compact horizontal row layout for a single product in list mode.
//

import SwiftUI

struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: URL(string: product.thumbnail)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: Strings.Icons.photo)
                        .foregroundStyle(.secondary)
                default:
                    ProgressView()
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .background(AppColors.secondaryBackground.clipShape(RoundedRectangle(cornerRadius: 8)))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                if let brand = product.brand {
                    Text(brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack {
                    PriceLabel(
                        price: product.price,
                        discountedPrice: product.discountedPrice,
                        discountPercentage: product.discountPercentage
                    )

                    Spacer()

                    RatingLabel(rating: product.rating)
                }
            }
        }
        .padding(8)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: AppColors.rowShadow, radius: 2, x: 0, y: 1)
    }
}
