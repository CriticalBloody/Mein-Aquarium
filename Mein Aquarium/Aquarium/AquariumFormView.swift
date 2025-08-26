//
//  AquariumFormView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 28.06.25.
//

import SwiftUI
import SwiftData
import PhotosUI
#if os(macOS)
import AppKit
#endif

struct AquariumFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext

    @State private var name: String
    @State private var width: Double
    @State private var height: Double
    @State private var depth: Double
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var image: Data?

    var aquarium: Aquarium?
    var onSave: (Aquarium) -> Void

    init(aquarium: Aquarium? = nil, onSave: @escaping (Aquarium) -> Void = { _ in }) {
        self.aquarium = aquarium
        _name = State(initialValue: aquarium?.name ?? "")
        _width = State(initialValue: aquarium?.width ?? 0)
        _height = State(initialValue: aquarium?.height ?? 0)
        _depth = State(initialValue: aquarium?.depth ?? 0)
        _image = State(initialValue: aquarium?.image ?? nil)
        self.onSave = onSave
    }

    private var platformBackground: Color {
    #if os(macOS)
        Color(NSColor.windowBackgroundColor)
    #else
        Color(.systemBackground)
    #endif
    }

    var body: some View {
    #if os(iOS)
        Form {
            Section(header: Text("Allgemein")) {
                TextField("Name", text: $name)
                HStack {
                    TextField("Breite (cm)", value: $width, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                    TextField("Höhe (cm)", value: $height, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                    TextField("Tiefe (cm)", value: $depth, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
            }
            Section(header: Text("Foto")) {
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 1,
                    matching: .images
                ) {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text(image == nil ? "Foto auswählen" : "Foto ersetzt")
                    }
                }
                .onChange(of: selectedItems) {
                    Task {
                        if let firstItem = selectedItems.first,
                           let data = try? await firstItem.loadTransferable(type: Data.self) {
                            image = data
                        }
                    }
                }
                if let imageData = image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            Section {
                HStack {
                    Button("Abbrechen") { presentationMode.wrappedValue.dismiss() }
                        .buttonStyle(.bordered)
                    Button("Speichern") {
                        if let aquarium = aquarium {
                            aquarium.name = name
                            aquarium.width = width
                            aquarium.height = height
                            aquarium.depth = depth
                            aquarium.image = image
                            onSave(aquarium)
                        } else {
                            let neuesAquarium = Aquarium(name: name, width: width, height: height, depth: depth)
                            neuesAquarium.image = image
                            modelContext.insert(neuesAquarium)
                            onSave(neuesAquarium)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle(aquarium == nil ? "Aquarium hinzufügen" : "Aquarium bearbeiten")
    #elseif os(macOS)
        ZStack {
            platformBackground
                .ignoresSafeArea()
            MainFormContent(
                aquarium: aquarium,
                name: $name,
                width: $width,
                height: $height,
                depth: $depth,
                image: $image,
                selectedItems: $selectedItems,
                onSave: onSave,
                presentationMode: presentationMode,
                modelContext: modelContext
            )
        }
    #endif
    }

    struct MainFormContent: View {
        var aquarium: Aquarium?
        @Binding var name: String
        @Binding var width: Double
        @Binding var height: Double
        @Binding var depth: Double
        @Binding var image: Data?
        @Binding var selectedItems: [PhotosPickerItem]
        var onSave: (Aquarium) -> Void
        var presentationMode: Binding<PresentationMode>
        var modelContext: ModelContext

        private var platformBackground: Color {
        #if os(macOS)
            Color(NSColor.windowBackgroundColor)
        #else
            Color(.systemBackground)
        #endif
        }

        var body: some View {
            VStack(spacing: 20) {
                Text(aquarium == nil ? "Neues Aquarium" : "Aquarium bearbeiten")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                VStack(alignment: .leading, spacing: 24) {
                    GeneralSection(name: $name, width: $width, height: $height, depth: $depth)
                    PhotoSection(image: $image, selectedItems: $selectedItems)
                    ButtonSection(
                        onCancel: { presentationMode.wrappedValue.dismiss() },
                        onSave: {
                            if let aquarium = aquarium {
                                aquarium.name = name
                                aquarium.width = width
                                aquarium.height = height
                                aquarium.depth = depth
                                aquarium.image = image
                                onSave(aquarium)
                                presentationMode.wrappedValue.dismiss()
                            } else {
                                let neuesAquarium = Aquarium(name: name, width: width, height: height, depth: depth)
                                neuesAquarium.image = image
                                modelContext.insert(neuesAquarium)
                                onSave(neuesAquarium)
                                presentationMode.wrappedValue.dismiss()
                            }
                        })
                }
                .padding(32)
                .frame(maxWidth: 400)
                .background(platformBackground)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
            }
            .padding(32)
            .frame(maxWidth: 480)
            .background(platformBackground)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
        }
    }

    struct GeneralSection: View {
        @Binding var name: String
        @Binding var width: Double
        @Binding var height: Double
        @Binding var depth: Double
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Allgemein").font(.headline)
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: .infinity)
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Breite (cm)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Breite", value: $width, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Höhe (cm)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Höhe", value: $height, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Tiefe (cm)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        TextField("Tiefe", value: $depth, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                }
            }
        }
    }

    struct PhotoSection: View {
        @Binding var image: Data?
        @Binding var selectedItems: [PhotosPickerItem]

        private var previewImage: some View {
            Group {
            #if os(macOS)
                if let imageData = image, let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            #else
                if let imageData = image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            #endif
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Fotos").font(.headline).padding(.top, 12)
            #if os(iOS)
                PhotosPicker(
                    "Foto auswählen",
                    selection: $selectedItems,
                    maxSelectionCount: 1,
                    matching: .images
                )
                .onChange(of: selectedItems) {
                    Task {
                        if let firstItem = selectedItems.first,
                           let data = try? await firstItem.loadTransferable(type: Data.self) {
                            image = data
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            #else
                PhotosPicker(
                    "Foto auswählen",
                    selection: $selectedItems,
                    maxSelectionCount: 1
                )
                .onChange(of: selectedItems) {
                    Task {
                        if let firstItem = selectedItems.first,
                           let data = try? await firstItem.loadTransferable(type: Data.self) {
                            image = data
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            #endif
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        previewImage
                    }
                    .frame(height: 70)
                }
            }
        }
    }

    struct ButtonSection: View {
        var onCancel: () -> Void
        var onSave: () -> Void
        var body: some View {
            HStack(spacing: 20) {
                Button("Abbrechen") { onCancel() }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.bordered)
                    .tint(.gray)
                Button("Speichern") { onSave() }
                    .frame(maxWidth: .infinity)
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 12)
        }
    }

    private func speichern() {
        if let aquarium = aquarium {
            aquarium.name = name
            aquarium.width = width
            aquarium.height = height
            aquarium.depth = depth
            aquarium.image = image
            onSave(aquarium)
            presentationMode.wrappedValue.dismiss()
        } else {
            let neuesAquarium = Aquarium(name: name, width: width, height: height, depth: depth)
            neuesAquarium.image = image
            onSave(neuesAquarium)
            presentationMode.wrappedValue.dismiss()
        }
    }
}

