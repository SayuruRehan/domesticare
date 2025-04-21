//
//  InventoryAutoDecrementOperation.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-21.
//

import Foundation

/// Runs off‑thread inside a BGAppRefreshTask
final class InventoryAutoDecrementOperation: Operation {

    private let prescriptionService = DrugPrescriptionService()
    private let inventoryService    = InventoryService()

    override func main() {
        let semaphore = DispatchSemaphore(value: 0)

        prescriptionService.fetchDrugsBackground(fetch_offset: .max) { [weak self] objects in
            guard let self else { semaphore.signal(); return }

            let dispatchGroup = DispatchGroup()

            for obj in objects {
                let name       = obj.value(forKey: "name")        as! String
                let dailyDose  = obj.value(forKey: "dailyDosage") as! Int64

                dispatchGroup.enter()
                self.inventoryService.drugInventory(for: name) { model in
                    guard var model else { dispatchGroup.leave(); return }

                    let newQty = max(model.remainingQuantity - dailyDose, 0)
                    self.inventoryService.updateRemainingQuantity(
                        for: model.uuid,
                        newQuantity: newQty
                    ) { _ in
                        model = DrugInventoryModel(
                            uuid:             model.uuid,
                            snapshot:         model.snapshot,
                            name:             model.name,
                            expirationDate:   model.expirationDate,
                            originalQuantity: model.originalQuantity,
                            remainingQuantity:newQty
                        )
                        NotificationManager.shared
                            .scheduleRefillReminder(for: model, dailyDose: dailyDose)
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .global()) {
                semaphore.signal()
            }
        }

        // Wait until all async work is done
        _ = semaphore.wait(timeout: .now() + 25)
    }
}
