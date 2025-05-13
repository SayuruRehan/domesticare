import Foundation
import CoreData

protocol InventoryServiceProvider {
    func getAllDrugInventory() -> [DrugInventoryModel]
    func saveDrugInventory(drugInventory: DrugInventoryModel)
    func updateDrugInventory(_ drugInventory: DrugInventoryModel)
    func deleteDrugInventory(_ drugInventory: DrugInventoryModel)
    func updateRemainingQuantity(for uuid: UUID, newQuantity: Int64, completion: @escaping (Bool) -> Void)
}

class InventoryService: InventoryServiceProvider {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAllDrugInventory() -> [DrugInventoryModel] {
        let request: NSFetchRequest<DrugInventory> = DrugInventory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let inventory = try context.fetch(request)
            return inventory.map { item in
                DrugInventoryModel(
                    uuid: item.uuid ?? UUID(),
                    snapshot: item.snapshot,
                    name: item.name ?? "",
                    expirationDate: item.expirationDate ?? Date(),
                    originalQuantity: item.originalQuantity,
                    remainingQuantity: item.remainingQuantity
                )
            }
        } catch {
            print("Error fetching inventory: \(error)")
            return []
        }
    }
    
    func saveDrugInventory(drugInventory: DrugInventoryModel) {
        let newInventory = DrugInventory(context: context)
        newInventory.uuid = drugInventory.uuid
        newInventory.snapshot = drugInventory.snapshot
        newInventory.name = drugInventory.name
        newInventory.expirationDate = drugInventory.expirationDate
        newInventory.originalQuantity = drugInventory.originalQuantity
        newInventory.remainingQuantity = drugInventory.remainingQuantity
        
        do {
            try context.save()
        } catch {
            print("Error saving inventory: \(error)")
        }
    }
    
    func updateDrugInventory(_ drugInventory: DrugInventoryModel) {
        let request: NSFetchRequest<DrugInventory> = DrugInventory.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", drugInventory.uuid as CVarArg)
        
        do {
            let inventory = try context.fetch(request)
            if let existingInventory = inventory.first {
                existingInventory.snapshot = drugInventory.snapshot
                existingInventory.name = drugInventory.name
                existingInventory.expirationDate = drugInventory.expirationDate
                existingInventory.originalQuantity = drugInventory.originalQuantity
                existingInventory.remainingQuantity = drugInventory.remainingQuantity
                try context.save()
            }
        } catch {
            print("Error updating inventory: \(error)")
        }
    }
    
    func deleteDrugInventory(_ drugInventory: DrugInventoryModel) {
        let request: NSFetchRequest<DrugInventory> = DrugInventory.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", drugInventory.uuid as CVarArg)
        
        do {
            let inventory = try context.fetch(request)
            if let existingInventory = inventory.first {
                context.delete(existingInventory)
                try context.save()
            }
        } catch {
            print("Error deleting inventory: \(error)")
        }
    }
    
    func updateRemainingQuantity(for uuid: UUID, newQuantity: Int64, completion: @escaping (Bool) -> Void) {
        let request: NSFetchRequest<DrugInventory> = DrugInventory.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        
        do {
            let inventory = try context.fetch(request)
            if let existingInventory = inventory.first {
                existingInventory.remainingQuantity = newQuantity
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Error updating quantity: \(error)")
            completion(false)
        }
    }
} 