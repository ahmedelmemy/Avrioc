//
//  APIEndpoint.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Defines API routes and constructs URLs for network requests.
//

import Foundation

enum APIEndpoint {
    case products(limit: Int, skip: Int)

    private var baseURL: String { "https://dummyjson.com" }

    // Produces a URLRequest instead of bare URL so the endpoint can specify
    // HTTP method, headers, and body for future non-GET routes.
    var urlRequest: URLRequest? {
        guard let url else { return nil }
        return URLRequest(url: url)
    }

    var url: URL? {
        switch self {
        case .products(let limit, let skip):
            var components = URLComponents(string: "\(baseURL)/products")
            components?.queryItems = [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "skip", value: "\(skip)")
            ]
            return components?.url
        }
    }
}
