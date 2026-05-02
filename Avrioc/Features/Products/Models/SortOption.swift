//
//  SortOption.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Presentation-level sort options with user-facing display names.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable, Sendable {
    case none
    case priceLowToHigh
    case priceHighToLow
    case ratingHighToLow
    case ratingLowToHigh

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return Strings.sortDefault
        case .priceLowToHigh: return Strings.sortPriceLow
        case .priceHighToLow: return Strings.sortPriceHigh
        case .ratingHighToLow: return Strings.sortRatingHigh
        case .ratingLowToHigh: return Strings.sortRatingLow
        }
    }
}
