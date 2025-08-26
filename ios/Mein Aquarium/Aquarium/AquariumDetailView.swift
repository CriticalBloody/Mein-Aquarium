//
//  AquariumDetailView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 28.06.25.
//

import SwiftUI
import SwiftData
import Charts
#if os(iOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

struct AquariumDetailView: View {
    var aquarium: Aquarium
    @Binding var path: NavigationPath
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\WaterParameter.date, order: .reverse)])
    private var allWaterParameters: [WaterParameter]
    
    @State private var showAddWaterParameter = false
    @State private var selectedParameter: String = "pH"
    let parameterOptions = ["pH", "KH", "GH", "Nitrit", "Nitrat"]

    @State private var editingParameter: WaterParameter?
    @State private var showEditParameterSheet = false
    @State private var selectedTestDetail: WaterParameter?
    @State private var showTestListSheet = false

    @State private var showAddBewohnerSheet = false

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    @EnvironmentObject var globalRanges: GlobalParameterRanges
    
    // Hilfsfunktion, um WaterParameters für das aktuelle Aquarium zu filtern
    func belongsToThisAquarium(_ param: WaterParameter) -> Bool {
        guard let paramAquarium = param.aquarium else { return false }
        return paramAquarium.id == aquarium.id
    }
    
    // Gefilterte WaterParameters
    var filteredParameters: [WaterParameter] {
        return allWaterParameters.filter { belongsToThisAquarium($0) }
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
    
    func isValueOutsideRange(_ value: Double?, for parameter: String) -> Bool {
        guard let val = value else { return false }
        let range = minMax(for: parameter)
        if let min = range.0, val < min {
            return true
        }
        if let max = range.1, val > max {
            return true
        }
        return false
    }
    
    var hasValuesOutsideRange: Bool {
        filteredParameters.contains { param in
            let val = value(for: selectedParameter, in: param)
            return isValueOutsideRange(val, for: selectedParameter)
        }
    }
    
    // Aquarium-Info-Bereich
    private var aquariumInfoSection: some View {
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
        }
        .padding(.vertical, 10)
    }
    
    var body: some View {
        ZStack {
            // Hero-Background
            if let imageData = aquarium.image {
#if os(iOS)
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .blur(radius: 24)
                        .overlay(Color.black.opacity(0.45))
                        .ignoresSafeArea()
                }
#elseif os(macOS)
                if let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .blur(radius: 24)
                        .overlay(Color.black.opacity(0.45))
                        .ignoresSafeArea()
                }
#endif
            } else {
                Color(.black).ignoresSafeArea()
            }

            ScrollView {
                VStack(spacing: 0) {
                    // Hero/Card-Content
                    VStack(alignment: .leading, spacing: 18) {
                        // Titel und Hauptinfos
                        Text(aquarium.name)
                            .font(.largeTitle).fontWeight(.bold)
                            .foregroundStyle(.white)
                            .shadow(radius: 4)
                            .padding(.top, 40)
                            .padding(.bottom, 6)
                        aquariumInfoSection
                            .foregroundColor(.white.opacity(0.95))
                        // Bild als Card-Vorschau (hell)
#if os(iOS)
                        if let imageData = aquarium.image, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 180)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 8)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.2), lineWidth: 2))
                        }
#elseif os(macOS)
                        if let imageData = aquarium.image, let nsImage = NSImage(data: imageData) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, minHeight: 140, maxHeight: 180)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 8)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.2), lineWidth: 2))
                        }
#endif
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 18)
                    .padding(.bottom, 30)
                    .background(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 22)
                    )
                    .padding(.horizontal, 32)
                    .padding(.top, 38)

                    VStack(alignment: .leading, spacing: 28) {
                        Divider().opacity(0.1)
                        
                        VStack(spacing: 12) {
                            Picker("Parameter", selection: $selectedParameter) {
                                ForEach(parameterOptions, id: \.self) { option in
                                    Text(option)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            chartSection
                        }
                        .frame(maxWidth: 500)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 10)

                        if hasValuesOutsideRange {
                            Text("⚠️ Mindestens ein Wert außerhalb des Sollbereichs!")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.bottom, 4)
                                .padding(.horizontal, 16)
                        }

                        Text("Letzter Test")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 18)
                            .padding(.horizontal, 16)

                        Divider().opacity(0.1)
                            .padding(.horizontal, 16)

                        // Nur der letzte Test wird angezeigt
                        if let lastTest = filteredParameters.first {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(lastTest.date, style: .date)
                                    .font(.headline)
                                    .padding(.horizontal, 16)

                                HStack(spacing: 10) {
                                    if let ph = lastTest.ph {
                                        HStack(spacing: 4) {
                                            Text("pH:")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("\(ph, specifier: "%.2f")")
                                                .font(.body)
                                            if isValueOutsideRange(ph, for: "pH") {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.red)
                                                    .fontWeight(.semibold)
                                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                                            }
                                        }
                                    }
                                    if let kh = lastTest.kh {
                                        HStack(spacing: 4) {
                                            Text("KH:")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("\(kh, specifier: "%.2f")")
                                                .font(.body)
                                            if isValueOutsideRange(kh, for: "KH") {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.red)
                                                    .fontWeight(.semibold)
                                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                                            }
                                        }
                                    }
                                    if let gh = lastTest.gh {
                                        HStack(spacing: 4) {
                                            Text("GH:")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("\(gh, specifier: "%.2f")")
                                                .font(.body)
                                            if isValueOutsideRange(gh, for: "GH") {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.red)
                                                    .fontWeight(.semibold)
                                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)

                                HStack(spacing: 10) {
                                    if let nitrat = lastTest.nitrat {
                                        HStack(spacing: 4) {
                                            Text("Nitrat:")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("\(nitrat, specifier: "%.2f")")
                                                .font(.body)
                                            if isValueOutsideRange(nitrat, for: "Nitrat") {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.red)
                                                    .fontWeight(.semibold)
                                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                                            }
                                        }
                                    }
                                    if let nitrit = lastTest.nitrit {
                                        HStack(spacing: 4) {
                                            Text("Nitrit:")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text("\(nitrit, specifier: "%.2f")")
                                                .font(.body)
                                            if isValueOutsideRange(nitrit, for: "Nitrit") {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundColor(.red)
                                                    .fontWeight(.semibold)
                                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)

                                if let note = lastTest.note, !note.isEmpty {
                                    Text("Notiz:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.top, 4)
                                        .padding(.horizontal, 16)
                                    Text(note)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 16)
                                }
                            }
                            .onTapGesture {
                                selectedTestDetail = lastTest
                            }

                            Button {
                                showTestListSheet = true
                            } label: {
                                Text("Alle Messungen anzeigen")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 8)
                            .padding(.horizontal, 16)
                        } else {
                            Text("Noch keine Tests vorhanden. Bitte füge einen Test hinzu.")
                                .foregroundColor(.secondary)
                                .padding(.bottom, 6)
                                .padding(.horizontal, 16)
                        }

                        Text("Bewohner")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 28)
                            .padding(.horizontal, 16)

                        if (aquarium.bewohner ?? []).isEmpty {
                            Text("Noch keine Bewohner hinzugefügt.")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                        } else {
                            ForEach(aquarium.bewohner ?? []) { bewohner in
                                NavigationLink(destination: BewohnerDetailView(bewohner: bewohner)) {
                                    Text(bewohner.name)
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        Text("Pflanzen")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 28)
                            .padding(.horizontal, 16)
                        if (aquarium.pflanzen ?? []).isEmpty {
                            Text("Noch keine Pflanzen hinzugefügt.")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                        } else {
                            ForEach(aquarium.pflanzen ?? []) { pflanze in
                                NavigationLink(destination: PflanzenDetailView(pflanze: pflanze)) {
                                    Text(pflanze.name)
                                }
                                .padding(.horizontal, 16)
                            }
                        }

                        Spacer()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(radius: 22)
                    )
                    .frame(maxWidth: 500)
                    .padding(.horizontal, 32)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: 450)
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle(aquarium.name)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    showAddWaterParameter = true
                } label: {
                    Label {
                        Text("Test")
                    } icon: {
                        Image("test.plus")
                    }
                }
                Button {
                    showAddBewohnerSheet = true
                } label: {
                    Label {
                        Text("Bewohner")
                    } icon: {
                        Image("fish.plus")
                    }
                }
            }
            ToolbarItemGroup(placement: .secondaryAction) {
                Button {
                    showEditSheet = true
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                }
                Button(role: .destructive) {
                    showDeleteAlert = true
                } label: {
                    Label("Löschen", systemImage: "trash")
                }
            }
        }
        .sheet(isPresented: $showAddWaterParameter) {
            TestFormView(aquarium: aquarium)
        }
        .sheet(isPresented: $showTestListSheet) {
            TestsListView(tests: filteredParameters)
        }
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
                        HStack(spacing: 4) {
                            Text("pH:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(ph, specifier: "%.2f")")
                                .font(.body)
                            if isValueOutsideRange(ph, for: "pH") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                    }
                    if let kh = test.kh {
                        HStack(spacing: 4) {
                            Text("KH:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(kh, specifier: "%.2f")")
                                .font(.body)
                            if isValueOutsideRange(kh, for: "KH") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                    }
                    if let gh = test.gh {
                        HStack(spacing: 4) {
                            Text("GH:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(gh, specifier: "%.2f")")
                                .font(.body)
                            if isValueOutsideRange(gh, for: "GH") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                    }
                    if let nitrit = test.nitrit {
                        HStack(spacing: 4) {
                            Text("Nitrit:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(nitrit, specifier: "%.2f")")
                                .font(.body)
                            if isValueOutsideRange(nitrit, for: "Nitrit") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                    }
                    if let nitrat = test.nitrat {
                        HStack(spacing: 4) {
                            Text("Nitrat:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(nitrat, specifier: "%.2f")")
                                .font(.body)
                            if isValueOutsideRange(nitrat, for: "Nitrat") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .fontWeight(.semibold)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                    }
                    if let note = test.note, !note.isEmpty {
                        Divider()
                        Text("Notiz:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 2)
                        Text(note)
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
        .sheet(isPresented: $showAddBewohnerSheet) {
            BewohnerFormView(aquarium: aquarium) { newBewohner in
                modelContext.insert(newBewohner)
                showAddBewohnerSheet = false
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AquariumFormView(aquarium: aquarium)
        }
        .alert("Aquarium wirklich löschen?", isPresented: $showDeleteAlert, actions: {
            Button("Löschen", role: .destructive) {
                modelContext.delete(aquarium)
                try? modelContext.save()
                path.removeLast()
            }
            Button("Abbrechen", role: .cancel) {}
        }, message: {
            Text("Das Aquarium und alle zugehörigen Daten werden unwiderruflich gelöscht.")
        })
    }
    
    // Chart-Bereich als eigene Computed Property ausgelagert
    private var chartSection: some View {
        let chartData = Array(filteredParameters.prefix(20)).compactMap { param -> (date: Date, value: Double, isOutOfRange: Bool)? in
            if let v = value(for: selectedParameter, in: param) {
                return (param.date, v, isValueOutsideRange(v, for: selectedParameter))
            }
            return nil
        }
        return ZStack {
            if !chartData.isEmpty {
                Chart {
                    ForEach(Array(chartData.enumerated()), id: \.offset) { idx, entry in
                        LineMark(
                            x: .value("Datum", entry.date),
                            y: .value(selectedParameter, entry.value)
                        )
                        PointMark(
                            x: .value("Datum", entry.date),
                            y: .value(selectedParameter, entry.value)
                        )
                        .foregroundStyle(entry.isOutOfRange ? .red : .primary)
                        if entry.isOutOfRange {
                            PointMark(
                                x: .value("Datum", entry.date),
                                y: .value(selectedParameter, entry.value)
                            ).annotation(position: .top, alignment: .center) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .imageScale(.medium)
                            }
                        }
                    }
                    if let min = minMax(for: selectedParameter).0 {
                        RuleMark(y: .value("Minimum", min))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundStyle(Color.red.opacity(0.5))
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
#if os(iOS)
                    .fill(Color(.secondarySystemBackground))
#else
                    .fill(Color.gray.opacity(0.1))
#endif
                    .frame(height: 200)
                    .overlay(
                        Text("Noch keine Werte für \(selectedParameter) eingetragen")
                            .foregroundColor(.secondary)
                    )
            }
        }
        .padding(.bottom, 10)
    }
}
    
