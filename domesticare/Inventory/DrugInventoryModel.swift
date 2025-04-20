//
//  Drug.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//

import Foundation

struct DrugInventoryModel: Hashable {
    let uuid: UUID
    let snapshot: Data?
    let name: String
    let expirationDate: Date
    let originalQuantity: Int64
    let remainingQuantity: Int64
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        NSLog("Cell name of \(name) UUID is \(uuid)")
    }
    
    static func == (lhs: DrugInventoryModel, rhs: DrugInventoryModel) -> Bool {
        lhs.uuid == rhs.uuid
    }
}
