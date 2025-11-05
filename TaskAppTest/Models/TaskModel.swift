//
//  TaskModel.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 11.10.2025.
//

import Foundation
import UIKit

struct TasksResponse: Decodable {
    let values: [TaskModel]
}

struct TaskModel: Decodable, Identifiable, Hashable {
    let id: String
    var name: String
    var completed: Bool
    var photoBase64: String?
    var date: String
}

// MARK: - Extensions

extension TaskModel {
    
    var imageData: Data? {
        guard let base64String = photoBase64 else { return nil }
        return Data(base64Encoded: base64String)
    }
    
    /// Вычисляемое свойство для работы с UIImage
    var image: UIImage? {
        guard let photoBase64 = photoBase64, let imageData = Data(base64Encoded: photoBase64) else { return nil }
        return UIImage(data: imageData)
    }
    
    /// Вычисляемое свойство для удобства работы с Date
    var dateValue: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.date(from: date) ?? Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: dateValue)
    }
}
