//
//  InventoryDetailViewController.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//

import UIKit
import CoreData

final class InventoryDetailViewController: UIViewController {

    // Dependencies
    unowned let coordinator: InventoryCoordinator
    let inventoryService: InventoryServiceProvider
    private let componentFactory: InfoComponentFactory = DrugInfoComponentFactory()
    private let inputFactory:   InputTextFieldFactory = DrugInfoTextFieldFactory()

    private(set) var drug: DrugInventoryModel

    // UI State
    private var isEditingQuantity = false
    private var quantityField: UITextField!

    init(coordinator: InventoryCoordinator,
         inventoryService: InventoryServiceProvider,
         drug: DrugInventoryModel) {

        self.coordinator      = coordinator
        self.inventoryService = inventoryService
        self.drug             = drug
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }

    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupNavigation()
        setupDrugComponents()
        setupDeleteButton()
    }

    // NavBar
    private func setupNavigation() {
        navigationItem.title = drug.name
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(barButtonSystemItem: .edit,
                            target: self,
                            action: #selector(toggleEditMode))
    }

    @objc private func toggleEditMode() {
        isEditingQuantity.toggle()

        if isEditingQuantity {
            // switch to “Save” mode
            navigationItem.rightBarButtonItem =
                UIBarButtonItem(barButtonSystemItem: .save,
                                target: self,
                                action: #selector(saveQuantity))
            quantityField.becomeFirstResponder()
        } else {
            // leave edit‑mode
            navigationItem.rightBarButtonItem =
                UIBarButtonItem(barButtonSystemItem: .edit,
                                target: self,
                                action: #selector(toggleEditMode))
            view.endEditing(true)
        }
    }

    // Drug Component Row
    private func setupDrugComponents() {
        // Left‑label
        let leftLabel = UILabel()
        leftLabel.text          = NSLocalizedString("Quantity", comment: "")
        leftLabel.textColor     = .systemOrange
        leftLabel.font          = .boldSystemFont(ofSize: 20)
        leftLabel.translatesAutoresizingMaskIntoConstraints = false

        // Right‑hand editable text‑field
        let input = inputFactory.create(
            placeholder: String(drug.remainingQuantity),
            isEditing: false
        )
        quantityField               = input.textFieldView
        quantityField.textAlignment = .center
        quantityField.delegate      = self
        input.translatesAutoresizingMaskIntoConstraints = false

        let row = componentFactory.create(
            leftView: leftLabel,
            rightView: input,
            isEditing: false
        )
        row.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            row.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            row.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            row.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // Delete
    private func setupDeleteButton() {
        let deleteButton = UIButton(type: .system, primaryAction:
            UIAction { [weak self] _ in
                guard let self else { return }
                self.coordinator.deleteInventoryTapped()
                self.inventoryService.removeDrugInventory(uuid: self.drug.uuid) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
            })
        deleteButton.layer.cornerRadius = 20
        deleteButton.backgroundColor    = .tintColor.withAlphaComponent(0.15)
        deleteButton.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
        deleteButton.titleLabel?.font   = .systemFont(ofSize: 18, weight: .semibold)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            deleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            deleteButton.heightAnchor.constraint(equalToConstant: 60),
            deleteButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            deleteButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }

    // Save Logic
    @objc private func saveQuantity() {
        guard
            let text   = quantityField.text?.trimmingCharacters(in: .whitespaces),
            let newQty = Int64(text),
            newQty >= 0, newQty <= drug.originalQuantity
        else {
            present(alert("Enter a value between 0 and \(drug.originalQuantity)."),
                    animated: true)
            return
        }

        inventoryService.updateRemainingQuantity(for: drug.uuid,
                                                 newQuantity: newQty) { [weak self] ok in
            guard let self else { return }
            if ok {
                drug = DrugInventoryModel(
                    uuid:             drug.uuid,
                    snapshot:         drug.snapshot,
                    name:             drug.name,
                    expirationDate:   drug.expirationDate,
                    originalQuantity: drug.originalQuantity,
                    remainingQuantity:newQty
                )
                quantityField.text = String(newQty)
                toggleEditMode()   // flips nav button back to “Edit”
            } else {
                present(alert("Couldn’t save, please try again."), animated: true)
            }
        }
    }

    // Helper func
    private func alert(_ message: String) -> UIAlertController {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        return alert
    }
}

// UITextFieldDelegate
extension InventoryDetailViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEditingQuantity
    }
}
