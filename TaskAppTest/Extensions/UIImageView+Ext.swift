//
//  UIImageView+Ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.11.2025.
//

import UIKit

extension UIImageView {
    
    static func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.isHidden = true
        return imageView
    }
}
