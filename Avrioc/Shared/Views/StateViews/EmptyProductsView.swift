//
//  EmptyProductsView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Placeholder shown when the product list is empty.
//

import SwiftUI

struct EmptyProductsView: View {
    var body: some View {
        ContentUnavailableView(
            Strings.noProducts,
            systemImage: Strings.Icons.bag,
            description: Text(Strings.noProductsDescription)
        )
    }
}
