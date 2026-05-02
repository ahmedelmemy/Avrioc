//
//  NetworkError.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Typed error cases for network layer failures with user-facing descriptions.
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return Strings.Error.invalidURL
        case .invalidResponse:
            return Strings.Error.invalidResponse
        case .httpError(let statusCode):
            return Strings.Error.httpError(statusCode: statusCode)
        case .decodingError:
            return Strings.Error.decodingError
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    // Equatable by case identity — wrapped Error values are not compared
    // because Error doesn't conform to Equatable. Sufficient for testing.
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.decodingError, .decodingError),
             (.unknown, .unknown):
            return true
        case (.httpError(let l), .httpError(let r)):
            return l == r
        default:
            return false
        }
    }
}
