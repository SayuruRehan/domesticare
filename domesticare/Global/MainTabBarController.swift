//
//  MainTabBarController.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    let inventoryVC: InventoryListViewController
    let prescriptionVC: PrescriptionListViewController
    
    init(inventoryVC: InventoryListViewController, prescriptionVC: PrescriptionListViewController) {
        self.inventoryVC = inventoryVC
        self.prescriptionVC = prescriptionVC
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.backgroundColor = .secondarySystemBackground
        prescriptionVC.title = NSLocalizedString("Prescriptions", comment: "")
        let prescriptionNavVC = UINavigationController(rootViewController: prescriptionVC)
        let prescriptionTab = UITabBarItem(title: prescriptionVC.title, image: .init(systemName: "list.bullet.clipboard.fill"), tag: 0)
        prescriptionNavVC.tabBarItem = prescriptionTab
        
        
        inventoryVC.title = NSLocalizedString("Inventory", comment: "")
        let inventoryNavVC = UINavigationController(rootViewController: inventoryVC)
        let inventoryTab = UITabBarItem(title: inventoryVC.title, image: .init(systemName: "cross.case.fill"), tag: 1)
        inventoryNavVC.tabBarItem = inventoryTab
        self.viewControllers = [prescriptionNavVC, inventoryNavVC]

    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        NSLog("Selected \(viewController.title!)")
    }
    
}
