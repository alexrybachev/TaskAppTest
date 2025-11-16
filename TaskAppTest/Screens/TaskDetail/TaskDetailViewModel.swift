//
//  TaskDetailViewModel.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.10.2025.
//

import Foundation
import Combine
import UIKit

final class TaskDetailViewModel {
    
    @Published var task: TaskModel
    @Published var name: String
    @Published var completed: Bool
    @Published var selectedImage: UIImage?
    
    let navigationTitle = "Информация о задаче"
    
    private let taskRepository: TaskRepositoryService
    
    var onCancelButtonTapped: ((UIViewController) -> Void)?
    
    init(
        task: TaskModel,
        taskRepository: TaskRepositoryService,
        onCancelButtonTapped: ((UIViewController) -> Void)? = nil
    ) {
        self.taskRepository = taskRepository
        self.task = task
        self.name = task.name
        self.completed = task.completed
        self.selectedImage = task.image
        self.onCancelButtonTapped = onCancelButtonTapped
    }
    
    func saveChanges() {
        if !name.isEmpty {
            let imageString = selectedImage?.toBase64String()
            let updateTask = TaskModel(
                id: task.id,
                name: name,
                completed: completed,
                photoBase64: imageString,
                date: task.date
            )
            taskRepository.updateTask(updateTask)
        }
    }
     
    func cancelButtonTapped(for viewController: UIViewController) {
        onCancelButtonTapped?(viewController)
    }
}
