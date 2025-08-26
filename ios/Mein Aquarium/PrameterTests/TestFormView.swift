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
#if os(macOS)
        VStack(spacing: 20) {
            Text(parameterToEdit == nil ? "Wasserwerte eintragen" : "Wasserwerte bearbeiten")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                DatePicker("Datum", selection: $date, displayedComponents: .date)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 12) {
                    TextField("pH", text: $ph)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                    TextField("KH (°dH)", text: $kh)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                    TextField("GH (°dH)", text: $gh)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)

                    TextField("Nitrit (mg/l)", text: $nitrit)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                    TextField("Nitrat (mg/l)", text: $nitrat)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                    TextEditor(text: $note)
                        .frame(minHeight: 60)
                        .overlay(
                            ZStack(alignment: .topLeading) {
                                if note.isEmpty {
                                    Text("Notiz")
                                        .foregroundColor(Color.gray.opacity(0.6))
                                        .padding(8)
                                }
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.5))
                            }
                        )
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor).opacity(0.85))
            .cornerRadius(12)
            .frame(maxWidth: .infinity)

            HStack(spacing: 20) {
                Button("Abbrechen") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button("Speichern") {
                    if let param = parameterToEdit {
                        param.date = date
                        param.ph = Double(ph)
                        param.kh = Double(kh)
                        param.gh = Double(gh)
                        param.nitrit = Double(nitrit)
                        param.nitrat = Double(nitrat)
                        param.note = note           // <--- NEU
                    } else {
                        let newParam = WaterParameter(
                            date: date,
                            ph: Double(ph),
                            kh: Double(kh),
                            gh: Double(gh),
                            nitrit: Double(nitrit),
                            nitrat: Double(nitrat),
                            note: note,         // <--- NEU
                            aquarium: aquarium
                        )
                        modelContext.insert(newParam)
                    }
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(24)
        .frame(maxWidth: 480)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
        )
        .padding()
#else
        VStack(alignment: .leading) {
            Text(parameterToEdit == nil ? "Wasserwerte eintragen" : "Wasserwerte bearbeiten")
                .font(.title)
                .padding(.bottom, 8)

            Form {
                Section {
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                    TextField("pH", text: $ph)
                    TextField("KH (°dH)", text: $kh)
                    TextField("GH (°dH)", text: $gh)
                    TextField("Nitrit (mg/l)", text: $nitrit)
                    TextField("Nitrat (mg/l)", text: $nitrat)
                    TextField("Notiz", text: $note)
                }
            }
            .formStyle(.grouped)
            .frame(maxWidth: 400)

            HStack(spacing: 20) {
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.gray)

                Button {
                    if let param = parameterToEdit {
                        param.date = date
                        param.ph = Double(ph)
                        param.kh = Double(kh)
                        param.gh = Double(gh)
                        param.nitrit = Double(nitrit)
                        param.nitrat = Double(nitrat)
                        param.note = note           // <--- NEU
                    } else {
                        let newParam = WaterParameter(
                            date: date,
                            ph: Double(ph),
                            kh: Double(kh),
                            gh: Double(gh),
                            nitrit: Double(nitrit),
                            nitrat: Double(nitrat),
                            note: note,         // <--- NEU
                            aquarium: aquarium
                        )
                        modelContext.insert(newParam)
                    }
                    dismiss()
                } label: {
                    Text("Speichern")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: 400)
#endif
    }
}
