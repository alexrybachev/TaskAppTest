//
//  TaskCell.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 11.10.2025.
//

import UIKit

final class TaskCell: UITableViewCell {
    
    private lazy var nameLabel = UILabel.makeUILabel(with: 16, .medium, nil, numberOfLines: 2)
    private lazy var statusLabel = UILabel.makeUILabel(with: 14, .regular, .systemGray)
    private lazy var dateLabel = UILabel.makeUILabel(with: 12, .light, .systemGray2)
    private lazy var stackView = UIStackView.makeUIStackView([nameLabel, statusLabel, dateLabel], with: .vertical, and: 4)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with task: TaskModel) {
        nameLabel.text = task.name
        statusLabel.text = task.completed ? "✅ Выполнена" : "⏳ В процессе"
        dateLabel.text = task.formattedDate
        accessoryType = .disclosureIndicator
    }
}

// MARK: - SetupUI

private extension TaskCell {
    
    func setupUI() {
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
