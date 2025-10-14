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
    case serverEror(String)
    case decodingError
    case encodingError
}

protocol NetworkServiceProtocol {
    func getTasks() -> AnyPublisher<[TaskModel], NetworkError>
    func addTask(_ task: TaskModel) -> AnyPublisher<[TaskModel], NetworkError>
    func updateTask(_ task: TaskModel) -> AnyPublisher<[TaskModel], NetworkError>
}

final class NetworkService: NetworkServiceProtocol {
    
    private let baseURL = "http://0.0.0.0:8080/api"
    private let session: URLSession
    
    init(
        session: URLSession = .shared
    ) {
        self.session = session
    }
    
    func getTasks() -> AnyPublisher<[TaskModel], NetworkError> {
        
        guard let url = URL(string: "\(baseURL)/getTasks") else {
            return Fail(error: .invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return session.dataTaskPublisher(for: request)
            .mapError{ _ in NetworkError.invalidResponse}
            .flatMap { (data, response) -> AnyPublisher<[TaskModel], NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.invalidResponse)
                        .eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: TasksResponse.self, decoder: JSONDecoder())
                    .map { $0.values }
                    .mapError { _ in NetworkError.decodingError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func addTask(_ task: TaskModel) -> AnyPublisher<[TaskModel], NetworkError> {
        
        guard let url = URL(string: "\(baseURL)/addTask") else {
            return Fail(error: .invalidURL)
                .eraseToAnyPublisher()
        }
        
        let addTask = AddTaskRequest(from: task)
        
        guard let jsonData = try? JSONEncoder().encode(addTask) else {
            return Fail(error: NetworkError.encodingError)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        return session.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.invalidResponse }
            .flatMap { (data, response) -> AnyPublisher<[TaskModel], NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.invalidResponse)
                        .eraseToAnyPublisher()
                }
                return Just(data)
                    .decode(type: TasksResponse.self, decoder: JSONDecoder())
                    .map { $0.values }
                    .mapError { _ in NetworkError.decodingError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func updateTask(_ task: TaskModel) -> AnyPublisher<[TaskModel], NetworkError> {
        
        guard let url = URL(string: "\(baseURL)/updateTask") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        let updateTask = UpdateTaskRequest(from: task)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(updateTask)
        
        return session.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.invalidResponse }
            .flatMap { (data, response) -> AnyPublisher<[TaskModel], NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: NetworkError.invalidResponse)
                        .eraseToAnyPublisher()
                }
                return Just(data)
                    .decode(type: TasksResponse.self, decoder: JSONDecoder())
                    .map { $0.values }
                    .mapError { _ in NetworkError.decodingError }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
