//
//  SettingsView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 26.06.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var globalRanges: GlobalParameterRanges
    @AppStorage("useDarkMode") private var useDarkMode = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Globale Parameter Card
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Image(systemName: "aqi.medium")
                            .font(.title2).foregroundColor(.accentColor)
                        Text("Globale Sollwerte")
                            .font(.title2.bold())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    ForEach(parameterEditors.indices, id: \.self) { index in
                        parameterEditors[index].1
                    }
                }
                .padding(24)
                .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.systemBackground.opacity(0.7)))
                .shadow(radius: 16, y: 8)
                
                // Zusätzliche Einstellungen Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "gearshape.2")
                            .font(.title2).foregroundColor(.accentColor)
                        Text("App-Einstellungen")
                            .font(.title2.bold())
                    }
                    Divider()

                    Toggle(isOn: $useDarkMode) {
                        Label("Dunkelmodus verwenden", systemImage: "moon.fill")
                    }
                    
                    Button(role: .destructive) {
                        resetSettings()
                    } label: {
                        Label("Alle Einstellungen zurücksetzen", systemImage: "arrow.counterclockwise")
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .background(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color.systemBackground.opacity(0.7)))
                .shadow(radius: 8, y: 4)
            }
            .padding(.vertical, 36)
            .padding(.horizontal, 12)
            .frame(maxWidth: 580)
            .frame(maxWidth: .infinity)
        }
        .background(Color.systemBackground.ignoresSafeArea())
        .navigationTitle("Einstellungen")
    }
    
    // MARK: - Helper
    
    private var parameterEditors: [(String, AnyView)] {
        [
            ("pH", AnyView(ParameterRangeEditor(name: "pH", range: $globalRanges.pH))),
            ("Nitrit", AnyView(ParameterRangeEditor(name: "Nitrit (mg/l)", range: $globalRanges.nitrit))),
            ("Nitrat", AnyView(ParameterRangeEditor(name: "Nitrat (mg/l)", range: $globalRanges.nitrat))),
            ("KH", AnyView(ParameterRangeEditor(name: "KH (°dH)", range: $globalRanges.kh))),
            ("GH", AnyView(ParameterRangeEditor(name: "GH (°dH)", range: $globalRanges.gh)))
        ]
    }
    
    private func resetSettings() {
        globalRanges.pH = ParameterRange(min: 6.5, max: 7.5)
        globalRanges.nitrit = ParameterRange(min: 0.0, max: 0.2)
        globalRanges.nitrat = ParameterRange(min: 0.0, max: 25.0)
        globalRanges.kh = ParameterRange(min: 4.0, max: 8.0)
        globalRanges.gh = ParameterRange(min: 6.0, max: 12.0)
        useDarkMode = false
    }
}

struct ParameterRangeEditor: View {
    let name: String
    @Binding var range: ParameterRange

    var body: some View {
        HStack(spacing: 12) {
            Text(name).frame(width: 110, alignment: .leading)
            TextField("Min", value: $range.min, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)
            Text("-")
            TextField("Max", value: $range.max, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)
        }
        .font(.body)
        .padding(.vertical, 4)
    }
}

