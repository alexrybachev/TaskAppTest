//
//  APIEndpoint.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 28.10.2025.
//

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
