//
//  URL+ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 07.11.2025.
//

import Foundation

extension URLRequest {
    
    func buildURLRequest(endpoint: APIEndpoint) -> Self? {
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
