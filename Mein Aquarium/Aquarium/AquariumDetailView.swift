//
//  AquariumDetailView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 28.06.25.
//

import SwiftUI
import SwiftData
import Charts

struct AquariumDetailView: View {
    var aquarium: Aquarium

    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\WaterParameter.date, order: .reverse)])
    private var allWaterParameters: [WaterParameter]

    @State private var showAddWaterParameter = false
    @State private var selectedParameter: String = "pH"
    let parameterOptions = ["pH", "Nitrit", "Nitrat", "KH", "GH"]
    
    @State private var editingParameter: WaterParameter?
    @State private var showEditParameterSheet = false
    @State private var selectedTestDetail: WaterParameter?

    // Hilfsfunktion, um WaterParameters für das aktuelle Aquarium zu filtern
    func belongsToThisAquarium(_ param: WaterParameter) -> Bool {
        guard let paramAquarium = param.aquarium else { return false }
        return paramAquarium.id == aquarium.id
    }

    // Gefilterte WaterParameters
    var filteredParameters: [WaterParameter] {
        allWaterParameters.filter { belongsToThisAquarium($0) }
    }
    
    func value(for parameter: String, in param: WaterParameter) -> Double? {
        switch parameter {
        case "pH":
            return param.ph
        case "Nitrit":
            return param.nitrit
        case "Nitrat":
            return param.nitrat
        case "KH":
            return param.kh
        case "GH":
            return param.gh
        default:
            return nil
        }
    }
    
    @EnvironmentObject var globalRanges: GlobalParameterRanges

    func minMax(for parameter: String) -> (Double?, Double?) {
        switch parameter {
        case "pH":
            return (globalRanges.pH.min, globalRanges.pH.max)
        case "Nitrit":
            return (globalRanges.nitrit.min, globalRanges.nitrit.max)
        case "Nitrat":
            return (globalRanges.nitrat.min, globalRanges.nitrat.max)
        case "KH":
            return (globalRanges.kh.min, globalRanges.kh.max)
        case "GH":
            return (globalRanges.gh.min, globalRanges.gh.max)
        default:
            return (nil, nil)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Maße
                HStack(spacing: 15) {
                    Label("\(aquarium.width, specifier: "%.0f") cm", systemImage: "arrow.left.and.right")
                    Label("\(aquarium.height, specifier: "%.0f") cm", systemImage: "arrow.up.and.down")
                    Label("\(aquarium.depth, specifier: "%.0f") cm", systemImage: "ruler")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                // Liter
                Text("\(aquarium.liters, specifier: "%.1f") Liter")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Parameter-Auswahl (Picker)
                Picker("Parameter", selection: $selectedParameter) {
                    ForEach(parameterOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.bottom, 10)
                
                // Chart-Bereich: Immer sichtbar, zeigt Platzhalter bei fehlenden Werten, sonst LineMark + PointMark + Sollwertlinien
                ZStack {
                    if filteredParameters.contains(where: { value(for: selectedParameter, in: $0) != nil }) {
                        Chart {
                            // Messwerte als Linie/Punkte
                            ForEach(filteredParameters) { param in
                                if let value = value(for: selectedParameter, in: param) {
                                    LineMark(
                                        x: .value("Datum", param.date),
                                        y: .value(selectedParameter, value)
                                    )
                                    PointMark(
                                        x: .value("Datum", param.date),
                                        y: .value(selectedParameter, value)
                                    )
                                }
                            }
                            // Sollbereich als RuleMark (Hilfslinie)
                            if let min = minMax(for: selectedParameter).0 {
                                RuleMark(y: .value("Minimum", min))
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundStyle(Color.green.opacity(0.5))
                            }
                            if let max = minMax(for: selectedParameter).1 {
                                RuleMark(y: .value("Maximum", max))
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundStyle(Color.red.opacity(0.5))
                            }
                        }
                        .frame(height: 200)
                        .chartXAxisLabel("Datum")
                        .chartYAxisLabel("Wert")
                    } else {
                        Rectangle()
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 200)
                            .overlay(
                                Text("Noch keine Werte für \(selectedParameter) eingetragen")
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                .padding(.bottom, 10)

                // Liste der einzelnen Messungen – pro Test alle Werte in einer Zeile unterhalb des Charts
                List(filteredParameters.prefix(20), id: \.id) { param in
                    VStack(alignment: .leading) {
                        Text(param.date, style: .date)
                            .font(.headline)
                        HStack {
                            if let ph = param.ph {
                                Text("pH: \(ph, specifier: "%.2f")")
                            }
                            if let kh = param.kh {
                                Text("KH: \(kh, specifier: "%.2f")")
                            }
                            if let gh = param.gh {
                                Text("GH: \(gh, specifier: "%.2f")")
                            }
                            
                        }
                        HStack {
                            if let nitrat = param.nitrat {
                                Text("Nitrat: \(nitrat, specifier: "%.2f")")
                            }
                            if let nitrit = param.nitrit {
                                Text("Nitrit: \(nitrit, specifier: "%.2f")")
                            }
                        }
                        HStack {
                            if let note = param.note, !note.isEmpty {
                                Text("Notitz: \(note)")
                            }
                        }
                        .font(.subheadline)
                    }
                    .onTapGesture {
                        selectedTestDetail = param
                    }
                }
                .frame(height: 170)
                .listStyle(.plain)
                
                Button {
                    showAddWaterParameter = true
                } label: {
                    Label("Neuen Wasserwert eintragen", systemImage: "plus")
                }
                .sheet(isPresented: $showAddWaterParameter) {
                    TestFormView(aquarium: aquarium)
                }
                
                // Platzhalter für Bewohner und Pflanzen
                Text("Bewohner")
                    .font(.headline)
                    .padding(.top, 10)
                Text("Hier kommen später die Bewohner rein.")
                
                Text("Pflanzen")
                    .font(.headline)
                    .padding(.top, 10)
                Text("Hier kommen später die Pflanzen rein.")
                
                Spacer()
                
                // Bild
                if let imageData = aquarium.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.bottom, 10)
                }
            }
            .padding()
        }
        .navigationTitle(aquarium.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedTestDetail) { test in
            VStack(spacing: 18) {
                Text("Details zur Messung")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(test.date, style: .date)
                    .font(.headline)
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    if let ph = test.ph {
                        Text("pH: \(ph, specifier: "%.2f")")
                    }
                    if let nitrit = test.nitrit {
                        Text("Nitrit: \(nitrit, specifier: "%.2f")")
                    }
                    if let nitrat = test.nitrat {
                        Text("Nitrat: \(nitrat, specifier: "%.2f")")
                    }
                    if let kh = test.kh {
                        Text("KH: \(kh, specifier: "%.2f")")
                    }
                    if let gh = test.gh {
                        Text("GH: \(gh, specifier: "%.2f")")
                    }
                    if let note = test.note, !note.isEmpty {
                        Divider()
                        Text("Notiz: \(note)")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .font(.title3)
                Divider()
                HStack {
                    Button {
                        editingParameter = test
                        showEditParameterSheet = true
                        selectedTestDetail = nil
                    } label: {
                        Label("Bearbeiten", systemImage: "pencil")
                    }
                    .buttonStyle(.borderedProminent)
                    Button(role: .destructive) {
                        modelContext.delete(test)
                        selectedTestDetail = nil
                    } label: {
                        Label("Löschen", systemImage: "trash")
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showEditParameterSheet) {
            if let editingParameter = editingParameter {
                TestFormView(aquarium: aquarium, parameterToEdit: editingParameter)
            }
        }
    }
}
