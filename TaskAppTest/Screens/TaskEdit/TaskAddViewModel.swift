//
//  TaskAddViewModel.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.10.2025.
//

import Foundation
import Combine
import UIKit


final class TaskAddViewModel: ObservableObject {
    
    @Published var name: String = ""
    @Published var completed: Bool = false
    @Published var selectedImage: UIImage?
    
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    
    private let coordinator: AppCoordinator
    private let taskRepository: TaskRepositoryService
    private var editingTask: TaskModel?
    private var cancellables = Set<AnyCancellable>()
    
    let navigationTitle = "Новая задача"
    
    var isEditing: Bool {
        editingTask != nil
    }
    
    // MARK: - Initial
    init(
        coordinator: AppCoordinator,
        taskRepository: TaskRepositoryService,
        editingTask: TaskModel? = nil
    ) {
        self.coordinator = coordinator
        self.taskRepository = taskRepository
        self.editingTask = editingTask
    }
    
    func saveTask() {
        if !name.isEmpty {
            let addTask = TaskModel(
                id: UUID().uuidString,
                name: name,
                completed: completed,
                photoBase64: selectedImage?.toBase64String(),
                date: Date.currentDateString
            )
            taskRepository.addTask(addTask)
        }
    }
    
    func cancelButtonTapped(for viewController: UIViewController) {
        coordinator.dismiss(for: viewController)
    }
}
