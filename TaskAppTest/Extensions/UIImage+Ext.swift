//
//  UIImage+Ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 13.10.2025.
//

import UIKit

extension UIImage {
    
    func toBase64String(compressionQuality: CGFloat = 0.8) -> String? {
        guard let imageData = self.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        return imageData.base64EncodedString()
    }
}
