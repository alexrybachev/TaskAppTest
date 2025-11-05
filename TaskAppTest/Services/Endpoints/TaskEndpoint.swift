//
//  TaskEndpoint.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 28.10.2025.
//

enum TaskEndpoint {
    case getTasks
    case addTask
    case updateTask
}

extension TaskEndpoint: APIEndpoint {
    
    var scheme: String {
        Constants.scheme
    }
    
    var host: String {
        Constants.baseURL
    }
    
    var port: Int? {
        Constants.port
    }
    
    var path: String {
        switch self {
        case .getTasks: "/api/getTasks"
        case .addTask: "/api/addTask"
        case .updateTask: "/api/updateTask"
        }
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var contentType: ContentType {
        .json
    }
    
}
