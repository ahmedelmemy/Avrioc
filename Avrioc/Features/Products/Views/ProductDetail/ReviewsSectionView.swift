//
//  ReviewsSectionView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Displays a list of user reviews with star ratings and comments.
//

import SwiftUI

struct ReviewsSectionView: View {
    let reviews: [Review]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.reviews(count: reviews.count))
                .font(.headline)

            ForEach(reviews) { review in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(review.reviewerName)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Spacer()

                        StarRatingView(rating: review.rating)
                    }

                    Text(review.comment)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .sectionCard(cornerRadius: 8)
            }
        }
    }
}
