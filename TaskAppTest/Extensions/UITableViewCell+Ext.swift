//
//  UITableViewCell+Ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 09.11.2025.
//

import UIKit

extension UITableViewCell {
    
    static var reuseIdentifier: String {
        String(describing: self)
    }
    
    var reuseIdentifier: String {
        type(of: self).reuseIdentifier
    }
}
