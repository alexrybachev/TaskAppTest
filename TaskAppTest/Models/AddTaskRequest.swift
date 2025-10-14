//
//  AddTaskRequest.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 13.10.2025.
//

/// Модель для lдобавления задачи на сервере
struct AddTaskRequest: Codable {
    let name: String
    let completed: Bool
    let photoBase64: String?
    let date: String
    
    init(from task: TaskModel) {
        self.name = task.name
        self.completed = task.completed
        self.photoBase64 = task.photoBase64
        self.date = task.date
    }
}
