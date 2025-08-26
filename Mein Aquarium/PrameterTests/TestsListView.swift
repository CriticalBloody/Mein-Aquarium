import SwiftUI

struct TestsListView: View {
    @EnvironmentObject var globalRanges: GlobalParameterRanges
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTest: WaterParameter?

    var tests: [WaterParameter]

    var body: some View {
        NavigationView {
            List(tests, id: \.id) { test in
                Button {
                    selectedTest = test
                } label: {
                    VStack(alignment: .leading) {
                        Text(test.date, style: .date)
                            .font(.headline)
                        HStack {
                            Text("pH: \(test.ph.map { String(format: "%.1f", $0) } ?? "–")")
                            if isValueOutsideRange(test.ph, for: "ph") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                        // Analog für KH, GH, Nitrat, Nitrit:
                        HStack {
                            Text("KH: \(test.kh.map { String(format: "%.1f", $0) } ?? "–")")
                            if isValueOutsideRange(test.kh, for: "kh") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                        HStack {
                            Text("GH: \(test.gh.map { String(format: "%.1f", $0) } ?? "–")")
                            if isValueOutsideRange(test.gh, for: "gh") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                        HStack {
                            Text("Nitrat: \(test.nitrat.map { String(format: "%.1f", $0) } ?? "–")")
                            if isValueOutsideRange(test.nitrat, for: "nitrat") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                        HStack {
                            Text("Nitrit: \(test.nitrit.map { String(format: "%.1f", $0) } ?? "–")")
                            if isValueOutsideRange(test.nitrit, for: "nitrit") {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .accessibilityLabel("Außerhalb des Sollbereichs")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tests")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedTest) { selectedTest in
                VStack(spacing: 20) {
                    Text(selectedTest.date, style: .date)
                        .font(.largeTitle)
                    HStack {
                        Text("pH: \(selectedTest.ph.map { String(format: "%.1f", $0) } ?? "–")")
                        if isValueOutsideRange(selectedTest.ph, for: "ph") {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .accessibilityLabel("Außerhalb des Sollbereichs")
                        }
                    }
                    HStack {
                        Text("KH: \(selectedTest.kh.map { String(format: "%.1f", $0) } ?? "–")")
                        if isValueOutsideRange(selectedTest.kh, for: "kh") {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .accessibilityLabel("Außerhalb des Sollbereichs")
                        }
                    }
                    HStack {
                        Text("GH: \(selectedTest.gh.map { String(format: "%.1f", $0) } ?? "–")")
                        if isValueOutsideRange(selectedTest.gh, for: "gh") {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .accessibilityLabel("Außerhalb des Sollbereichs")
                        }
                    }
                    HStack {
                        Text("Nitrat: \(selectedTest.nitrat.map { String(format: "%.1f", $0) } ?? "–")")
                        if isValueOutsideRange(selectedTest.nitrat, for: "nitrat") {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .accessibilityLabel("Außerhalb des Sollbereichs")
                        }
                    }
                    HStack {
                        Text("Nitrit: \(selectedTest.nitrit.map { String(format: "%.1f", $0) } ?? "–")")
                        if isValueOutsideRange(selectedTest.nitrit, for: "nitrit") {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .accessibilityLabel("Außerhalb des Sollbereichs")
                        }
                    }
                    if let note = selectedTest.note, !note.isEmpty {
                        Divider()
                        Text("Notiz: \(note)")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    Button("Schließen") {
                        dismiss()
                    }
                    .padding()
                }
                .padding()
            }
        }
    }

    private func isValueOutsideRange(_ value: Double?, for parameter: String) -> Bool {
        guard let value = value else { return false }
        switch parameter {
        case "ph":
            return value < globalRanges.pH.min || value > globalRanges.pH.max
        case "kh":
            return value < globalRanges.kh.min || value > globalRanges.kh.max
        case "gh":
            return value < globalRanges.gh.min || value > globalRanges.gh.max
        case "nitrat":
            return value < globalRanges.nitrat.min || value > globalRanges.nitrat.max
        case "nitrit":
            return value < globalRanges.nitrit.min || value > globalRanges.nitrit.max
        default:
            return false
        }
    }
}

