import SwiftUI

struct PrescriptionDetailView: View {
    @EnvironmentObject private var prescriptionStore: DrugPrescriptionStore
    let prescription: DrugPrescriptionModel
    @State private var isEditing = false
    
    var body: some View {
        VStack(spacing: 20) {
            if isEditing {
                PrescriptionEditView(mode: .edit(prescription))
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text(prescription.name)
                        .font(.title)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Pills per day")
                            .foregroundColor(.orange)
                            .font(.headline)
                        Spacer()
                        Text("\(prescription.dailyDosage)")
                            .font(.title2)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(isEditing ? "Edit Prescription" : prescription.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
            }
        }
    }
}

struct PrescriptionEditView: View {
    enum Mode {
        case add
        case edit(DrugPrescriptionModel)
    }
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var prescriptionStore: DrugPrescriptionStore
    
    let mode: Mode
    @State private var name: String = ""
    @State private var dosage: Int = 1
    
    private let dosageOptions = Array(1...9)
    
    var body: some View {
        Form {
            Section {
                TextField("Drug Name", text: $name)
                    .textInputAutocapitalization(.words)
                
                Picker("Pills per day", selection: $dosage) {
                    ForEach(dosageOptions, id: \.self) { number in
                        Text("\(number)").tag(number)
                    }
                }
            }
        }
        .navigationTitle(mode.isAdd ? "New Prescription" : "Edit Prescription")
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
        .onAppear {
            if case .edit(let prescription) = mode {
                name = prescription.name
                dosage = Int(prescription.dailyDosage)
            }
        }
    }
    
    private func save() {
        switch mode {
        case .add:
            prescriptionStore.addPrescription(name: name, dosage: Int64(dosage))
        case .edit(let prescription):
            let updated = DrugPrescriptionModel(
                uuid: prescription.uuid,
                name: name,
                dailyDosage: Int64(dosage)
            )
            prescriptionStore.updatePrescription(updated)
        }
    }
}

extension PrescriptionEditView.Mode {
    var isAdd: Bool {
        if case .add = self { return true }
        return false
    }
} 