//
//  TaskAddViewController.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.10.2025.
//

import UIKit

final class TaskAddViewController: UIViewController {
    
    private let taskView: TaskViewProtocol
    private let viewModel: TaskAddViewModel
    
    // MARK: - Initial
    init(taskView: TaskViewProtocol, viewModel: TaskAddViewModel) {
        self.taskView = taskView
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = taskView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        taskView.delegate = self
        taskView.transferTextFieldDelegate(for: self)
    }
}

// MARK: - SetupUI
private extension TaskAddViewController {
    
    func setupUI() {
        title = viewModel.navigationTitle
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func cancelTapped() {
        viewModel.cancelButtonTapped(for: self)
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
            taskView.configureView(name: viewModel.name, completed: viewModel.completed, image: image)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - TaskViewDelegate

extension TaskAddViewController: TaskViewDelegate {
    
    func didTextFieldChange(_ text: String?) {
        viewModel.name = text ?? ""
    }
    
    func didSwitchChanged(_ value: Bool) {
        viewModel.completed = value
    }
    
    func didAddPhotoButtonTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }
    
    func didSaveButtonTapped() {
        viewModel.saveTask()
        viewModel.cancelButtonTapped(for: self)
    }
    
    
}
