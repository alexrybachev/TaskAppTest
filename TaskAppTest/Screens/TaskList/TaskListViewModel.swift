//
//  TaskListViewModel.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 11.10.2025.
//

import Foundation
import Combine
import UIKit

final class TaskListViewModel: ObservableObject {
    
    @Published var tasks: [TaskModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let taskRepository: TaskRepositoryService
    private let coordinator: AppCoordinator
    private var cancellables = Set<AnyCancellable>()
    
    init(
        coordinator: AppCoordinator,
        taskRepository: TaskRepositoryService
    ) {
        self.coordinator = coordinator
        self.taskRepository = taskRepository
        setupBindings()
    }
    
    private func setupBindings() {
        taskRepository.tasks
            .assign(to: &$tasks)
        
        taskRepository.isLoading
            .assign(to: &$isLoading)
    }
    
    func fetchTasks() {
        taskRepository.fetchTasks()
    }
    
    func showAddTask(from viewController: UIViewController) {
        coordinator.showAddNewTask(from: viewController)
    }
    
    func showTaskDetail(_ task: TaskModel, from viewController: UIViewController) {
        coordinator.showDetailTask(task, from: viewController)
    }
}
