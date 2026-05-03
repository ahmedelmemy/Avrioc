//
//  ProductCardView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Grid card layout for a single product with thumbnail, price, and stock status.
//

import SwiftUI

struct ProductCardView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CachedAsyncImage(url: URL(string: product.thumbnail)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                case .failure:
                    Image(systemName: Strings.Icons.photo)
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 140)
            .background(AppColors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .frame(minHeight: 40, alignment: .topLeading)

                // Invisible placeholder keeps card height consistent when brand is nil
                Text(product.brand ?? " ")
                    .font(.caption)
                    .foregroundStyle(product.brand != nil ? Color.secondary : Color.clear)

                PriceLabel(
                    price: product.price,
                    discountedPrice: product.discountedPrice,
                    discountPercentage: product.discountPercentage
                )

                Spacer(minLength: 0)

                HStack(spacing: 2) {
                    RatingLabel(rating: product.rating)

                    Spacer()

                    Text(product.availabilityStatus)
                        .font(.caption2)
                        .capsuleBadge(
                            foreground: AppColors.stockForeground(inStock: product.isInStock),
                            background: AppColors.stockBackground(inStock: product.isInStock)
                        )
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        // Stretch to fill the grid cell height so all cards align in a row,
        // pinning content to the top to keep visual consistency.
        .frame(maxHeight: .infinity, alignment: .top)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: AppColors.cardShadow, radius: 4, x: 0, y: 2)
    }
}
