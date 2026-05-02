//
//  MockHTTPClient.swift
//  AvriocTests
//
//  Created by Ahmed Elmemy on 02/05/2026.
//
//  Configurable HTTP client mock for testing repository logic.
//

import Foundation
import Combine
@testable import Avrioc

final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var result: Result<Any, NetworkError> = .failure(.invalidResponse)

    func request<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError> {
        switch result {
        case .success(let value):
            guard let typed = value as? T else {
                return Fail(error: .invalidResponse).eraseToAnyPublisher()
            }
            return Just(typed)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
