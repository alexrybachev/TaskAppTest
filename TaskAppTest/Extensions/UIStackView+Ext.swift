//
//  UIStackView+Ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.11.2025.
//

import UIKit

extension UIStackView {
    
    static func makeUIStackView(_ views: [UIView], with axis: NSLayoutConstraint.Axis, and spacing: CGFloat, and distribution: UIStackView.Distribution = .fill) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = axis
        stackView.spacing = 16
        return stackView
    }
    
    static func createLabeledField(_ label: String, field: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let stack = UIStackView(arrangedSubviews: [labelView, field])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }
}
