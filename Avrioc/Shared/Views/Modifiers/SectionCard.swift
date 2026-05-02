//
//  SectionCard.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  View modifier for padded, rounded card sections on detail screens.
//

import SwiftUI

/// Consistent card styling for detail page sections (price, details, review items).
struct SectionCard: ViewModifier {
    var cornerRadius: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppColors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func sectionCard(cornerRadius: CGFloat = 12) -> some View {
        modifier(SectionCard(cornerRadius: cornerRadius))
    }
}
