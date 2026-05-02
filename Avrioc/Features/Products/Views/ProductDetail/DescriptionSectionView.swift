//
//  DescriptionSectionView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Simple section displaying the product description text.
//

import SwiftUI

struct DescriptionSectionView: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.description)
                .font(.headline)
            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
