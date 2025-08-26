import SwiftUI
import SwiftData

struct BewohnerView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var aquariums: [Aquarium]

    @State private var showEditView = false
    @State private var selectedAquariumForAddID: UUID? = nil
    @State private var showAquariumSelectSheet = false
    @State private var bearbeitenBewohner: Bewohner?
    @State private var aquariumForForm: Aquarium? = nil
    @State private var showAddBewohnerFormSheet = false

    @State private var selectedAquariumFilterID: UUID? = nil
    @State private var selectedArtFilter: String? = nil

    private var alleArten: [String] {
        let arten = aquariums.flatMap { $0.bewohner ?? [] }.map { $0.art }
        return Array(Set(arten)).sorted()
    }

    private func gefilterteBewohner() -> [Bewohner] {
        aquariums.flatMap { $0.bewohner ?? [] }.filter { bewohner in
            let aquariumID = bewohner.aquarium?.id
            let idMatch = selectedAquariumFilterID == nil || aquariumID == selectedAquariumFilterID
            let artMatch = selectedArtFilter == nil || bewohner.art == selectedArtFilter
            return idMatch && artMatch
        }
    }

    // Dynamische Spalten (min/max Breite einstellen)
    private func adaptiveColumns(_ width: CGFloat) -> [GridItem] {
        let minCardWidth: CGFloat = 270  // Optimal wie im App Store
        let spacing: CGFloat = 28        // Abstand wie im App Store
        let columns = max(1, Int((width - spacing) / (minCardWidth + spacing)))
        return Array(repeating: GridItem(.flexible(minimum: minCardWidth, maximum: 350), spacing: spacing, alignment: .top), count: columns)
    }

    // MARK: - FilterBar
    private func filterBar() -> some View {
        HStack(spacing: 16) {
            Picker("Aquarium", selection: $selectedAquariumFilterID) {
                Text("Alle Aquarien").tag(nil as UUID?)
                ForEach(aquariums) { aquarium in
                    Text(aquarium.name).tag(Optional(aquarium.id))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 200)

            Picker("Art", selection: $selectedArtFilter) {
                Text("Alle Arten").tag(nil as String?)
                ForEach(alleArten, id: \.self) { art in
                    Text(art).tag(Optional(art))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 200)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }

    // MARK: - BewohnerGrid
    private func bewohnerGrid(_ width: CGFloat) -> some View {
        LazyVGrid(columns: adaptiveColumns(width), alignment: .leading, spacing: 30) {
            ForEach(gefilterteBewohner()) { bewohner in
                NavigationLink(destination: BewohnerDetailView(bewohner: bewohner)) {
                    BewohnerCardView(bewohner: bewohner)
                        .frame(maxWidth: 320) // Limitiere Kartenbreite
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.leading, 40)
        .padding(.trailing, 20)
        .padding(.bottom, 40)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        filterBar()
                        bewohnerGrid(geo.size.width)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Bewohner")
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if aquariums.count == 1, let onlyAquarium = aquariums.first {
                            aquariumForForm = onlyAquarium
                            showAddBewohnerFormSheet = true
                        } else if aquariums.count > 1 {
                            selectedAquariumForAddID = nil
                            showAquariumSelectSheet = true
                        }
                    } label: {
                        Image("fish.plus")
                    }
                    .disabled(aquariums.isEmpty)
                }
            }
#else
            .toolbar {
                ToolbarItem {
                    Button {
                        if aquariums.count == 1, let onlyAquarium = aquariums.first {
                            aquariumForForm = onlyAquarium
                            showAddBewohnerFormSheet = true
                        } else if aquariums.count > 1 {
                            selectedAquariumForAddID = nil
                            showAquariumSelectSheet = true
                        }
                    } label: {
                        Image("fish.plus")
                    }
                    .disabled(aquariums.isEmpty)
                }
            }
#endif
            .sheet(isPresented: $showAddBewohnerFormSheet, onDismiss: { aquariumForForm = nil }) {
                if let aquarium = aquariumForForm {
                    BewohnerFormView(aquarium: aquarium, onSave: { neuerBewohner in
                        if let aquarium = aquariumForForm {
                            neuerBewohner.aquarium = aquarium
                            modelContext.insert(neuerBewohner)
                            try? modelContext.save()
                        }
                        showAddBewohnerFormSheet = false
                    })
                    .frame(minWidth: 400, minHeight: 300)
                } else {
                    Text("Kein Aquarium ausgewählt.")
                        .frame(minWidth: 400, minHeight: 300)
                }
            }
            .sheet(isPresented: $showEditView) {
                if let bewohner = bearbeitenBewohner {
                    if let aquarium = bewohner.aquarium {
                        BewohnerFormView(aquarium: aquarium, bewohner: bewohner, onSave: { updatedBewohner in
                            // Update logic if needed
                            showEditView = false
                        })
                    } else {
                        Text("Aquarium nicht verfügbar.")
                            .frame(minWidth: 400, minHeight: 300)
                    }
                } else {
                    Text("Bewohner nicht verfügbar.")
                        .frame(minWidth: 400, minHeight: 300)
                }
            }
            .sheet(isPresented: $showAquariumSelectSheet) {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("Zu welchem Aquarium möchtest du einen Bewohner hinzufügen?")
                            .font(.headline)
                            .padding(.top)
                        Picker("Aquarium", selection: $selectedAquariumForAddID) {
                            Text("Bitte wählen").tag(nil as UUID?)
                            ForEach(aquariums) { aquarium in
                                Text(aquarium.name).tag(Optional(aquarium.id))
                            }
                        }
#if os(iOS)
                        .pickerStyle(.wheel)
#endif
                        .padding(.horizontal)
                        Button(action: {
                            if let selectedID = selectedAquariumForAddID {
                                aquariumForForm = aquariums.first(where: { $0.id == selectedID })
                            }
                            showAquariumSelectSheet = false
                        }) {
                            Text("Weiter")
                        }
                        .disabled(selectedAquariumForAddID == nil)
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .padding()
                    .navigationTitle("Aquarium wählen")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Abbrechen") {
                                showAquariumSelectSheet = false
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: aquariumForForm) { oldValue, newValue in
            if newValue != nil {
                showAddBewohnerFormSheet = true
            }
        }
    }
}

