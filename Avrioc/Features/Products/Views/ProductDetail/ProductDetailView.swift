//
//  ProductDetailView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Full product detail screen composing carousel, info, pricing, specs, and reviews.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ImageCarouselView(images: product.images, thumbnail: product.thumbnail)
                ProductInfoView(
                    category: product.category,
                    rating: product.rating,
                    reviewsCount: product.reviews.count,
                    title: product.title,
                    brand: product.brand
                )
                PriceSectionView(
                    price: product.price,
                    discountedPrice: product.discountedPrice,
                    discountPercentage: product.discountPercentage,
                    availabilityStatus: product.availabilityStatus,
                    isInStock: product.isInStock
                )
                DescriptionSectionView(text: product.description)
                DetailsSectionView(product: product)
                ReviewsSectionView(reviews: product.reviews)
            }
            .padding()
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
