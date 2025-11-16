//
//  APIEndpoint.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 28.10.2025.
//

import Foundation

protocol APIEndpoint {
    var scheme: String { get }
    var host: String { get }
    var port: Int? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var contentType: ContentType { get }
}

extension APIEndpoint {
    var port: Int? { nil }
}

extension APIEndpoint {
    
    var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = path
        
        guard let url = components.url else {
            preconditionFailure("Unable to create url from: \(String(describing: components))")
        }
        
        return url
    }
    
    var request: URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue(contentType.headerValue, forHTTPHeaderField: "Content-Type")
        return request
    }
}
