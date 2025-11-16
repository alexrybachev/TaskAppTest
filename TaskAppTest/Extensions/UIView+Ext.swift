//
//  UIView+Ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 16.11.2025.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }
}
