//
//  DetailsSectionView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Product specifications card with dimensions, stock, shipping, and tags.
//

import SwiftUI

struct DetailsSectionView: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.details)
                .font(.headline)

            DetailRow(label: Strings.skuLabel, value: product.sku)
            DetailRow(label: Strings.weightLabel, value: Strings.weight(product.weight))
            DetailRow(
                label: Strings.dimensionsLabel,
                value: Strings.dimensions(w: product.dimensions.width, h: product.dimensions.height, d: product.dimensions.depth)
            )
            DetailRow(label: Strings.stockLabel, value: Strings.stock(product.stock))
            DetailRow(label: Strings.minOrderLabel, value: Strings.stock(product.minimumOrderQuantity))
            DetailRow(label: Strings.warrantyLabel, value: product.warrantyInformation)
            DetailRow(label: Strings.shippingLabel, value: product.shippingInformation)
            DetailRow(label: Strings.returnPolicyLabel, value: product.returnPolicy)

            if !product.tags.isEmpty {
                HStack {
                    Text(Strings.tags)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 100, alignment: .leading)

                    FlowLayout(spacing: 4) {
                        ForEach(product.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .capsuleBadge(background: AppColors.tagBackground)
                        }
                    }
                }
            }
        }
        .sectionCard()
    }
}
