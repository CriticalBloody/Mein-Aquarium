//
//  AquariumFormView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 28.06.25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AquariumFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var aquarium: Aquarium

    // Bilderauswahl
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section("Allgemeine Infos") {
                    TextField("Name", text: $aquarium.name)
                    HStack {
                        TextField("Breite (cm)", value: $aquarium.width, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                        TextField("Höhe (cm)", value: $aquarium.height, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                        TextField("Tiefe (cm)", value: $aquarium.depth, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section("Bild hinzufügen") {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Label("Bild auswählen", systemImage: "photo")
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                                aquarium.image = data
                            }
                        }
                    }
                }
            }
            .navigationTitle(aquarium.modelContext == nil ? "Neues Aquarium" : "Aquarium bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        if aquarium.modelContext == nil {
                            modelContext.insert(aquarium)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AquariumFormView(aquarium: Aquarium(name: "Demo", width: 50, height: 40, depth: 30))
        .modelContainer(for: Aquarium.self, inMemory: true)
}
