//
//  RatingLabel.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Inline star icon with numeric rating value for product cards and rows.
//

import SwiftUI

/// Compact star icon + numeric rating display for product cards and rows.
struct RatingLabel: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: Strings.Icons.starFill)
                .font(.caption2)
                .foregroundStyle(AppColors.rating)
            Text(Strings.rating(rating))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
