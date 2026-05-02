//
//  OfflineBannerView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Warning banner indicating cached data is being shown with a retry option.
//

import SwiftUI

struct OfflineBannerView: View {
    let onRetry: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: Strings.Icons.wifiSlash)
            Text(Strings.showingCachedData)
            Spacer()
            Button(Strings.retry, action: onRetry)
                .font(.caption.bold())
        }
        .font(.caption)
        .padding(10)
        .background(AppColors.offlineBanner)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
        .padding(.bottom, 4)
    }
}
