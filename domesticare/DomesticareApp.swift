import SwiftUI
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "domesticare")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

@main
struct DomesticareApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var prescriptionStore: DrugPrescriptionStore
    @StateObject private var inventoryStore: InventoryStore
    
    init() {
        let context = persistenceController.container.viewContext
        _prescriptionStore = StateObject(wrappedValue: DrugPrescriptionStore(context: context))
        _inventoryStore = StateObject(wrappedValue: InventoryStore(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(prescriptionStore)
                .environmentObject(inventoryStore)
        }
    }
} 