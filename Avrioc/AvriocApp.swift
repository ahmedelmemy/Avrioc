//
//  AvriocApp.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  App entry point. Initializes the dependency container and launches the root view.
//

import SwiftUI

@main
struct AvriocApp: App {
    private let container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
