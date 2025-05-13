import Foundation
import CoreData

class DrugPrescriptionStore: ObservableObject {
    @Published var prescriptions: [DrugPrescriptionModel] = []
    private let service = DrugPrescriptionService()
    
    init() {
        loadPrescriptions()
    }
    
    func loadPrescriptions() {
        prescriptions = service.getAllPrescriptions()
    }
    
    func addPrescription(name: String, dosage: Int64) {
        let model = DrugPrescriptionModel(
            uuid: UUID(),
            name: name,
            dailyDosage: dosage
        )
        service.savePrescription(prescription: model)
        loadPrescriptions()
    }
    
    func deletePrescription(_ prescription: DrugPrescriptionModel) {
        service.deletePrescription(prescription)
        loadPrescriptions()
    }
    
    func updatePrescription(_ prescription: DrugPrescriptionModel) {
        service.updatePrescription(prescription)
        loadPrescriptions()
    }
} 