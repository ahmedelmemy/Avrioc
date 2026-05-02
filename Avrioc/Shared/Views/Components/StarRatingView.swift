//
//  StarRatingView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Renders a 1-to-5 filled/empty star row for review ratings.
//

import SwiftUI

/// Displays 1-5 filled/empty stars for a given integer rating.
struct StarRatingView: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? Strings.Icons.starFill : Strings.Icons.star)
                    .font(.caption2)
                    .foregroundStyle(AppColors.rating)
            }
        }
    }
}
