//
//  ImageCarouselView.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Swipeable image carousel with cached thumbnail fallback on load failure.
//

import SwiftUI

struct ImageCarouselView: View {
    let images: [String]
    let thumbnail: String

    var body: some View {
        TabView {
            ForEach(images, id: \.self) { imageURL in
                CachedAsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        // Fall back to the already-cached thumbnail (memory only, no disk I/O)
                        // so the user sees a low-res image instead of a broken icon.
                        if let thumbURL = URL(string: thumbnail),
                           let cached = ImageCacheService.shared.cachedImage(for: thumbURL) {
                            Image(uiImage: cached)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Image(systemName: Strings.Icons.photo)
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        }
                    case .empty:
                        ProgressView()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
        .tabViewStyle(.page)
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .background(AppColors.secondaryBackground.clipShape(RoundedRectangle(cornerRadius: 12)))
    }
}
