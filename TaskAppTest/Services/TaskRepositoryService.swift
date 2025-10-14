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
    
    private let syncQueue = DispatchQueue(label: "SyncQueue", qos: .utility)
    
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
        loadInitialData()
        startSyncTimer()
    }
    
    deinit {
        print("TaskRepositoryService deinit")
    }
    
}

// MARK: - Public methods
extension TaskRepositoryService {
    
    func fetchTasks() {
        if isOnline.value {
            fetchTasksFromServer()
        } else {
            mergeLocalAndDeferredTasks()
        }
    }
    
    func addTask(_ task: TaskModel) {
        if isOnline.value {
            addTaskToServer(task)
        } else {
            saveTaskLocally(task, deferredOperation: .add)
        }
    }
    
    func updateTask(_ task: TaskModel) {
        if isOnline.value {
            updateTaskOnServer(task)
        } else {
            saveTaskLocally(task, deferredOperation: .update)
        }
    }
    
    func syncPendingOperations() {
        guard isOnline.value else { return }
        
        let deferredTasks = localStorage.getDeferredTasks()
        guard !deferredTasks.isEmpty else { return }
        
        syncStatus.send(.syncing)
        syncDeferredTasks(deferredTasks)
    }
    
}

// MARK: - Network Monitoring
private extension TaskRepositoryService {
    
    func setupNetworkMonitoring() {
        monitor.$isConnected
            .sink { [weak self] isOnline in
                self?.isOnline.send(isOnline)
                print("isOnline = \(self!.isOnline.value)")
                if isOnline {
                    print("📱 Network connected - starting sync")
                    self?.syncPendingOperations()
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
                if self?.isOnline.value == true {
                    self?.syncPendingOperations()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Server Synchronization
private extension TaskRepositoryService {
    
    func fetchTasksFromServer() {
        syncStatus.send(.syncing)
        
        networkService.getTasks()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ Error fetching tasks from server: \(error)")
                    self?.syncStatus.send(.error("Error fetching tasks from server"))
                }
            } receiveValue: { [weak self] serverTasks in
                guard let self = self else { return }
                self.localStorage.saveTasks(serverTasks)
                self.tasks.send(serverTasks)
                self.syncStatus.send(.success)
                self.syncPendingOperations()
            }
            .store(in: &cancellables)
    }
    
    func addTaskToServer(_ task: TaskModel) {
        networkService.addTask(task)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ Failed to add task to server: \(error)")
                    self?.saveTaskLocally(task, deferredOperation: .add)
                    self?.syncStatus.send(.error("Failed to add task"))
                }
            } receiveValue: { [weak self] updatedTasks in
                guard let self = self else { return }
                self.localStorage.saveTasks(updatedTasks)
                self.tasks.send(updatedTasks)
            }
            .store(in: &cancellables)
    }
    
    func updateTaskOnServer(_ task: TaskModel) {
        networkService.updateTask(task)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ Failed to update task on server: \(error)")
                    self?.saveTaskLocally(task, deferredOperation: .update)
                    self?.syncStatus.send(.error("Failed to update task"))
                }
            } receiveValue: { [weak self] updatedTasks in
                guard let self = self else { return }
                self.localStorage.saveTasks(updatedTasks)
                self.tasks.send(updatedTasks)
            }
            .store(in: &cancellables)
    }
    
    func syncDeferredTasks(_ deferredTasks: [TaskModel]) {
        guard !deferredTasks.isEmpty else {
            syncStatus.send(.success)
            return
        }
        
        let group = DispatchGroup()
        var successfulTasks: [TaskModel] = []
        var failedTasks: [TaskModel] = []
        
        for task in deferredTasks {
            group.enter()
        
            let localTasks = localStorage.loadTasks()
            let isUpdate = localTasks.contains(where: { $0.id == task.id })
            
            let publisher = isUpdate ?
            networkService.updateTask(task) :
            networkService.addTask(task)
            
            publisher
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("❌ Failed to sync task \(task.id): \(error)")
                        failedTasks.append(task)
                    } else {
                        successfulTasks.append(task)
                    }
                    group.leave()
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.handleSyncCompletion(successfulTasks: successfulTasks, failedTasks: failedTasks)
        }
    }
    
    func handleSyncCompletion(successfulTasks: [TaskModel], failedTasks: [TaskModel]) {
        if failedTasks.isEmpty {
            localStorage.clearDeferredTasks()
            syncStatus.send(.success)
            fetchTasksFromServer()
        } else {
            localStorage.saveDeferredTasks(failedTasks)
            syncStatus.send(.error("Failed to sync \(failedTasks.count) tasks"))
        }
    }
}

// MARK: - Data Management
private extension TaskRepositoryService {
    
    func loadInitialData() {
        let localTasks = localStorage.loadInitialData()
        tasks.send(localTasks)
        
        if isOnline.value {
            fetchTasksFromServer()
        } else {
            mergeLocalAndDeferredTasks()
        }
    }
    
    func mergeLocalAndDeferredTasks() {
        let localTasks = localStorage.loadTasks()
        let deferredTasks = localStorage.getDeferredTasks()
        
        var mergedTasks = localTasks
        
        for deferredTask in deferredTasks {
            if let index = mergedTasks.firstIndex(where: { $0.id == deferredTask.id }) {
                mergedTasks[index] = deferredTask
            } else {
                mergedTasks.append(deferredTask)
            }
        }
        
        tasks.send(mergedTasks)
    }
    
    func saveTaskLocally(_ task: TaskModel, deferredOperation: DeferredOperationType) {
        var currentTasks = tasks.value
        
        if let index = currentTasks.firstIndex(where: { $0.id == task.id }) {
            currentTasks[index] = task
            localStorage.updateTask(task)
        } else {
            currentTasks.append(task)
            localStorage.saveTasks(currentTasks)
        }
        
        tasks.send(currentTasks)
        
        switch deferredOperation {
        case .add:
            localStorage.saveDeferredTask(task)
        case .update:
            localStorage.updateDeferedTask(task)
        }
    }

}
