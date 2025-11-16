//
//  UITextField+Ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.10.2025.
//

import UIKit

extension UITextField {
    
    static func makeUITextField(_ placeholder: String) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.returnKeyType = .done
        return field
    }
}
