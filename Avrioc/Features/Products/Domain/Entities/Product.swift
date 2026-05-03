//
//  Product.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Domain models for products, dimensions, and reviews.
//

import Foundation

struct Product: Identifiable, Hashable, Sendable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Double
    let discountPercentage: Double
    let discountedPrice: Double
    let rating: Double
    let stock: Int
    let tags: [String]
    let brand: String?
    let sku: String
    let weight: Int
    let dimensions: Dimensions
    let warrantyInformation: String
    let shippingInformation: String
    let availabilityStatus: String
    let reviews: [Review]
    let returnPolicy: String
    let minimumOrderQuantity: Int
    let images: [String]
    let thumbnail: String

    // API contract value — domain logic, not a UI string.
    private static let inStockStatus = "In Stock"
    var isInStock: Bool { availabilityStatus == Self.inStockStatus }

    // Identity-based equality — two Products with the same id are considered equal
    // regardless of other fields. This enables efficient diffing in SwiftUI lists
    // and prevents unnecessary view updates when non-displayed fields change.
    static func == (lhs: Product, rhs: Product) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Dimensions: Hashable, Sendable {
    let width: Double
    let height: Double
    let depth: Double
}

struct Review: Identifiable, Hashable, Sendable {
    let rating: Int
    let comment: String
    let date: String
    let reviewerName: String
    let reviewerEmail: String

    // Deterministic composite key — reviewerEmail + date is unique per review
    var id: String { "\(reviewerEmail)-\(date)" }
}
