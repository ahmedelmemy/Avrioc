//
//  CachedAsyncImage.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Drop-in AsyncImage replacement backed by the two-layer image cache.
//

import SwiftUI

struct CachedAsyncImage<Content: View>: View {
    let url: URL?
    @ViewBuilder let content: (AsyncImagePhase) -> Content

    @State private var phase: AsyncImagePhase = .empty

    var body: some View {
        content(phase)
            // .task(id:) automatically cancels the previous task when `url` changes
            // or the view disappears, preventing stale images from appearing.
            .task(id: url) {
                await loadImage()
            }
    }

    private func loadImage() async {
        guard let url else {
            phase = .failure(URLError(.badURL))
            return
        }

        if let cached = await ImageCacheService.shared.image(for: url) {
            phase = .success(Image(uiImage: cached))
            return
        }

        // Reset to empty before network fetch to show a loading placeholder
        phase = .empty

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // Check cancellation after the network call returns — the view may have
            // disappeared while waiting, and we shouldn't update state for a dead view.
            try Task.checkCancellation()
            guard let uiImage = UIImage(data: data) else {
                phase = .failure(URLError(.cannotDecodeContentData))
                return
            }
            ImageCacheService.shared.store(data, image: uiImage, for: url)
            phase = .success(Image(uiImage: uiImage))
        } catch is CancellationError {
            // View disappeared
        } catch {
            phase = .failure(error)
        }
    }
}
