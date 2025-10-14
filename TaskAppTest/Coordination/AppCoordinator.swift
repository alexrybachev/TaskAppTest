//
//  AppCoordinator.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 11.10.2025.
//

import UIKit

protocol AppCoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get set }
    
    func start()
    func showAddNewTask(from viewController: UIViewController)
    func showDetailTask(_ task: TaskModel, from viewController: UIViewController)
    func dismiss(for viewController: UIViewController)
}

final class AppCoordinator: AppCoordinatorProtocol  {
    
    var navigationController: UINavigationController
    
    private let window: UIWindow?
    private let taskRepository: TaskRepositoryService
    
    init(
        window: UIWindow?,
        navigationController: UINavigationController = UINavigationController(),
        taskRepository: TaskRepositoryService = TaskRepositoryService()
    ) {
        self.window = window
        self.navigationController = navigationController
        self.taskRepository = taskRepository
    }
    
    func start() {
        showTaskList()
        window?.makeKeyAndVisible()
    }
    
    private func showTaskList() {
        let taskListViewModel = TaskListViewModel(coordinator: self, taskRepository: taskRepository)
        let taskListViewController = TaskListViewController(viewModel: taskListViewModel)
        navigationController = UINavigationController(rootViewController: taskListViewController)
        window?.rootViewController = navigationController
    }
    
    func showAddNewTask(from viewController: UIViewController) {
        let taskAddViewModel = TaskAddViewModel(coordinator: self, taskRepository: taskRepository)
        let taskAddViewController = TaskAddViewController(viewModel: taskAddViewModel)
        viewController.navigationController?.pushViewController(taskAddViewController, animated: true)
    }
    
    func showDetailTask(_ task: TaskModel, from viewController: UIViewController) {
        let taskDetailViewModel = TaskDetailViewModel(task: task, taskRepository: taskRepository, coordinator: self)
        let taskDetailViewController = TaskDetailViewController(viewModel: taskDetailViewModel)
        viewController.navigationController?.pushViewController(taskDetailViewController, animated: true)
    }
    
    func dismiss(for viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
}
