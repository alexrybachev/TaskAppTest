//
//  ContentType.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 28.10.2025.
//

enum ContentType {
    case json
    
    var headerValue: String {
        "application/json"
    }
}
