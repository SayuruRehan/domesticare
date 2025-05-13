import Foundation

struct DrugInventoryModel: Identifiable {
    let uuid: UUID
    let snapshot: Data?
    let name: String
    let expirationDate: Date
    let originalQuantity: Int64
    let remainingQuantity: Int64
    
    var id: UUID { uuid }
} 