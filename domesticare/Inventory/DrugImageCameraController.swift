//
//  DrugImageCameraController.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//

import Foundation
import UIKit

class DrugImageCameraController: UIImagePickerController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    weak var coordinator: InventoryCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellPerRow: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
        self.preferredContentSize = CGSize(width: view.frame.size.width / cellPerRow - 15 - 20 - 60, height: view.frame.size.width / cellPerRow - 15 - 20 - 20)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        coordinator?.setInventoryDrugImage(image: info[.originalImage] as? UIImage)
    }
}
