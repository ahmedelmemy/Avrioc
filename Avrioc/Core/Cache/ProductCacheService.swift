//
//  ProductCacheService.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Thread-safe disk cache for product responses with incremental page merging.
//

import Foundation

protocol ProductCacheServiceProtocol: Sendable {
    func save(_ response: ProductResponseDTO, isFirstPage: Bool)
    func load() -> ProductResponseDTO?
    func clear()
}

/// @unchecked Sendable: thread safety is guaranteed by routing all disk I/O
/// through a serial DispatchQueue, not by Swift's built-in checking.
final class ProductCacheService: ProductCacheServiceProtocol, @unchecked Sendable {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    /// Serial queue ensures atomic read-modify-write during page merges.
    private let ioQueue = DispatchQueue(label: "ProductCacheService.io")

    init(fileName: String = "cached_products.json") {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.fileURL = caches.appendingPathComponent(fileName)
    }

    /// Saves are async (non-blocking) to avoid stalling the caller.
    /// First-page saves replace the entire cache; subsequent pages are merged
    /// with deduplication to support incremental pagination caching.
    func save(_ response: ProductResponseDTO, isFirstPage: Bool) {
        ioQueue.async { [self] in
            let merged: ProductResponseDTO
            if isFirstPage {
                merged = response
            } else if let existing = readFromDisk() {
                // Deduplicate by ID to handle overlapping pages or retries
                let existingIDs = Set(existing.products.map(\.id))
                let newProducts = response.products.filter { !existingIDs.contains($0.id) }
                merged = ProductResponseDTO(
                    products: existing.products + newProducts,
                    total: response.total,
                    skip: 0,
                    limit: existing.products.count + newProducts.count
                )
            } else {
                merged = response
            }

            if let data = try? encoder.encode(merged) {
                try? data.write(to: fileURL, options: .atomic)
            }
        }
    }

    /// Synchronous load — blocks the caller until the read completes.
    /// This is intentional: cache fallback in the repository must return data
    /// within the same Combine pipeline synchronously.
    func load() -> ProductResponseDTO? {
        ioQueue.sync { readFromDisk() }
    }

    func clear() {
        ioQueue.sync {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    private func readFromDisk() -> ProductResponseDTO? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? decoder.decode(ProductResponseDTO.self, from: data)
    }
}
