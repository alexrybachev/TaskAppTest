//
//  TaskView.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 07.11.2025.
//

import UIKit

protocol TaskViewProtocol: UIView {
    var delegate: TaskViewDelegate? { get set }
    func configureView(name: String, completed: Bool, image: UIImage?)
    func transferTextFieldDelegate(for viewController: UITextFieldDelegate)
}

protocol TaskViewDelegate: AnyObject {
    func didTextFieldChange(_ text: String?)
    func didSwitchChanged(_ value: Bool)
    func didAddPhotoButtonTapped()
    func didSaveButtonTapped()
}

final class TaskView: UIView {
    
    // MARK: - UI Elements
    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()
    private lazy var nameTextField = UITextField.makeUITextField("Название задачи")
    private lazy var completedLabel = UILabel.makeSimpleLabel("Выполнена")
    private lazy var completedSwitch = UISwitch()
    private lazy var addPhotoButton = UIButton.makeSimpleButton("Добавить фото")
    private lazy var photoImageView = UIImageView.makeImageView()
    private lazy var saveButton = UIButton.makeUIButton("Сохранить")
    private lazy var switchRow = UIStackView.makeUIStackView([completedLabel, completedSwitch], with: .horizontal, and: 0, and: .equalSpacing)
    private lazy var nameLabeledField = UIStackView.createLabeledField("Название", field: nameTextField)
    private lazy var addPhotoLabeledField = UIStackView.createLabeledField("Фото", field: addPhotoButton)
    private lazy var stackViews = UIStackView.makeUIStackView([nameLabeledField, switchRow, addPhotoLabeledField, photoImageView, saveButton], with: .vertical, and: 16)
    
    weak var delegate: TaskViewDelegate?
    
    // MARK: - Initial
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - SetupUI
private extension TaskView {
    
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackViews)
    }
    
    func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackViews.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackViews.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackViews.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackViews.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackViews.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            photoImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func setupActions() {
        completedSwitch.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

}

// MARK: - Objc methods
private extension TaskView {
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        delegate?.didTextFieldChange(sender.text)
    }
    
    @objc func changeSwitch(_ sender: UISwitch) {
        delegate?.didSwitchChanged(sender.isOn)
    }
    
    @objc func addPhotoTapped() {
        delegate?.didAddPhotoButtonTapped()
    }
    
    @objc func saveButtonTapped() {
        delegate?.didSaveButtonTapped()
    }
}


// MARK: TaskViewProtocol

extension TaskView: TaskViewProtocol {
    
    func configureView(name: String, completed: Bool, image: UIImage? = nil) {
        nameTextField.text = name
        completedSwitch.isOn = completed
        if image != nil {
            photoImageView.isHidden = false
            photoImageView.image = image
        }
    }
    
    func transferTextFieldDelegate(for viewController: UITextFieldDelegate) {
        nameTextField.delegate = viewController
    }
}
