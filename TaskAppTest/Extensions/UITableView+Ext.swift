//
//  UITableView+Ext.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 09.11.2025.
//

import UIKit

extension UITableView {
        
    func register<T: UITableViewCell>(_ type: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func reuse<T: UITableViewCell>(_ type: T.Type, _ indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

extension UITableView {
    func registerCell<Cell>(_ cell: Cell.Type) where Cell: UITableViewCell {
        register(cell.self, forCellReuseIdentifier: String(describing: cell))
    }
}
