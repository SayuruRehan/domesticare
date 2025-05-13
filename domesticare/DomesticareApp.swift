import SwiftUI

@main
struct DomesticareApp: App {
    @StateObject private var prescriptionStore = DrugPrescriptionStore()
    @StateObject private var inventoryStore = InventoryStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(prescriptionStore)
                .environmentObject(inventoryStore)
        }
    }
} 