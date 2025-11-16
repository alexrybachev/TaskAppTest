//
//  HTTPClient.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 28.10.2025.
//

import Foundation
import Combine

final class HTTPClient {
    
    private let configuration = URLSessionConfiguration.default
    private let session: URLSession
    
    init() {
        session = URLSession(configuration: configuration)
    }
    
    func request<T: Decodable>(endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError> {
        guard let request = endpoint.request else {
            return Fail(error: NetworkError.buildRequestError)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap(parceResponse)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { NetworkError.serverError($0.localizedDescription) }
            .eraseToAnyPublisher()
    }
    
    func post<T: Encodable, U: Decodable>(endpoint: APIEndpoint, body: T) -> AnyPublisher<U, NetworkError> {
        guard var request = endpoint.request else {
            return Fail(error: NetworkError.buildRequestError)
                .eraseToAnyPublisher()
        }
        
        guard let jsonData = try? JSONEncoder().encode(body) else {
            return Fail(error: NetworkError.encodingError)
                .eraseToAnyPublisher()
        }
        request.httpBody = jsonData
        
        return session.dataTaskPublisher(for: request)
            .tryMap(parceResponse)
            .decode(type: U.self, decoder: JSONDecoder())
            .mapError { NetworkError.serverError($0.localizedDescription) }
            .catch { error -> AnyPublisher<U, NetworkError> in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Extensions

private extension HTTPClient {
    
    func parceResponse(_ data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else { throw NetworkError.invalidResponse }
        return data
    }
}
