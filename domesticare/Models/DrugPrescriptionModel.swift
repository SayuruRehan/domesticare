import Foundation

struct DrugPrescriptionModel: Identifiable {
    let uuid: UUID
    let name: String
    let dailyDosage: Int64
    
    var id: UUID { uuid }
} 