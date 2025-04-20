//
//  Coordinator.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] {get set}
    var navigationController: UINavigationController {get set}
    func start()
}
