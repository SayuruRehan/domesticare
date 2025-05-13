import SwiftUI

struct InventoryListView: View {
    @EnvironmentObject private var inventoryStore: InventoryStore
    @State private var isAddingInventory = false
    @State private var isEditing = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(inventoryStore.inventory) { item in
                        NavigationLink(destination: InventoryDetailView(item: item)) {
                            InventoryItemView(item: item)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingInventory = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingInventory) {
                NavigationView {
                    InventoryEditView(mode: .add)
                }
            }
        }
    }
}

struct InventoryItemView: View {
    let item: DrugInventoryModel
    
    var body: some View {
        VStack {
            if let imageData = item.snapshot,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
            } else {
                Image(systemName: "pills.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .foregroundColor(.orange)
                    .padding()
            }
            
            Text(item.name)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            
            Text("\(item.remainingQuantity) remaining")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
} 