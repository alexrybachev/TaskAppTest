//
//  TaskAddViewModel.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.10.2025.
//

import Foundation
import Combine
import UIKit


final class TaskAddViewModel {
    
    @Published var name: String = ""
    @Published var completed: Bool = false
    @Published var selectedImage: UIImage?
    
    private let taskRepository: TaskRepositoryService
    
    let navigationTitle = "Новая задача"
    
    var onCancelButtonTapped: ((UIViewController) -> Void)?
    
    // MARK: - Initial
    init(
        taskRepository: TaskRepositoryService,
        onCancelButtonTapped: ((UIViewController) -> Void)? = nil
    ) {
        self.taskRepository = taskRepository
        self.onCancelButtonTapped = onCancelButtonTapped
    }
    
    func saveTask() {
        if !name.isEmpty {
            let imageString = selectedImage?.toBase64String()
            let dateNow = Date.currentDateString
            let addTask = TaskModel(
                id: UUID().uuidString,
                name: name,
                completed: completed,
                photoBase64: imageString,
                date: dateNow
            )
            taskRepository.addTask(addTask)
        }
    }
    
    func cancelButtonTapped(for viewController: UIViewController) {
        onCancelButtonTapped?(viewController)
    }
}
