//
//  NetworkService.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 13.10.2025.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case decodingError
    case encodingError
    case buildRequestError
    case unknown
}

protocol NetworkServiceProtocol {
    func getTasks() -> AnyPublisher<[TaskModel], NetworkError>
    func addTask(_ task: TaskModel) -> AnyPublisher<[TaskModel], NetworkError>
    func updateTask(_ task: TaskModel) -> AnyPublisher<[TaskModel], NetworkError>
}

final class NetworkService {
    
    private let network: HTTPClient
    
    init(
        network: HTTPClient = HTTPClient()
    ) {
        self.network = network
    }
}

extension NetworkService: NetworkServiceProtocol {
    
    func getTasks() -> AnyPublisher<[TaskModel], NetworkError> {
        network.request(endpoint: TaskEndpoint.getTasks)
            .compactMap { (response: TasksResponse) in
                response.values
            }
            .eraseToAnyPublisher()
    }
    
    func addTask(_ task: TaskModel) -> AnyPublisher<[TaskModel], NetworkError> {
        let addTask = AddTaskRequest(from: task)
        return network.post(endpoint: TaskEndpoint.addTask, body: addTask)
            .compactMap { (response: TasksResponse) in
                response.values
            }
            .eraseToAnyPublisher()
    }
    
    func updateTask(_ task: TaskModel) -> AnyPublisher<[TaskModel], NetworkError> {
        let updateTask = UpdateTaskRequest(from: task)
        return network.post(endpoint: TaskEndpoint.updateTask, body: updateTask)
            .compactMap { (response: TasksResponse) in
                response.values
            }
            .eraseToAnyPublisher()
    }
}
