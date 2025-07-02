//
//  SettingsView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 26.06.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var globalRanges: GlobalParameterRanges

    var body: some View {
        Form {
            Section(header: Text("Globale Sollwerte")) {
                ParameterRangeEditor(name: "pH", range: $globalRanges.pH)
                ParameterRangeEditor(name: "Nitrit (mg/l)", range: $globalRanges.nitrit)
                ParameterRangeEditor(name: "Nitrat (mg/l)", range: $globalRanges.nitrat)
                ParameterRangeEditor(name: "KH (°dH)", range: $globalRanges.kh)
                ParameterRangeEditor(name: "GH (°dH)", range: $globalRanges.gh)
            }
        }
        .navigationTitle("Einstellungen")
    }
}

struct ParameterRangeEditor: View {
    let name: String
    @Binding var range: ParameterRange

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
            HStack {
                TextField("Min", value: $range.min, format: .number)
                    .textFieldStyle(.roundedBorder)
                Text("-")
                TextField("Max", value: $range.max, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}
