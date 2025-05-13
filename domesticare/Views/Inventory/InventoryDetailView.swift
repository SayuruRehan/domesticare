import SwiftUI
import Vision

struct InventoryDetailView: View {
    @EnvironmentObject private var inventoryStore: InventoryStore
    let item: DrugInventoryModel
    @State private var isEditing = false
    @State private var showingDeleteAlert = false
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var recognizedText: String = ""
    @State private var isProcessingImage = false
    
    private let ocrService = OCRService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let imageData = item.snapshot,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 300)
                        .cornerRadius(15)
                        .onTapGesture {
                            selectedImage = uiImage
                            processImage()
                        }
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Quantity")
                            .foregroundColor(.orange)
                            .font(.headline)
                        Spacer()
                        Text("\(item.remainingQuantity) remaining")
                            .font(.title2)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(10)
                    
                    if !recognizedText.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Detected Text")
                                .font(.headline)
                            Text(recognizedText)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                    
                    if isEditing {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(item.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                inventoryStore.deleteInventory(item)
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
        .overlay {
            if isProcessingImage {
                ProgressView("Processing Image...")
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
    }
    
    private func processImage() {
        guard let image = selectedImage else { return }
        
        isProcessingImage = true
        ocrService.detectText(in: image) { result in
            isProcessingImage = false
            
            switch result {
            case .success(let text):
                recognizedText = text
            case .failure(let error):
                print("OCR Error: \(error)")
                recognizedText = "Failed to detect text"
            }
        }
    }
}

struct InventoryEditView: View {
    enum Mode {
        case add
        case edit(DrugInventoryModel)
    }
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var inventoryStore: InventoryStore
    
    let mode: Mode
    @State private var name: String = ""
    @State private var quantity: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        Form {
            Section {
                TextField("Drug Name", text: $name)
                    .textInputAutocapitalization(.words)
                
                TextField("Quantity", text: $quantity)
                    .keyboardType(.numberPad)
            }
            
            Section {
                Button(action: { showingImagePicker = true }) {
                    HStack {
                        Text("Take Photo")
                        Spacer()
                        Image(systemName: "camera.fill")
                            .foregroundColor(.orange)
                    }
                }
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                }
            }
        }
        .navigationTitle(mode.isAdd ? "New Item" : "Edit Item")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    save()
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
        .onAppear {
            if case .edit(let item) = mode {
                name = item.name
                quantity = String(item.remainingQuantity)
                if let imageData = item.snapshot {
                    selectedImage = UIImage(data: imageData)
                }
            }
        }
    }
    
    private func save() {
        guard let quantityInt = Int64(quantity) else { return }
        
        switch mode {
        case .add:
            inventoryStore.addInventory(
                name: name,
                quantity: quantityInt,
                image: selectedImage?.pngData()
            )
        case .edit(let item):
            let updated = DrugInventoryModel(
                uuid: item.uuid,
                snapshot: selectedImage?.pngData(),
                name: name,
                expirationDate: item.expirationDate,
                originalQuantity: quantityInt,
                remainingQuantity: quantityInt
            )
            inventoryStore.updateInventory(updated)
        }
    }
}

extension InventoryEditView.Mode {
    var isAdd: Bool {
        if case .add = self { return true }
        return false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
} 