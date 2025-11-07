//
//  TaskRepositoryService.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 13.10.2025.
//


import Foundation
import Combine
import Network

final class TaskRepositoryService {
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    private let networkService: NetworkServiceProtocol
    private let localStorage: LocalStorageServiceProtocol
    private let monitor: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()
    
    let tasks = CurrentValueSubject<[TaskModel], Never>([])
    let isOnline = CurrentValueSubject<Bool, Never>(false)
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let syncStatus = CurrentValueSubject<SyncStatus, Never>(.idle)
    
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        localStorage: LocalStorageServiceProtocol = LocalStorageService(),
        monitor: NetworkMonitor = NetworkMonitor()
    ) {
        self.networkService = networkService
        self.localStorage = localStorage
        self.monitor = monitor
        setupNetworkMonitoring()
        startSyncTimer()
    }
}

// MARK: - Public methods
extension TaskRepositoryService {
    
    func fetchTasks() {
        isLoading.send(true)
        if isOnline.value {
            fetchTasksFromServer()
        } else {
            updateTasksInfo()
            isLoading.send(false)
        }
    }
    
    func addTask(_ task: TaskModel) {
        if isOnline.value {
            saveTaskToServer(task)
        } else {
            localStorage.saveNewTaskToCoreData(task, with: .new)
            updateTasksInfo()
        }
    }
    
    func updateTask(_ task: TaskModel) {
        if isOnline.value {
            updateTaskOnServer(task)
        } else {
            localStorage.updateTaskToCoreData(task, with: .update)
            updateTasksInfo()
        }
    }
    
    /// Метод для синхронизации задач между сервером и  CoreData
    func syncTasks() {
        guard isOnline.value else { return }
        syncStatus.send(.syncing)
        
        let updatedTasks = localStorage.getTasksFromCoreData(with: .update)
        let updatePublisher = updateTasksFromCoreData(for: updatedTasks)
        
        let newTasks = localStorage.getTasksFromCoreData(with: .new)
        let newTasksPubishers = addNewTaskToServer(for: newTasks)
        
        return Publishers.Merge(updatePublisher, newTasksPubishers)
            .last()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.localStorage.updateTasksOnCoreData(with: .update)
                    self?.localStorage.updateTasksOnCoreData(with: .new)
                    self?.fetchTasksFromServer()
                    self?.syncStatus.send(.idle)
                    print("♻️ Finished syncing tasks")
                case .failure(let error):
                    print("❌ Failure sync tasks: \(error), \(error.localizedDescription)")
                    self?.syncStatus.send(.error("Error fetching tasks from server"))
                }
            } receiveValue: { [weak self] result in
                self?.tasks.send(result)
                self?.syncStatus.send(.success)
            }
            .store(in: &cancellables)
    }
    
    /// Метод для обновления задач
    func updateTasksInfo() {
        let savedTasks = localStorage.getTasksFromCoreData(with: nil)
        tasks.send(savedTasks)
    }
    
}

// MARK: - Network Monitoring
private extension TaskRepositoryService {
    
    func setupNetworkMonitoring() {
        monitor.$isConnected
            .sink { [weak self] isOnline in
                self?.isOnline.send(isOnline)
                if isOnline {
                    print("📱 Network connected - starting sync")
                    self?.syncTasks()
                } else {
                    print("📱 Network disconnected - working offline")
                }
            }
            .store(in: &cancellables)
    }
    
    /// Периодическая проверка синхронизации каждые 30 секунд
    func startSyncTimer() {
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                print("isOnline = \(self?.isOnline.value ?? false)")
            }
            .store(in: &cancellables)
    }
}

// MARK: - Network Management
private extension TaskRepositoryService {
    
    func fetchTasksFromServer() {
        networkService.getTasks()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isOnline.send(true)
                    self?.isLoading.send(false)
                case .failure(let error):
                    print("❌ Error fetching tasks from server: \(error)")
                    self?.isLoading.send(false)
                    self?.updateTasksInfo()
                }
            } receiveValue: { [weak self] serverTasks in
                self?.tasks.send(serverTasks)
                self?.localStorage.loadTaskFromServerToCoreData(for: serverTasks)
            }
            .store(in: &cancellables)
    }
    
    func saveTaskToServer(_ task: TaskModel) {
        networkService.addTask(task)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isOnline.send(true)
                case .failure(let error):
                    print("❌ Failed to add task to server: \(error)")
                    self?.localStorage.saveNewTaskToCoreData(task, with: .new)
                    self?.updateTasksInfo()
                }
            } receiveValue: { [weak self] savedTasks in
                self?.tasks.send(savedTasks)
                if let newTask = savedTasks.first(where: { $0.date == task.date }) {
                    self?.localStorage.saveNewTaskToCoreData(newTask, with: .server)
                }
            }
            .store(in: &cancellables)
    }
    
    func updateTaskOnServer(_ task: TaskModel) {
        networkService.updateTask(task)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isOnline.send(true)
                case .failure(let error):
                    print("❌ Failed to update task on server: \(error)")
                    self?.localStorage.updateTaskToCoreData(task, with: .update)
                    self?.updateTasksInfo()
                }
            } receiveValue: { [weak self] updatedTasks in
                self?.tasks.send(updatedTasks)
                if let updatedTask = updatedTasks.first(where: { $0.id == task.id }) {
                    self?.localStorage.updateTaskToCoreData(updatedTask, with: .server)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Server Synchronization
private extension TaskRepositoryService {
    
    func addNewTaskToServer(for tasks: [TaskModel]) -> AnyPublisher<[TaskModel], NetworkError> {
        return Publishers.Sequence(sequence: tasks)
            .flatMap { [weak self] task -> AnyPublisher<[TaskModel], NetworkError> in
                guard let self = self else {
                    return Fail<[TaskModel], NetworkError>(error: NetworkError.serverError("Error addNewTaskToServer"))
                        .eraseToAnyPublisher()
                }
                return self.networkService.addTask(task)
            }
            .last()
            .eraseToAnyPublisher()
    }
    
    func updateTasksFromCoreData(for tasks: [TaskModel]) -> AnyPublisher<[TaskModel], NetworkError> {
        return Publishers.Sequence(sequence: tasks)
            .flatMap { [weak self] task -> AnyPublisher<[TaskModel], NetworkError> in
                guard let self = self else {
                    return Fail<[TaskModel], NetworkError>(error: NetworkError.serverError("Error updateTasksFromCoreData"))
                        .eraseToAnyPublisher()
                }
                return self.networkService.updateTask(task)
            }
            .last()
            .eraseToAnyPublisher()
    }
}
