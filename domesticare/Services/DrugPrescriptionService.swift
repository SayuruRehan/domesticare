import Foundation
import CoreData

protocol DrugPrescriptionServiceProvider {
    func getAllPrescriptions() -> [DrugPrescriptionModel]
    func savePrescription(prescription: DrugPrescriptionModel)
    func updatePrescription(_ prescription: DrugPrescriptionModel)
    func deletePrescription(_ prescription: DrugPrescriptionModel)
}

class DrugPrescriptionService: DrugPrescriptionServiceProvider {
    private let context: NSManagedObjectContext
    
    init() {
        self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func getAllPrescriptions() -> [DrugPrescriptionModel] {
        let request: NSFetchRequest<DrugPrescription> = DrugPrescription.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let prescriptions = try context.fetch(request)
            return prescriptions.map { prescription in
                DrugPrescriptionModel(
                    uuid: prescription.uuid ?? UUID(),
                    name: prescription.name ?? "",
                    dailyDosage: prescription.dailyDosage
                )
            }
        } catch {
            print("Error fetching prescriptions: \(error)")
            return []
        }
    }
    
    func savePrescription(prescription: DrugPrescriptionModel) {
        let newPrescription = DrugPrescription(context: context)
        newPrescription.uuid = prescription.uuid
        newPrescription.name = prescription.name
        newPrescription.dailyDosage = prescription.dailyDosage
        
        do {
            try context.save()
        } catch {
            print("Error saving prescription: \(error)")
        }
    }
    
    func updatePrescription(_ prescription: DrugPrescriptionModel) {
        let request: NSFetchRequest<DrugPrescription> = DrugPrescription.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", prescription.uuid as CVarArg)
        
        do {
            let prescriptions = try context.fetch(request)
            if let existingPrescription = prescriptions.first {
                existingPrescription.name = prescription.name
                existingPrescription.dailyDosage = prescription.dailyDosage
                try context.save()
            }
        } catch {
            print("Error updating prescription: \(error)")
        }
    }
    
    func deletePrescription(_ prescription: DrugPrescriptionModel) {
        let request: NSFetchRequest<DrugPrescription> = DrugPrescription.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", prescription.uuid as CVarArg)
        
        do {
            let prescriptions = try context.fetch(request)
            if let existingPrescription = prescriptions.first {
                context.delete(existingPrescription)
                try context.save()
            }
        } catch {
            print("Error deleting prescription: \(error)")
        }
    }
} 