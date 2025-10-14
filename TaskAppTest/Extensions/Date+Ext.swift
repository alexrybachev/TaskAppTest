//
//  Date+Ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 13.10.2025.
//

import Foundation

extension Date {
    
    func toDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }
    
    static var currentDateString: String {
        return Date().toDateString()
    }
}
