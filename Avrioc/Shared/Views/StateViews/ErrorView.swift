//
//  ErrorView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Error state with message and retry action button.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(Strings.somethingWentWrong, systemImage: Strings.Icons.warning)
        } description: {
            Text(message)
        } actions: {
            Button(Strings.tryAgain, action: onRetry)
                .buttonStyle(.borderedProminent)
        }
    }
}
