//
//  TaskListViewModel.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 11.10.2025.
//

import Foundation
import Combine
import UIKit

final class TaskListViewModel {
    
    @Published var tasks: [TaskModel] = []
    @Published var isLoading = false
    
    private let taskRepository: TaskRepositoryService
    
    let title = "Мои задачи"
    
    var onCellTapped: ((TaskModel) -> Void)?
    var onAddButtonTapped: (() -> Void)?
    
    init(
        taskRepository: TaskRepositoryService,
        onCellTapped: ((TaskModel) -> Void)? = nil,
        onAddButtonTapped: (() -> Void)? = nil
    ) {
        self.taskRepository = taskRepository
        self.onCellTapped = onCellTapped
        self.onAddButtonTapped = onAddButtonTapped
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
}
