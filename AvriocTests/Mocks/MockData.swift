//
//  MockData.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Factory methods with sensible defaults for Product, ProductDTO, and sample fixtures.
//

import Foundation
@testable import Avrioc

enum MockData {

    // MARK: - Product Factory

    static func makeProduct(
        id: Int = 1,
        title: String = "Test Product",
        description: String = "A test product",
        category: String = "test",
        price: Double = 10.0,
        discountPercentage: Double = 0,
        discountedPrice: Double? = nil,
        rating: Double = 4.0,
        stock: Int = 10,
        tags: [String] = [],
        brand: String? = nil,
        sku: String = "TST",
        weight: Int = 1,
        dimensions: Dimensions = Dimensions(width: 1, height: 1, depth: 1),
        warrantyInformation: String = "",
        shippingInformation: String = "",
        availabilityStatus: String = "In Stock",
        reviews: [Review] = [],
        returnPolicy: String = "",
        minimumOrderQuantity: Int = 1,
        images: [String] = [],
        thumbnail: String = ""
    ) -> Product {
        Product(
            id: id,
            title: title,
            description: description,
            category: category,
            price: price,
            discountPercentage: discountPercentage,
            discountedPrice: discountedPrice ?? price * (1 - discountPercentage / 100),
            rating: rating,
            stock: stock,
            tags: tags,
            brand: brand,
            sku: sku,
            weight: weight,
            dimensions: dimensions,
            warrantyInformation: warrantyInformation,
            shippingInformation: shippingInformation,
            availabilityStatus: availabilityStatus,
            reviews: reviews,
            returnPolicy: returnPolicy,
            minimumOrderQuantity: minimumOrderQuantity,
            images: images,
            thumbnail: thumbnail
        )
    }

    // MARK: - ProductDTO Factory

    static func makeProductDTO(
        id: Int = 1,
        title: String = "Test Product",
        description: String = "",
        category: String = "test",
        price: Double = 10.0,
        discountPercentage: Double = 0,
        rating: Double = 4.0,
        stock: Int = 10,
        tags: [String] = [],
        brand: String? = nil,
        sku: String = "TST",
        weight: Int = 1,
        dimensions: DimensionsDTO = DimensionsDTO(width: 1, height: 1, depth: 1),
        warrantyInformation: String = "",
        shippingInformation: String = "",
        availabilityStatus: String = "In Stock",
        reviews: [ReviewDTO] = [],
        returnPolicy: String = "",
        minimumOrderQuantity: Int = 1,
        images: [String] = [],
        thumbnail: String = ""
    ) -> ProductDTO {
        ProductDTO(
            id: id,
            title: title,
            description: description,
            category: category,
            price: price,
            discountPercentage: discountPercentage,
            rating: rating,
            stock: stock,
            tags: tags,
            brand: brand,
            sku: sku,
            weight: weight,
            dimensions: dimensions,
            warrantyInformation: warrantyInformation,
            shippingInformation: shippingInformation,
            availabilityStatus: availabilityStatus,
            reviews: reviews,
            returnPolicy: returnPolicy,
            minimumOrderQuantity: minimumOrderQuantity,
            images: images,
            thumbnail: thumbnail
        )
    }

    // MARK: - Fixtures

    static func sampleProducts() -> [Product] {
        [
            makeProduct(
                id: 1,
                title: "Test Phone",
                description: "A test smartphone",
                category: "smartphones",
                price: 999.99,
                discountPercentage: 10.0,
                rating: 4.5,
                stock: 50,
                tags: ["electronics", "phone"],
                brand: "TestBrand",
                sku: "TST-001",
                weight: 5,
                dimensions: Dimensions(width: 10, height: 20, depth: 1),
                warrantyInformation: "1 year warranty",
                shippingInformation: "Ships in 1 week",
                reviews: [
                    Review(rating: 5, comment: "Great!", date: "2025-01-01", reviewerName: "Ahmed Elmemy", reviewerEmail: "ahmedelmemy@test.com"),
                    Review(rating: 4, comment: "Good", date: "2025-01-02", reviewerName: "Ahmed E.", reviewerEmail: "ahmed.e@test.com")
                ],
                returnPolicy: "30 days return policy",
                images: ["https://example.com/phone.jpg"],
                thumbnail: "https://example.com/phone_thumb.jpg"
            ),
            makeProduct(
                id: 2,
                title: "Test Laptop",
                description: "A test laptop computer",
                category: "laptops",
                price: 1499.99,
                discountPercentage: 5.0,
                rating: 4.2,
                stock: 30,
                tags: ["electronics", "laptop"],
                brand: "LaptopBrand",
                sku: "TST-002",
                weight: 10,
                dimensions: Dimensions(width: 30, height: 20, depth: 2),
                warrantyInformation: "2 year warranty",
                shippingInformation: "Ships in 3 days",
                reviews: [
                    Review(rating: 3, comment: "OK", date: "2025-01-03", reviewerName: "Ahmed Elmemy", reviewerEmail: "ahmedelmemy2@test.com")
                ],
                returnPolicy: "14 days return policy",
                images: ["https://example.com/laptop.jpg"],
                thumbnail: "https://example.com/laptop_thumb.jpg"
            ),
            makeProduct(
                id: 3,
                title: "Red Lipstick",
                description: "A beautiful red lipstick",
                category: "beauty",
                price: 12.99,
                rating: 4.8,
                stock: 100,
                tags: ["beauty", "lipstick"],
                brand: "BeautyBrand",
                sku: "TST-003",
                dimensions: Dimensions(width: 2, height: 10, depth: 2),
                warrantyInformation: "No warranty",
                shippingInformation: "Ships overnight",
                reviews: [],
                returnPolicy: "No return policy",
                images: ["https://example.com/lipstick.jpg"],
                thumbnail: "https://example.com/lipstick_thumb.jpg"
            )
        ]
    }

    static func sampleProductDTOs() -> [ProductDTO] {
        [
            makeProductDTO(
                id: 1,
                title: "Mascara",
                description: "A volumizing mascara",
                category: "beauty",
                price: 9.99,
                discountPercentage: 10.0,
                rating: 4.5,
                stock: 99,
                tags: ["beauty", "mascara"],
                brand: "Essence",
                sku: "BEA-001",
                weight: 4,
                dimensions: DimensionsDTO(width: 15, height: 13, depth: 23),
                warrantyInformation: "1 week warranty",
                shippingInformation: "Ships in 3-5 days",
                reviews: [
                    ReviewDTO(rating: 5, comment: "Great!", date: "2025-01-01", reviewerName: "Ahmed Elmemy", reviewerEmail: "ahmedelmemy@test.com")
                ],
                returnPolicy: "No return policy",
                minimumOrderQuantity: 48,
                images: ["https://example.com/mascara.jpg"],
                thumbnail: "https://example.com/mascara_thumb.jpg"
            )
        ]
    }
}
