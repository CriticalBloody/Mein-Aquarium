//
//  AquariumMainView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 26.06.25.
//

import SwiftUI
import SwiftData

struct AquariumMainView: View {
    
    @Environment(\.modelContext) private var modelContext

    // SwiftData-Abfrage für Aquarien
    @Query private var aquariums: [Aquarium]

    // State-Variablen für Test-Sheets
    @State private var showTestSheet = false
    @State private var selectedAquariumForTest: Aquarium?
    @State private var showAddTestForm = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(aquariums) { aquarium in
                    NavigationLink(destination: AquariumDetailView(aquarium: aquarium)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(aquarium.name)
                                    .font(.headline)
                                Text("\(aquarium.liters, specifier: "%.1f") Liter")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            if let imageData = aquarium.image, let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .swipeActions {
                        NavigationLink(destination: AquariumFormView(aquarium: aquarium)) {
                            Label("Bearbeiten", systemImage: "pencil")
                        }
                        .tint(.blue)
                        Button(role: .destructive) {
                            modelContext.delete(aquarium)
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Meine Aquarien")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AquariumFormView(aquarium: Aquarium(name: "", width: 0, height: 0, depth: 0))) {
                        Label("Aquarium hinzufügen", systemImage: "plus")
                    }
                    Button {
                        if aquariums.count == 1, let onlyAquarium = aquariums.first {
                            selectedAquariumForTest = onlyAquarium
                            showAddTestForm = true
                        } else {
                            selectedAquariumForTest = nil
                            showTestSheet = true
                        }
                    } label: {
                        Label("Test hinzufügen", systemImage: "drop.fill")
                    }
                }
            }

            // Sheet für Aquarium-Auswahl, falls mehrere Aquarien
            .sheet(isPresented: $showTestSheet) {
                NavigationStack {
                    VStack(spacing: 20) {
                        Text("Zu welchem Aquarium möchtest du den neuen Test hinzufügen?")
                            .font(.headline)
                            .padding(.top)

                        Picker("Aquarium", selection: $selectedAquariumForTest) {
                            ForEach(aquariums) { aquarium in
                                Text(aquarium.name).tag(Optional(aquarium))
                            }
                        }
                        .pickerStyle(.wheel)
                        .padding(.horizontal)

                        Button("Weiter") {
                            showTestSheet = false
                            // Zeige dann das Testformular
                            showAddTestForm = true
                        }
                        .disabled(selectedAquariumForTest == nil)
                        .buttonStyle(.borderedProminent)

                        Spacer()
                    }
                    .padding()
                }
            }
            // Sheet für das Formular zur Eingabe der Wasserwerte
            .sheet(isPresented: $showAddTestForm) {
                if let selectedAquarium = selectedAquariumForTest {
                    TestFormView(aquarium: selectedAquarium)
                } else if aquariums.count == 1, let onlyAquarium = aquariums.first {
                    TestFormView(aquarium: onlyAquarium)
                } else {
                    Text("Kein Aquarium ausgewählt.")
                        .padding()
                }
            }
        }
    }
}

#Preview {
    AquariumFormView(aquarium: Aquarium(name: "Demo", width: 50, height: 40, depth: 30))
        .modelContainer(for: Aquarium.self, inMemory: true)
}
