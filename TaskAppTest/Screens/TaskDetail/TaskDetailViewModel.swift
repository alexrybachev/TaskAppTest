//
//  TaskDetailViewModel.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.10.2025.
//

import Foundation
import Combine
import UIKit

final class TaskDetailViewModel: ObservableObject {
    
    @Published var task: TaskModel
    @Published var name: String
    @Published var completed: Bool
    @Published var selectedImage: UIImage?
    @Published var isSaving = false
    
    let navigationTitle = "Информация о задаче"
    
    private let coordinator: AppCoordinator
    private let taskRepository: TaskRepositoryService
    private var cancellables = Set<AnyCancellable>()
    
    init(
        task: TaskModel,
        taskRepository: TaskRepositoryService,
        coordinator: AppCoordinator
    ) {
        self.taskRepository = taskRepository
        self.task = task
        self.name = task.name
        self.completed = task.completed
        self.coordinator = coordinator
        self.selectedImage = task.image
    }
    
    func saveChanges() {
        if !name.isEmpty {
            let updateTask = TaskModel(
                id: task.id,
                name: name,
                completed: completed,
                photoBase64: selectedImage?.toBase64String(),
                date: task.date
            )
            taskRepository.updateTask(updateTask)
        }
    }
     
    func cancelButtonTapped(for viewController: UIViewController) {
        coordinator.dismiss(for: viewController)
    }
}
