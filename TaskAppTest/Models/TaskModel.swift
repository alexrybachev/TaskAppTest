//
//  TaskModel.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 11.10.2025.
//

import Foundation
import UIKit

struct TasksResponse: Codable {
    let values: [TaskModel]
}

struct TaskModel: Codable, Identifiable, Hashable {
    let id: String
    var name: String
    var completed: Bool
    var photoBase64: String?
    var date: String
}

// TODO: - Возможно удалить
extension TaskModel {
    
//    func addNewTask(name: String, completed: Bool = false, photoBase64: String?) -> AddTaskRequest {
//        add
//    }
    
    /// Метод для обновления задачи с изображением
//    func updating(name: String? = nil,
//                  completed: Bool? = nil,
//                  image: UIImage? = nil,
//                  date: Date? = nil) -> TaskModel {
//        
//        let newDate: String
//        if let date = date {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            newDate = formatter.string(from: date)
//        } else {
//            newDate = self.date ?? ""
//        }
//        
//        let newPhotoBase64: String?
//        if let image = image,
//           let imageData = image.jpegData(compressionQuality: 0.7) {
//            newPhotoBase64 = imageData.base64EncodedString()
//        } else {
//            newPhotoBase64 = self.photoBase64
//        }
//        
//        return TaskModel(
//            id: self.id,
//            name: name ?? self.name,
//            completed: completed ?? self.completed,
//            photoBase64: newPhotoBase64,
//            date: newDate
//        )
//    }
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
