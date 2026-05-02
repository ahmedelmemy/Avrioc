//
//  ProductMapper.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Maps DTOs to domain models and extracts unique sorted categories.
//

import Foundation

enum ProductMapper {

    static func mapToDomain(_ dto: ProductDTO) -> Product {
        Product(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            category: dto.category,
            price: dto.price,
            discountPercentage: dto.discountPercentage,
            discountedPrice: dto.price * (1 - dto.discountPercentage / 100),
            rating: dto.rating,
            stock: dto.stock,
            tags: dto.tags,
            brand: dto.brand,
            sku: dto.sku,
            weight: dto.weight,
            dimensions: mapDimensions(dto.dimensions),
            warrantyInformation: dto.warrantyInformation,
            shippingInformation: dto.shippingInformation,
            availabilityStatus: dto.availabilityStatus,
            reviews: dto.reviews.map { mapReview($0) },
            returnPolicy: dto.returnPolicy,
            minimumOrderQuantity: dto.minimumOrderQuantity,
            images: dto.images,
            thumbnail: dto.thumbnail
        )
    }

    static func mapToDomain(_ dtos: [ProductDTO]) -> [Product] {
        dtos.map { mapToDomain($0) }
    }

    static func extractCategories(from products: [Product]) -> [String] {
        Array(Set(products.map(\.category))).sorted()
    }

    private static func mapDimensions(_ dto: DimensionsDTO) -> Dimensions {
        Dimensions(width: dto.width, height: dto.height, depth: dto.depth)
    }

    private static func mapReview(_ dto: ReviewDTO) -> Review {
        Review(
            rating: dto.rating,
            comment: dto.comment,
            date: dto.date,
            reviewerName: dto.reviewerName,
            reviewerEmail: dto.reviewerEmail
        )
    }
}
