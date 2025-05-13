import Foundation
import CoreData

class InventoryStore: ObservableObject {
    @Published var inventory: [DrugInventoryModel] = []
    private let service: InventoryService
    
    init(context: NSManagedObjectContext) {
        self.service = InventoryService(context: context)
        loadInventory()
    }
    
    func loadInventory() {
        inventory = service.getAllDrugInventory()
    }
    
    func addInventory(name: String, quantity: Int64, image: Data?) {
        let model = DrugInventoryModel(
            uuid: UUID(),
            snapshot: image,
            name: name,
            expirationDate: .now.addingTimeInterval(60 * 60 * 24 * 365), // 1 year ahead
            originalQuantity: quantity,
            remainingQuantity: quantity
        )
        service.saveDrugInventory(drugInventory: model)
        loadInventory()
    }
    
    func deleteInventory(_ item: DrugInventoryModel) {
        service.deleteDrugInventory(item)
        loadInventory()
    }
    
    func updateInventory(_ item: DrugInventoryModel) {
        service.updateDrugInventory(item)
        loadInventory()
    }
    
    func updateRemainingQuantity(for uuid: UUID, newQuantity: Int64) {
        service.updateRemainingQuantity(for: uuid, newQuantity: newQuantity) { [weak self] _ in
            self?.loadInventory()
        }
    }
} 