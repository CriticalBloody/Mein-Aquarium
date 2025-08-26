//
//  PflanzenView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 26.06.25.
//

import SwiftUI
import SwiftData

struct PflanzenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var aquariums: [Aquarium]

    @State private var selectedAquariumFilterID: UUID? = nil
    @State private var selectedArtFilter: String? = nil
    @State private var showAddPflanzeSheet = false
    @State private var selectedAquariumForAdd: Aquarium? = nil
    @State private var showAquariumSelectSheet = false

    private var aktuellesAquariumFürAdd: Aquarium? {
        if let selected = selectedAquariumForAdd {
            return selected
        }
        if let filtered = aquariums.first(where: { $0.id == selectedAquariumFilterID }) {
            return filtered
        }
        return aquariums.first
    }

    // 1. Alle Arten extrahieren
    private var alleArten: [String] {
        let arten = aquariums.flatMap { $0.pflanzen ?? [] }.map { $0.art }
        return Array(Set(arten)).sorted()
    }

    // 2. Gefilterte Pflanzen ermitteln
    private func gefiltertePflanzen() -> [Pflanze] {
        aquariums.flatMap { $0.pflanzen ?? [] }.filter { pflanze in
            let aquariumID = pflanze.aquarium?.id
            let idMatch = selectedAquariumFilterID == nil || aquariumID == selectedAquariumFilterID
            let artMatch = selectedArtFilter == nil || pflanze.art == selectedArtFilter
            return idMatch && artMatch
        }
    }

    // 3. Adaptive Grid Columns
    private func adaptiveColumns(_ width: CGFloat) -> [GridItem] {
        let minCardWidth: CGFloat = 270
        let spacing: CGFloat = 28
        let columns = max(1, Int((width - spacing) / (minCardWidth + spacing)))
        return Array(repeating: GridItem(.flexible(minimum: minCardWidth, maximum: 350), spacing: spacing, alignment: .top), count: columns)
    }

    // 4. FilterBar
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

    // 5. PflanzenGrid
    private func pflanzenGrid(_ width: CGFloat) -> some View {
        LazyVGrid(columns: adaptiveColumns(width), alignment: .leading, spacing: 30) {
            ForEach(gefiltertePflanzen()) { pflanze in
                NavigationLink(destination: PflanzenDetailView(pflanze: pflanze)) {
                    PflanzenCardView(pflanze: pflanze)
                        .frame(maxWidth: 320)
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
                        pflanzenGrid(geo.size.width)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Pflanzen")
            .toolbar {
                ToolbarItem {
                    Button {
                        if aquariums.count == 1 {
                            selectedAquariumForAdd = aquariums.first
                            showAddPflanzeSheet = true
                        } else if aquariums.count > 1 {
                            selectedAquariumForAdd = nil
                            showAquariumSelectSheet = true
                        }
                    } label: {
                        Image("leaf.plus")
                    }
                }
            }
            .sheet(isPresented: $showAquariumSelectSheet) {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("Zu welchem Aquarium möchtest du eine Pflanze hinzufügen?")
                            .font(.headline)
                            .padding(.top)
                        Picker("Aquarium", selection: $selectedAquariumForAdd) {
                            Text("Bitte wählen").tag(nil as Aquarium?)
                            ForEach(aquariums) { aquarium in
                                Text(aquarium.name).tag(Optional(aquarium))
                            }
                        }
                        .padding(.horizontal)
                        Button(action: {
                            showAquariumSelectSheet = false
                            if selectedAquariumForAdd != nil {
                                showAddPflanzeSheet = true
                            }
                        }) {
                            Text("Weiter")
                        }
                        .disabled(selectedAquariumForAdd == nil)
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
            .sheet(isPresented: $showAddPflanzeSheet) {
                if let aquarium = aktuellesAquariumFürAdd {
                    PflanzenFormView(aquarium: aquarium) { neuePflanze in
                        neuePflanze.aquarium = aquarium // Stelle sicher, dass die Beziehung gesetzt ist
                        modelContext.insert(neuePflanze)
                        try? modelContext.save() // Speichere explizit
                        selectedAquariumFilterID = aquarium.id
                        selectedArtFilter = nil
                        selectedAquariumForAdd = nil
                        showAddPflanzeSheet = false
                    }
                    .frame(minWidth: 400, minHeight: 300)
                } else {
                    Text("Kein Aquarium vorhanden")
                        .frame(minWidth: 400, minHeight: 200)
                }
            }
        }
    }
}

