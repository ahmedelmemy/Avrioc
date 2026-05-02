//
//  ImageCacheService.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Two-layer image cache (NSCache in-memory + disk) with SHA256-based file keys.
//

import SwiftUI
import CryptoKit

final class ImageCacheService: @unchecked Sendable {
    static let shared = ImageCacheService()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let cacheDirectory: URL
    private let ioQueue = DispatchQueue(label: "ImageCacheService.io", qos: .utility)

    private init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = caches.appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        memoryCache.countLimit = 100
    }

    // MARK: - Sync (memory only — safe to call from main thread)

    /// Returns nil if not in memory. Used by ImageCarouselView for a quick
    /// thumbnail fallback without blocking the UI thread with disk I/O.
    func cachedImage(for url: URL) -> UIImage? {
        memoryCache.object(forKey: cacheKey(for: url) as NSString)
    }

    // MARK: - Async (memory + disk, two-layer lookup)

    func image(for url: URL) async -> UIImage? {
        let key = cacheKey(for: url)

        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }

        return await withCheckedContinuation { continuation in
            ioQueue.async { [weak self] in
                guard let self else {
                    continuation.resume(returning: nil)
                    return
                }
                let filePath = self.diskPath(for: key)
                if let data = try? Data(contentsOf: filePath), let image = UIImage(data: data) {
                    self.memoryCache.setObject(image, forKey: key as NSString)
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    /// Stores the original downloaded bytes (not re-encoded UIImage data) to disk
    /// to preserve format fidelity (e.g., PNG transparency, JPEG compression level).
    func store(_ data: Data, image: UIImage, for url: URL) {
        let key = cacheKey(for: url)
        memoryCache.setObject(image, forKey: key as NSString)
        let filePath = diskPath(for: key)
        ioQueue.async {
            try? data.write(to: filePath)
        }
    }

    // MARK: - Private

    /// SHA256 hash produces a fixed-length, filesystem-safe filename from any URL.
    private func cacheKey(for url: URL) -> String {
        SHA256.hash(data: Data(url.absoluteString.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private func diskPath(for key: String) -> URL {
        cacheDirectory.appendingPathComponent(key)
    }
}
