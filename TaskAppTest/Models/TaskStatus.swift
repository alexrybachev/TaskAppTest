//
//  TaskStatus.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 28.10.2025.
//

import CoreData

/// Статус задачи для разделения
enum TaskStatus: String {
    case server
    case update
    case new
    
    var stringValue: String {
        switch self {
        case .server: return "server"
        case .update: return "update"
        case .new: return "new"
        }
    }
    
    static func from(string: String) -> TaskStatus {
        switch string {
        case "server": return .server
        case "update": return .update
        case "new": return .new
        default: return .new
        }
    }
}

// MARK: - Extensions

extension TaskEntity {   
    var status: TaskStatus {
        get {
            guard let string = statusString else { return .new }
            return TaskStatus.from(string: string)
        }
        
        set {
            statusString = newValue.stringValue
        }
    }
}
