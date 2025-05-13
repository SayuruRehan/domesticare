import SwiftUI

struct PrescriptionListView: View {
    @EnvironmentObject private var prescriptionStore: DrugPrescriptionStore
    @State private var isAddingPrescription = false
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(prescriptionStore.prescriptions) { prescription in
                    NavigationLink(destination: PrescriptionDetailView(prescription: prescription)) {
                        PrescriptionRowView(prescription: prescription)
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        prescriptionStore.deletePrescription(prescriptionStore.prescriptions[index])
                    }
                }
            }
            .navigationTitle("Prescriptions")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingPrescription = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingPrescription) {
                NavigationView {
                    PrescriptionEditView(mode: .add)
                }
            }
        }
    }
}

struct PrescriptionRowView: View {
    let prescription: DrugPrescriptionModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(prescription.name)
                .font(.headline)
            Text("\(prescription.dailyDosage) pills per day")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
} 