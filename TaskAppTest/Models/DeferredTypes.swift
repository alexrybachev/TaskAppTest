//
//  DeferredTypes.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 14.10.2025.
//

import Foundation

/// Тип для кеширования с дальнейшей синхронизацией
enum DeferredOperationType: String, Codable {
    case add
    case update
}

struct DeferredType: Codable {
    let id: String
    let type: DeferredOperationType
    let task: TaskModel
    
    init(type: DeferredOperationType, task: TaskModel) {
        self.id = UUID().uuidString
        self.type = type
        self.task = task
    }
}
