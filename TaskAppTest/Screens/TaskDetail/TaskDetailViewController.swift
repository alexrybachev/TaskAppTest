//
//  TaskDetailViewController.swift
//  TaskAppTest
//
//  Created by Aleksandr Rybachev on 12.10.2025.
//

import UIKit

final class TaskDetailViewController: UIViewController {
    
    private let taskView: TaskViewProtocol
    private let viewModel: TaskDetailViewModel
    
    // MARK: - Initial
    init(taskView: TaskViewProtocol, viewModel: TaskDetailViewModel) {
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
        taskView.configureView(name: viewModel.task.name, completed: viewModel.task.completed, image: viewModel.task.image)
        taskView.transferTextFieldDelegate(for: self)
    }

}

// MARK: - SetupUI
private extension TaskDetailViewController {
    
    func setupUI() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
        title = viewModel.navigationTitle
    }
    
    @objc func cancelTapped() {
        viewModel.cancelButtonTapped(for: self)
    }
}

// MARK: - UITextFieldDelegate
extension TaskDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension TaskDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension TaskDetailViewController: TaskViewDelegate {
    
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
        viewModel.saveChanges()
        viewModel.cancelButtonTapped(for: self)
    }

}
