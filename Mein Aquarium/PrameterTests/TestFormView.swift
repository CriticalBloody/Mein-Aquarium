//
//  TestFormView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 01.07.25.
//

import SwiftUI
import SwiftData

struct TestFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var aquarium: Aquarium
    var parameterToEdit: WaterParameter?

    @State private var date: Date
    @State private var ph: String
    @State private var nitrit: String
    @State private var nitrat: String
    @State private var kh: String
    @State private var gh: String
    @State private var note: String     // <--- NEU

    init(aquarium: Aquarium, parameterToEdit: WaterParameter? = nil) {
        self.aquarium = aquarium
        self.parameterToEdit = parameterToEdit
        _date = State(initialValue: parameterToEdit?.date ?? Date())
        _ph = State(initialValue: parameterToEdit?.ph.map { "\($0)" } ?? "")
        _nitrit = State(initialValue: parameterToEdit?.nitrit.map { "\($0)" } ?? "")
        _nitrat = State(initialValue: parameterToEdit?.nitrat.map { "\($0)" } ?? "")
        _kh = State(initialValue: parameterToEdit?.kh.map { "\($0)" } ?? "")
        _gh = State(initialValue: parameterToEdit?.gh.map { "\($0)" } ?? "")
        _note = State(initialValue: parameterToEdit?.note ?? "")      // <--- NEU
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Datum", selection: $date, displayedComponents: .date)
                TextField("pH", text: $ph).keyboardType(.decimalPad)
                TextField("Nitrit (mg/l)", text: $nitrit).keyboardType(.decimalPad)
                TextField("Nitrat (mg/l)", text: $nitrat).keyboardType(.decimalPad)
                TextField("KH (°dH)", text: $kh).keyboardType(.decimalPad)
                TextField("GH (°dH)", text: $gh).keyboardType(.decimalPad)
                Section(header: Text("Notiz")) {
                    TextField("z.B. Wasserwechsel durchgeführt, Werte auffällig, ...", text: $note)
                }
            }
            .navigationTitle(parameterToEdit == nil ? "Wasserwerte eintragen" : "Wasserwerte bearbeiten")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        if let param = parameterToEdit {
                            param.date = date
                            param.ph = Double(ph)
                            param.nitrit = Double(nitrit)
                            param.nitrat = Double(nitrat)
                            param.kh = Double(kh)
                            param.gh = Double(gh)
                            param.note = note           // <--- NEU
                        } else {
                            let newParam = WaterParameter(
                                date: date,
                                ph: Double(ph),
                                nitrit: Double(nitrit),
                                nitrat: Double(nitrat),
                                kh: Double(kh),
                                gh: Double(gh),
                                note: note,         // <--- NEU
                                aquarium: aquarium
                            )
                            modelContext.insert(newParam)
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}
