//
//  TestFormView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 18.07.25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PflanzenFormView: View {
    @Environment(\.presentationMode) var presentationMode

    @Query private var allAquariums: [Aquarium]
    @State private var selectedAquarium: Aquarium
    @State private var name: String
    @State private var art: String
    @State private var plantedDate: Date
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [Data]

    var pflanze: Pflanze?
    var onSave: (Pflanze) -> Void

    init(aquarium: Aquarium, pflanze: Pflanze? = nil, onSave: @escaping (Pflanze) -> Void = { _ in }) {
        self.pflanze = pflanze
        _selectedAquarium = State(initialValue: pflanze?.aquarium ?? aquarium)
        _name = State(initialValue: pflanze?.name ?? "")
        _art = State(initialValue: pflanze?.art ?? "")
        _plantedDate = State(initialValue: pflanze?.plantedDate ?? Date())
        _images = State(initialValue: pflanze?.images ?? [])
        self.onSave = onSave
    }

    var body: some View {
#if os(iOS)
        // iOS bleibt unverändert, Panel-Design wäre hier separat möglich!
        NavigationView {
            Form {
                Section(header: Text("Allgemein")) {
                    TextField("Name", text: $name)
                    TextField("Art", text: $art)
                    DatePicker("Eingepflanzt am", selection: $plantedDate, displayedComponents: .date)
                    Picker("Aquarium", selection: $selectedAquarium) {
                        ForEach(allAquariums) { aquarium in
                            Text(aquarium.name).tag(aquarium)
                        }
                    }
                }
                Section(header: Text("Fotos")) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 28)
                                .foregroundColor(.accentColor)
                            Text("Fotos auswählen")
                                .font(.body)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .onChange(of: selectedItems) { _, newItems in
                        Task {
                            var updatedImages: [Data] = []
                            for item in newItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    updatedImages.append(data)
                                }
                            }
                            images = updatedImages
                        }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(images, id: \.self) { imageData in
                                if let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .frame(height: 70)
                    }
                }
            }
            .navigationBarTitle(pflanze == nil ? "Neue Pflanze" : "Pflanze bearbeiten", displayMode: .inline)
            .navigationBarItems(trailing: Button("Speichern") {
                speichern()
            })
        }
#elseif os(macOS)
        ZStack {
            Color(.windowBackgroundColor)
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text(pflanze == nil ? "Neue Pflanze" : "Pflanze bearbeiten")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Allgemein")
                            .font(.headline)
                            .padding(.bottom, 4)
                        TextField("Name", text: $name)
                        TextField("Art", text: $art)
                        DatePicker("Eingepflanzt am", selection: $plantedDate, displayedComponents: .date)
                        Picker("Aquarium", selection: $selectedAquarium) {
                            ForEach(allAquariums) { aquarium in
                                Text(aquarium.name).tag(aquarium)
                            }
                        }
                        Text("Fotos")
                            .font(.headline)
                            .padding(.top, 16)
                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: 10,
                            matching: .images
                        ) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 28)
                                    .foregroundColor(.accentColor)
                                Text("Fotos auswählen")
                                    .font(.body)
                                    .foregroundColor(.accentColor)
                            }
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onChange(of: selectedItems) { _, newItems in
                            Task {
                                var updatedImages: [Data] = []
                                for item in newItems {
                                    if let data = try? await item.loadTransferable(type: Data.self) {
                                        updatedImages.append(data)
                                    }
                                }
                                images = updatedImages
                            }
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(images, id: \.self) { imageData in
                                    if let nsImage = NSImage(data: imageData) {
                                        Image(nsImage: nsImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 64, height: 64)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                            .frame(height: 70)
                        }
                    }
                        HStack(spacing: 20) {
                            Button("Abbrechen") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .frame(maxWidth: .infinity)
                            .buttonStyle(.bordered)

                            Button("Speichern") {
                                speichern()
                            }
                            .frame(maxWidth: .infinity)
                            .keyboardShortcut(.defaultAction)
                        }
                        .padding(.top, 24)
                    }
                    .padding(32)
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(24)
                    .shadow(radius: 24)
                    .frame(maxWidth: 400)
                }
                .padding(32)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(24)
                .shadow(radius: 24)
                .frame(maxWidth: 480)
            }
        
#endif
    }

    private func speichern() {
        if let pflanze = pflanze {
            pflanze.name = name
            pflanze.art = art
            pflanze.plantedDate = plantedDate
            pflanze.images = images
            pflanze.aquarium = selectedAquarium
            onSave(pflanze)
            presentationMode.wrappedValue.dismiss()
        } else {
            let neuePflanze = Pflanze(name: name, art: art, plantedDate: plantedDate, aquarium: selectedAquarium, images: images)
            onSave(neuePflanze)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
