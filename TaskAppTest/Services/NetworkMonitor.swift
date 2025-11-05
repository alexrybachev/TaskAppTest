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
    
    @Published var isConnected = false
    
    init() {
        self.monitor = NWPathMonitor()
        startMonitoring()
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                print("🛜 The network connection has changed: \(path.status == .satisfied ? "Available" : "Not available")")
            }
        }
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    deinit {
        monitor.cancel()
        print("🛜 Network monitoring has stopped")
    }
}
