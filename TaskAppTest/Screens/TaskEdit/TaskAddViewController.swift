//
//  TaskAddViewController.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.10.2025.
//

import UIKit
import Combine

final class TaskAddViewController: UIViewController {
    
    private let viewModel: TaskAddViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Название задачи"
        field.borderStyle = .roundedRect
        field.returnKeyType = .done
        return field
    }()
    
    private let completedSwitch: UISwitch = {
        let switchControl = UISwitch()
        return switchControl
    }()
    
    private let completedLabel: UILabel = {
        let label = UILabel()
        label.text = "Выполнена"
        return label
    }()
    
    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить фото", for: .normal)
        return button
    }()
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        imageView.isHidden = true
        return imageView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    // MARK: - Initial
    init(
        viewModel: TaskAddViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupActions()
    }
    
    deinit {
        print("TaskEditVC deinit")
    }
}

// MARK: - SetupUI
private extension TaskAddViewController {
    
    func setupUI() {
        title = viewModel.navigationTitle
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let stackView = UIStackView(arrangedSubviews: [
            createLabeledField("Название", field: nameTextField),
            createSwitchRow(),
            createLabeledField("Фото", field: addPhotoButton),
            photoImageView,
            saveButton
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 16
        
        contentView.addSubview(stackView)
        
        setupConstraints(stackView: stackView)
        setupActions()
        
        nameTextField.delegate = self
    }
    
    func setupConstraints(stackView: UIStackView) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            photoImageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func setupActions() {
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        completedSwitch.addTarget(self, action: #selector(changeSwitch), for: .valueChanged)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    func updateUI() {
        print("TaskEditVC updateUI")
        // Update image
//        if let image = viewModel.selectedImage {
//            photoImageView.image = image
//            photoImageView.isHidden = false
//        }
        
        // Update saving state
        if viewModel.isSaving {
            print("Сохраняем задачу...")
//            showLoadingIndicator(message: "Сохраняем задачу...")
        } else {
            print("Должны скрыть индикатор...")
//            hideLoadingIndicator()
            
            // Handle success
//            if viewModel.errorMessage == nil {
//                coordinatorDelegate?.didFinishEditing()
//            }
        }
        
        // Show errors
//        if let errorMessage = viewModel.errorMessage {
//            showErrorAlert(message: errorMessage)
//        }
    }
    
    func createLabeledField(_ label: String, field: UIView) -> UIStackView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        let stack = UIStackView(arrangedSubviews: [labelView, field])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }
    
    func createSwitchRow() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [completedLabel, completedSwitch])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        return stack
    }
}

// MARK: - Setup binding
private extension TaskAddViewController {
    
    func setupBindings() {
        nameTextField.textPublisher
            .assign(to: \.name, on: viewModel)
            .store(in: &cancellables)
        
        viewModel.$selectedImage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.photoImageView.image = image
                self?.photoImageView.isHidden = image == nil
                
                if image != nil {
                    self?.photoImageView.alpha = 0
                    UIView.animate(withDuration: 0.3) {
                        self?.photoImageView.alpha = 1
                    }
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Objc methods
private extension TaskAddViewController {
    
    @objc func addPhotoTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    @objc func saveTapped() {
        viewModel.saveTask()
        viewModel.cancelButtonTapped(for: self)
    }
    
    @objc func cancelTapped() {
        viewModel.cancelButtonTapped(for: self)
    }
    
    @objc func changeSwitch(_ sender: UISwitch) {
        viewModel.completed = sender.isOn
    }
}

// MARK: - UITextFieldDelegate
extension TaskAddViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

// MARK: - UIImagePickerControllerDelegate
extension TaskAddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.selectedImage = image
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

