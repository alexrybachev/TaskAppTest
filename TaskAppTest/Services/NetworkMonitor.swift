//
//  NetworkMonitor.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 11.10.2025.
//

// Services/NetworkMonitor.swift
import Network
import Combine

/// NetworkMonitor - класс для отслеживания состояния сетевого соединения
final class NetworkMonitor: ObservableObject {
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    
    init() {
        self.monitor = NWPathMonitor()
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                print("Сетевое соединение изменилось: \(path.status == .satisfied ? "Доступно" : "Недоступно")")
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    deinit {
        monitor.cancel()
        print("Мониторинг сети прекратился")
    }
}
