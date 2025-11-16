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
    func showDetailTask(_ task: TaskModel)
    func dismiss(for viewController: UIViewController)
}

final class AppCoordinator: AppCoordinatorProtocol  {
    
    private let window: UIWindow?
    private let taskRepository: TaskRepositoryService
    
    var navigationController: UINavigationController
    
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
        let taskListViewModel = TaskListViewModel(
            taskRepository: taskRepository,
            onCellTapped: { [weak self] task in
                self?.showDetailTask(task)
            },
            onAddButtonTapped: { [weak self] in
                self?.showAddNewTask(from: UIViewController())
            })
        let taskListViewController = TaskListViewController(viewModel: taskListViewModel)
        navigationController = UINavigationController(rootViewController: taskListViewController)
        window?.rootViewController = navigationController
    }
    
    func showAddNewTask(from viewController: UIViewController) {
        let taskAddViewModel = TaskAddViewModel(taskRepository: taskRepository, onCancelButtonTapped: { [weak self] viewController in
            self?.dismiss(for: viewController)
        })
        let taskView = TaskView()
        let taskAddViewController = TaskAddViewController(taskView: taskView, viewModel: taskAddViewModel)
        navigationController.pushViewController(taskAddViewController, animated: true)
    }
    
    func showDetailTask(_ task: TaskModel) {
        let taskDetailViewModel = TaskDetailViewModel(
            task: task,
            taskRepository: taskRepository,
            onCancelButtonTapped: { [weak self] viewController in
                self?.dismiss(for: viewController)
            })
        let taskView = TaskView()
        let taskDetailViewController = TaskDetailViewController(taskView: taskView, viewModel: taskDetailViewModel)
        navigationController.pushViewController(taskDetailViewController, animated: true)
    }
    
    func dismiss(for viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
}
