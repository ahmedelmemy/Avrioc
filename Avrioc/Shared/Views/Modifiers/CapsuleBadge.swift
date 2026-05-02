//
//  CapsuleBadge.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  View modifier for consistent capsule-shaped badge styling across the app.
//

import SwiftUI

/// Reusable capsule badge styling used across category tags, discount labels,
/// stock indicators, and product tags. Normalizes padding for visual consistency.
struct CapsuleBadge: ViewModifier {
    var foreground: Color = .primary
    var background: Color = AppColors.accentLight

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(Capsule())
    }
}

extension View {
    func capsuleBadge(foreground: Color = .primary, background: Color = AppColors.accentLight) -> some View {
        modifier(CapsuleBadge(foreground: foreground, background: background))
    }
}
