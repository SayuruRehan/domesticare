//
//  InventoryService.swift
//  domesticare
//
//  Created by Sayuru Rehan on 2025-04-20
//

import Foundation
import CoreData
import UIKit

protocol InventoryServiceProvider {
    func fetchInventoryDetailsBackground(
        fetch_offset: Int?,
        action: @escaping ([NSManagedObject]) -> ()
    )
    func saveDrugInventory(drugInventory: DrugInventoryModel)
    func removeDrugInventory(uuid: UUID, completionHandler: @escaping (Bool) -> Void)
    func updateRemainingQuantity(
        for uuid: UUID,
        newQuantity: Int64,
        completion: @escaping (Bool) -> Void
    )
}

extension InventoryServiceProvider {
    func fetchInventoryDetailBackground(
        action: @escaping ([NSManagedObject]) -> ()
    ) {
        fetchInventoryDetailsBackground(fetch_offset: nil, action: action)
    }
}

final class InventoryService: InventoryServiceProvider {

    private lazy var drugInventoryContext: NSManagedObjectContext =
        appDelegate.persistentContainer.viewContext

    func fetchInventoryDetailsBackground(
        fetch_offset: Int?,
        action: @escaping ([NSManagedObject]) -> ()
    ) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DrugInventory")
        request.returnsObjectsAsFaults = false
        if let fetch_offset = fetch_offset { request.fetchLimit = fetch_offset }
        drugInventoryContext.perform { [weak self] in
            guard let self else { return }
            let result = try! self.drugInventoryContext.fetch(request)
            action(result as! [NSManagedObject])
        }
    }

    func saveDrugInventory(drugInventory: DrugInventoryModel) {
        let entity = NSEntityDescription.entity(
            forEntityName: "DrugInventory",
            in: drugInventoryContext
        )
        let newDrug = NSManagedObject(entity: entity!, insertInto: drugInventoryContext)
        newDrug.setValue(drugInventory.uuid,              forKey: "uuid")
        newDrug.setValue(drugInventory.name,              forKey: "name")
        newDrug.setValue(drugInventory.remainingQuantity, forKey: "remainingQuantity")
        newDrug.setValue(drugInventory.originalQuantity,  forKey: "originalQuantity")
        newDrug.setValue(drugInventory.snapshot,          forKey: "snapshot")

        drugInventoryContext.perform {
            try? self.drugInventoryContext.save()
        }
    }

    func removeDrugInventory(uuid: UUID, completionHandler: @escaping (Bool) -> Void) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DrugInventory")
        request.predicate = NSPredicate(format: "uuid == %@", uuid.uuidString)

        drugInventoryContext.perform { [weak self] in
            guard
                let self,
                let object = try? self.drugInventoryContext.fetch(request).first as? NSManagedObject
            else { return completionHandler(false) }

            self.drugInventoryContext.delete(object)
            try? self.drugInventoryContext.save()
            DispatchQueue.main.async { completionHandler(true) }
        }
    }

    func updateRemainingQuantity(
        for uuid: UUID,
        newQuantity: Int64,
        completion: @escaping (Bool) -> Void
    ) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DrugInventory")
        request.predicate = NSPredicate(format: "uuid == %@", uuid.uuidString)

        drugInventoryContext.perform { [weak self] in
            guard
                let self,
                let object = try? self.drugInventoryContext.fetch(request).first as? NSManagedObject
            else { return completion(false) }

            object.setValue(newQuantity, forKey: "remainingQuantity")

            do {
                try self.drugInventoryContext.save()
                DispatchQueue.main.async { completion(true) }
            } catch {
                NSLog("InventoryService – failed to update: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
    
    func drugInventory(for name: String,
                       completion: @escaping (DrugInventoryModel?) -> Void) {

        let req = NSFetchRequest<NSManagedObject>(entityName: "DrugInventory")
        req.predicate = NSPredicate(format: "name == %@", name)
        req.fetchLimit = 1

        drugInventoryContext.perform {
            guard
                let data = try? self.drugInventoryContext.fetch(req).first
            else { return completion(nil) }

            let model = DrugInventoryModel(
                uuid:             data.value(forKey: "uuid") as! UUID,
                snapshot:         data.value(forKey: "snapshot") as? Data,
                name:             data.value(forKey: "name") as! String,
                expirationDate:   .init(),  // not needed here
                originalQuantity: data.value(forKey: "originalQuantity") as! Int64,
                remainingQuantity:data.value(forKey: "remainingQuantity") as! Int64
            )
            completion(model)
        }
    }

}
