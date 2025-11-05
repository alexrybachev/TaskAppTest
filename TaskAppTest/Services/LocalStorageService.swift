//
//  StorageService.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 11.10.2025.
//

import Foundation
import CoreData

protocol LocalStorageServiceProtocol {
    func getTasksFromCoreData(with status: TaskStatus?) -> [TaskModel]
    func saveNewTaskToCoreData(_ task: TaskModel, with status: TaskStatus)
    func updateTaskToCoreData(_ task: TaskModel, with status: TaskStatus)
    
    func updateTasksOnCoreData(with status: TaskStatus)
    func deleteTasksFromCoreData(with status: TaskStatus)
    func loadTaskFromServerToCoreData(for tasks: [TaskModel])
}

final class LocalStorageService {
    
    private let containerId = "TaskEntity"
    private let persintentContainer: NSPersistentContainer
    
    private var context: NSManagedObjectContext {
        persintentContainer.viewContext
    }
    
    // MARK: - Initial
    
    init() {
        persintentContainer = NSPersistentContainer(name: containerId)
        persintentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Loading core data error \(error), \(error.userInfo)")
            }
        })
    }
}

// MARK: - LocalStorageServiceProtocol

extension LocalStorageService: LocalStorageServiceProtocol {
    
    /// Метод для получения задач из CoreData с определенным статусом `TaskStatus`. Если параметр status == nil, то выгрузятся все задачи
    func getTasksFromCoreData(with status: TaskStatus?) -> [TaskModel] {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        if let status = status {
            fetchRequest.predicate = NSPredicate(format: "statusString == %@", status.stringValue)
        }
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let taskEntity = try context.fetch(fetchRequest)
            return taskEntity.map { TaskModel(
                id: $0.id ?? "",
                name: $0.name ?? "",
                completed: $0.completed,
                photoBase64: $0.photoBase64,
                date: $0.date ?? ""
            )}
        } catch {
            print("▶️ Error fetching tasks: \(error)")
            return []
        }
    }
    
    /// Метод для сохранения задачи в CoreData
    func saveNewTaskToCoreData(_ task: TaskModel, with status: TaskStatus) {
        guard !taskExists(with: task.id) else {
            print("▶️ Task with date \(task.id) already exists.")
            updateTaskToCoreData(task, with: status)
            return
        }
        
        let taskEntity = TaskEntity(context: context)
        switch status {
        case .new:
            let maxId = maxId() + 1
            taskEntity.id = String(maxId)
        default:
            taskEntity.id = task.id
        }
        taskEntity.name = task.name
        taskEntity.completed = task.completed
        taskEntity.photoBase64 = task.photoBase64
        taskEntity.date = task.date
        taskEntity.statusString = status.stringValue

        do {
            try context.save()
            print("▶️ Task with \(taskEntity.id ?? "") saved to CoreData")
        } catch {
            print("▶️ Error saving task: \(error)")
            context.rollback()
        }
    }
    
    /// Метод для сохранения задачи в CoreData
    func updateTaskToCoreData(_ task: TaskModel, with status: TaskStatus) {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
        
        do {
            let savedTasks = try context.fetch(fetchRequest)
            guard let taskEntity = savedTasks.first else {
                print("▶️ Task with id \(task.id) didn't exist")
                saveNewTaskToCoreData(task, with: .new)
                return
            }
            taskEntity.name = task.name
            taskEntity.completed = task.completed
            taskEntity.photoBase64 = task.photoBase64

            if taskEntity.status != .new {
                taskEntity.status = status
            }
            
            try context.save()
            print("▶️ Task with id \(taskEntity.id ?? "") updated to CoreData")
        } catch {
            print("▶️ Error updating task: \(error)")
            context.rollback()
        }
    }
    
    /// Вспомогательный метод для массового обновления статусов у задач в CoreData
    func updateTasksOnCoreData(with status: TaskStatus) {
        let batchUpdate = NSBatchUpdateRequest(entityName: containerId)
        batchUpdate.predicate = NSPredicate(format: "statusString == %@", status.stringValue)
        batchUpdate.propertiesToUpdate = ["statusString": "server"]
        batchUpdate.resultType = .updatedObjectsCountResultType
        
        do {
            if let result = try context.execute(batchUpdate) as? NSBatchUpdateResult {
                print("▶️ Updated \(result.result ?? 0) tasks with status \(status.stringValue)")
                context.refreshAllObjects()
            }
        } catch {
            print("▶️ Error batch updating: \(error)")
            return
        }
    }
    
    /// Вспомогательный метод на период тестирования - загружает данные из сервера в CoreData
    func loadTaskFromServerToCoreData(for tasks: [TaskModel]) {
        let savedTask = getTasksFromCoreData(with: .server)
        for task in tasks {
            if !savedTask.contains(where: { $0.id == task.id }) {
                saveNewTaskToCoreData(task, with: .server)
            }
        }
    }
    
    /// Вспомогательный метод на период тестирования - удаляет данные из CoreData
    func deleteTasksFromCoreData(with status: TaskStatus) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "statusString == %@", status.stringValue)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeCount
        
        do {
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            print("▶️ Deleted tasks with status \(status.stringValue): \(result?.result ?? 0)")
            context.reset()
        } catch {
            print("▶️ Error deleting batch tasks: \(error)")
            context.rollback()
        }
    }
    
}

// MARK: - Private methods

private extension LocalStorageService {
    
    /// Дополнительный метод для проверки существования задачи
    func taskExists(with id: String) -> Bool {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("▶️ Error checking task existence: \(error)")
            return false
        }
    }
    
    /// Дополнительный метод для получения максимального значения `id` задачи
    func maxId() -> Int {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        do {
            let result = try context.fetch(fetchRequest)
            if result.count > 0 {
                let ids = result.compactMap { Int($0.id ?? "") }
                return ids.max() ?? 0
            } else {
                return 0
            }
        } catch {
            print("▶️ Error getting ids")
            return 0
        }
    }
}
