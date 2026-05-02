//
//  ProductDTO.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Codable DTOs matching the DummyJSON products API response shape.
//

import Foundation

struct ProductResponseDTO: Codable, Sendable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

struct ProductDTO: Codable, Sendable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let tags: [String]
    let brand: String?
    let sku: String
    let weight: Int
    let dimensions: DimensionsDTO
    let warrantyInformation: String
    let shippingInformation: String
    let availabilityStatus: String
    let reviews: [ReviewDTO]
    let returnPolicy: String
    let minimumOrderQuantity: Int
    let images: [String]
    let thumbnail: String
}

struct DimensionsDTO: Codable, Sendable {
    let width: Double
    let height: Double
    let depth: Double
}

struct ReviewDTO: Codable, Sendable {
    let rating: Int
    let comment: String
    let date: String
    let reviewerName: String
    let reviewerEmail: String
}
