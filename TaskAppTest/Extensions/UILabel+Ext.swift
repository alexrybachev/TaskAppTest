//
//  UILabel+Ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.11.2025.
//

import UIKit

extension UILabel {
    
    static func makeUILabel(with fontSize: CGFloat, _ weight: UIFont.Weight, _ textColor: UIColor? = nil, numberOfLines: Int = 1) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        if textColor != nil {
            label.textColor = textColor
        }
        label.numberOfLines = numberOfLines
        return label
    }
    
    static func makeSimpleLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        return label
    }
}
