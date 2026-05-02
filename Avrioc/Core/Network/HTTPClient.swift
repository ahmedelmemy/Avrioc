//
//  HTTPClient.swift
//  Avrioc
//
//  Created by Ahmed Elmemy on 01/05/2026.
//
//  Generic Combine-based HTTP client that decodes JSON responses into typed models.
//

import Foundation
import Combine

protocol HTTPClientProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError>
}

final class HTTPClient: HTTPClientProtocol, @unchecked Sendable {
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError> {
        guard let urlRequest = endpoint.urlRequest else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let http = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                guard (200...299).contains(http.statusCode) else {
                    throw NetworkError.httpError(statusCode: http.statusCode)
                }
                return data
            }
            .decode(type: T.self, decoder: decoder)
            // Map untyped errors from tryMap/decode into our typed NetworkError enum.
            // NetworkErrors thrown in tryMap pass through; DecodingErrors from .decode()
            // and URLErrors from dataTaskPublisher are wrapped accordingly.
            .mapError { error in
                switch error {
                case let networkError as NetworkError:
                    return networkError
                case is DecodingError:
                    return .decodingError(error)
                default:
                    return .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
