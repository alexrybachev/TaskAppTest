//
//  StorageService.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 11.10.2025.
//

import Foundation

protocol LocalStorageServiceProtocol {
    func loadInitialData() -> [TaskModel]
    
//    func saveTask(_ task: TaskModel)
    func saveTasks(_ tasks: [TaskModel])
    func updateTask(_ task: TaskModel)
    func loadTasks() -> [TaskModel]
    
    func saveDeferredTask(_ task: TaskModel)
    func saveDeferredTasks(_ tasks: [TaskModel])
    func updateDeferedTask(_ task: TaskModel)
    func getDeferredTasks() -> [TaskModel]
    func clearDeferredTasks()
}

final class LocalStorageService: LocalStorageServiceProtocol {
    
    private let syncedTasksKey = "saved_tasks"
    private let deferredTasksKey = "deferred_tasks"
    
    // MARK: - Saved tasks
    
//    func saveTask(_ task: TaskModel) {
//        var cachedData = loadTasks()
//        cachedData.append(task)
//        saveTasks(cachedData)
//    }
    
    func loadInitialData() -> [TaskModel] {
        let savedTasks = loadTasks()
        let defferedTasks = getDeferredTasks()
        return savedTasks + defferedTasks
    }
    
    func saveTasks(_ tasks: [TaskModel]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: syncedTasksKey)
        }
    }
    
    func updateTask(_ task: TaskModel) {
        var cachedData = loadTasks()
        if let updateTaskIndex = cachedData.firstIndex(where: { $0.id == task.id }) {
            cachedData[updateTaskIndex] = task
        } else {
            cachedData.append(task)
        }
        saveTasks(cachedData)
    }
    
    func loadTasks() -> [TaskModel] {
        guard let data = UserDefaults.standard.data(forKey: syncedTasksKey),
              let tasks = try? JSONDecoder().decode([TaskModel].self, from: data) else {
            return []
        }
        return tasks
    }
    
    // MARK: - Deferred tasks
    
    func saveDeferredTask(_ task: TaskModel) {
        var defferedTasks = getDeferredTasks()
        defferedTasks.append(task)
        saveTasks(defferedTasks)
        print("🧹 Saved one deffered task")
    }
    
    func saveDeferredTasks(_ tasks: [TaskModel]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: deferredTasksKey)
            print("🧹 Saved all deffered tasks")
        }
    }
    
    func updateDeferedTask(_ task: TaskModel) {
        var savedTasks = getDeferredTasks()
        if let updatedTaskIndex = savedTasks.firstIndex(where: { $0.id == task.id }) {
            savedTasks[updatedTaskIndex].name = task.name
            savedTasks[updatedTaskIndex].completed = task.completed
            if task.photoBase64 != nil {
                savedTasks[updatedTaskIndex].photoBase64 = task.photoBase64
            }
        }
        saveDeferredTasks(savedTasks)
        print("🧹 Updated deffered tasks")
    }
    
    func getDeferredTasks() -> [TaskModel] {
        guard let data = UserDefaults.standard.data(forKey: deferredTasksKey),
              let tasks = try? JSONDecoder().decode([TaskModel].self, from: data) else {
            return []
        }
        print("🧹 Get deffered tasks")
        return tasks
    }
    
    func clearDeferredTasks() {
        UserDefaults.standard.removeObject(forKey: deferredTasksKey)
        print("🧹 Cleared all deffered tasks")
    }
}

//extension LocalStorageService {
//    
//    func saveDeferredTasks(_ tasks: [TaskModel]) {
//        // Очищаем текущие и сохраняем новые
//        clearDeferredTasks()
//        tasks.forEach { saveDeferredTask($0) }
//    }
//    
//    func updateDeferedTask(_ task: TaskModel) {
//        var deferredTasks = getDeferredTasks()
//        
//        // Удаляем старую версию задачи если есть
//        deferredTasks.removeAll { $0.id == task.id }
//        
//        // Добавляем обновленную версию
//        deferredTasks.append(task)
//        
//        // Сохраняем обратно
//        saveDeferredTasks(deferredTasks)
//    }
//}
