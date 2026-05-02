//
//  ProductMapperTests.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Tests for DTO-to-domain mapping, discount calculation, and category extraction.
//

import XCTest
@testable import Avrioc

final class ProductMapperTests: XCTestCase {

    // MARK: - Single Product Mapping

    /// Verifies all DTO fields are correctly transferred to the domain model.
    func testMapDTOToDomain() {
        let dto = MockData.sampleProductDTOs()[0]
        let product = ProductMapper.mapToDomain(dto)

        XCTAssertEqual(product.id, dto.id)
        XCTAssertEqual(product.title, dto.title)
        XCTAssertEqual(product.description, dto.description)
        XCTAssertEqual(product.category, dto.category)
        XCTAssertEqual(product.price, dto.price)
        XCTAssertEqual(product.rating, dto.rating)
        XCTAssertEqual(product.brand, dto.brand)
        XCTAssertEqual(product.images, dto.images)
        XCTAssertEqual(product.thumbnail, dto.thumbnail)
    }

    /// Verifies discountedPrice is pre-computed as price * (1 - discount/100).
    func testDiscountedPriceCalculation() {
        let dto = MockData.makeProductDTO(price: 100.0, discountPercentage: 25.0)
        let product = ProductMapper.mapToDomain(dto)

        XCTAssertEqual(product.discountedPrice, 75.0, accuracy: 0.01)
    }

    /// Verifies zero discount keeps the original price unchanged.
    func testZeroDiscountKeepsOriginalPrice() {
        let dto = MockData.makeProductDTO(price: 49.99, discountPercentage: 0)
        let product = ProductMapper.mapToDomain(dto)

        XCTAssertEqual(product.discountedPrice, 49.99, accuracy: 0.01)
    }

    // MARK: - Dimensions Mapping

    /// Verifies DimensionsDTO fields map correctly to Dimensions domain model.
    func testDimensionsMapping() {
        let dto = MockData.makeProductDTO(
            dimensions: DimensionsDTO(width: 15, height: 13, depth: 23)
        )
        let product = ProductMapper.mapToDomain(dto)

        XCTAssertEqual(product.dimensions.width, 15)
        XCTAssertEqual(product.dimensions.height, 13)
        XCTAssertEqual(product.dimensions.depth, 23)
    }

    // MARK: - Reviews Mapping

    /// Verifies ReviewDTO array is mapped to Review domain models with correct fields.
    func testReviewsMapping() {
        let reviews = [
            ReviewDTO(rating: 5, comment: "Great!", date: "2025-01-01", reviewerName: "Ahmed Elmemy", reviewerEmail: "ahmedelmemy@test.com"),
            ReviewDTO(rating: 3, comment: "OK", date: "2025-01-02", reviewerName: "Ahmed E.", reviewerEmail: "ahmed.e@test.com")
        ]
        let dto = MockData.makeProductDTO(reviews: reviews)
        let product = ProductMapper.mapToDomain(dto)

        XCTAssertEqual(product.reviews.count, 2)
        XCTAssertEqual(product.reviews.first?.reviewerName, "Ahmed Elmemy")
        XCTAssertEqual(product.reviews.first?.rating, 5)
        XCTAssertEqual(product.reviews.last?.comment, "OK")
    }

    // MARK: - Batch Mapping

    /// Verifies batch mapping converts an array of DTOs preserving order and count.
    func testMapMultipleDTOs() {
        let dtos = [
            MockData.makeProductDTO(id: 1),
            MockData.makeProductDTO(id: 2),
            MockData.makeProductDTO(id: 3)
        ]
        let products = ProductMapper.mapToDomain(dtos)

        XCTAssertEqual(products.count, 3)
        XCTAssertEqual(products.map(\.id), [1, 2, 3])
    }

    // MARK: - Category Extraction

    /// Verifies categories are extracted, deduplicated, and sorted alphabetically.
    func testExtractCategories() {
        let products = MockData.sampleProducts()
        let categories = ProductMapper.extractCategories(from: products)

        XCTAssertEqual(categories, ["beauty", "laptops", "smartphones"])
    }

    /// Verifies duplicate categories from repeated products are removed.
    func testExtractCategoriesRemovesDuplicates() {
        var products = MockData.sampleProducts()
        products.append(products[0])
        let categories = ProductMapper.extractCategories(from: products)

        XCTAssertEqual(categories.count, 3)
    }

    /// Verifies extracting categories from an empty list returns an empty array.
    func testExtractCategoriesFromEmptyList() {
        XCTAssertTrue(ProductMapper.extractCategories(from: []).isEmpty)
    }

    // MARK: - Optional Brand

    /// Verifies nil brand in DTO maps to nil brand in domain model.
    func testNilBrandMapping() {
        let dto = MockData.makeProductDTO(brand: nil)
        let product = ProductMapper.mapToDomain(dto)

        XCTAssertNil(product.brand)
    }
}
