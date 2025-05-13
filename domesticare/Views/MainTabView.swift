import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PrescriptionListView()
                .tabItem {
                    Label("Prescriptions", systemImage: "list.bullet.clipboard.fill")
                }
            
            InventoryListView()
                .tabItem {
                    Label("Inventory", systemImage: "cross.case.fill")
                }
        }
        .tint(.red)
    }
} 