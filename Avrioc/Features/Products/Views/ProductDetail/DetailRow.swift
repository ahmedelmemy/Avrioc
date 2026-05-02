//
//  DetailRow.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Reusable label-value row for the product details section.
//

import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(value)
                .font(.subheadline)
        }
    }
}
