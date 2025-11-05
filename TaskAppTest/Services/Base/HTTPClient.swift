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
        guard let request = buildURLRequest(endpoint: endpoint) else {
            return Fail(error: NetworkError.buildRequestError)
                .eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200..<300:
                    return data
                default:
                    throw NetworkError.serverError(httpResponse.statusCode.description)
                }
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? NetworkError {
                    return apiError
                } else {
                    return NetworkError.serverError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func post<T: Encodable, U: Decodable>(endpoint: APIEndpoint, body: T) -> AnyPublisher<U, NetworkError> {
        guard var request = buildURLRequest(endpoint: endpoint) else {
            return Fail(error: NetworkError.buildRequestError)
                .eraseToAnyPublisher()
        }
        
        guard let jsonData = try? JSONEncoder().encode(body) else {
            return Fail(error: NetworkError.encodingError)
                .eraseToAnyPublisher()
        }
        request.httpBody = jsonData
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200..<300: return data
                default: throw NetworkError.serverError(httpResponse.statusCode.description)
                }
            }
            .decode(type: U.self, decoder: JSONDecoder())
            .mapError { error in
                if let apiError = error as? NetworkError {
                    return apiError
                } else {
                    return NetworkError.serverError(error.localizedDescription)
                }
            }
            .catch { error -> AnyPublisher<U, NetworkError> in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - URLRequest

private extension HTTPClient {
    
    func buildURLRequest(endpoint: APIEndpoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.host
        components.port = endpoint.port
        components.path = endpoint.path
        guard let url = components.url else {
            print("❌ HTTPClient -> Error build url")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.addValue(endpoint.contentType.headerValue, forHTTPHeaderField: "Content-Type")
        return request
    }
}
