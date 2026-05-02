//
//  Strings+Errors.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  User-facing error message strings for network failures.
//

import Foundation

extension Strings {
    enum Error {
        static let invalidURL = "Invalid URL"
        static let invalidResponse = "Invalid server response"
        static func httpError(statusCode: Int) -> String { "Server error (status: \(statusCode))" }
        static let decodingError = "Failed to process server data"
    }
}
