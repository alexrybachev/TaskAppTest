//
//  UpdateTaskRequest.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 13.10.2025.
//

import Foundation

/// Модель для обновления задачи на сервере
struct UpdateTaskRequest: Encodable {
    let id: String
    let name: String
    let completed: Bool
    let photoBase64: String?
    
    init(from task: TaskModel) {
        self.id = task.id
        self.name = task.name
        self.completed = task.completed
        self.photoBase64 = task.photoBase64
    }
}
