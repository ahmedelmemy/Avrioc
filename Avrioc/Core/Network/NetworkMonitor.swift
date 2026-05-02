//
//  NetworkMonitor.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Observes network reachability via NWPathMonitor and publishes connectivity changes.
//

import Foundation
import Network
import Combine

final class NetworkMonitor: ObservableObject, @unchecked Sendable {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        // NWPathMonitor callbacks arrive on a background queue; dispatch to main
        // because @Published must be updated on the main thread for SwiftUI/Combine.
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
