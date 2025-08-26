import SwiftUI
import SwiftData
import PhotosUI

struct BewohnerFormView: View {
    @Environment(\.presentationMode) var presentationMode

    @Query private var allAquariums: [Aquarium]
    @State private var selectedAquarium: Aquarium
    @State private var name: String
    @State private var art: String
    @State private var birthDate: Date
    @State private var addedDate: Date
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var image: Data?

    var bewohner: Bewohner?
    var onSave: (Bewohner) -> Void

    init(aquarium: Aquarium, bewohner: Bewohner? = nil, onSave: @escaping (Bewohner) -> Void = { _ in }) {
        self.bewohner = bewohner
        _selectedAquarium = State(initialValue: bewohner?.aquarium ?? aquarium)
        _name = State(initialValue: bewohner?.name ?? "")
        _art = State(initialValue: bewohner?.art ?? "")
        _birthDate = State(initialValue: bewohner?.birthDate ?? Date())
        _addedDate = State(initialValue: bewohner?.addedDate ?? Date())
        _image = State(initialValue: bewohner?.images ?? nil)
        self.onSave = onSave
    }
    
    var body: some View {
#if os(iOS)
        NavigationView {
            Form {
                Section(header: Text("Allgemein")) {
                    TextField("Name", text: $name)
                    TextField("Art", text: $art)
                    DatePicker("Geboren am", selection: $birthDate, displayedComponents: .date)
                    DatePicker("Eingesetzt am", selection: $addedDate, displayedComponents: .date)
                    Picker("Aquarium", selection: $selectedAquarium) {
                        ForEach(allAquariums) { aquarium in
                            Text(aquarium.name).tag(aquarium)
                        }
                    }
                }
                Section(header: Text("Fotos")) {
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 1,
                        matching: .images
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 28)
                                .foregroundColor(.accentColor)
                            Text("Foto auswählen")
                                .font(.body)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .onChange(of: selectedItems) { _, newItems in
                        Task {
                            if let firstItem = newItems.first,
                               let data = try? await firstItem.loadTransferable(type: Data.self) {
                                image = data
                            }
                        }
                    }
                    
                    // *** Plattformgerechte Vorschau ***
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
#if os(iOS)
                            if let imageData = image,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
#elseif os(macOS)
                            if let imageData = image,
                               let nsImage = NSImage(data: imageData) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 64, height: 64)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
#endif
                        }
                        .frame(height: 70)
                    }
                }
            }
            .navigationBarTitle(bewohner == nil ? "Neuer Bewohner" : "Bewohner bearbeiten", displayMode: .inline)
            .navigationBarItems(trailing: Button("Speichern") {
                speichern()
            })
        }
#elseif os(macOS)
        ZStack {
            Color(.windowBackgroundColor)
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text(bewohner == nil ? "Neuer Bewohner" : "Bewohner bearbeiten")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Allgemein")
                            .font(.headline)
                            .padding(.bottom, 4)
                        TextField("Name", text: $name)
                        TextField("Art", text: $art)
                        DatePicker("Geboren am", selection: $birthDate, displayedComponents: .date)
                        DatePicker("Eingesetzt am", selection: $addedDate, displayedComponents: .date)
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
                            maxSelectionCount: 1,
                            matching: .images
                        ) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 28)
                                    .foregroundColor(.accentColor)
                                Text("Foto auswählen")
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
                                if let firstItem = newItems.first,
                                   let data = try? await firstItem.loadTransferable(type: Data.self) {
                                    image = data
                                }
                            }
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                if let imageData = image,
                                   let nsImage = NSImage(data: imageData) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 64, height: 64)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
        if let bewohner = bewohner {
            bewohner.name = name
            bewohner.art = art
            bewohner.birthDate = birthDate
            bewohner.addedDate = addedDate
            bewohner.images = image
            bewohner.aquarium = selectedAquarium
            onSave(bewohner)
            presentationMode.wrappedValue.dismiss()
        } else {
            let neuerBewohner = Bewohner(name: name, art: art, birthDate: birthDate, addedDate: addedDate, aquarium: selectedAquarium, id: UUID())
            neuerBewohner.images = image
            onSave(neuerBewohner)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
