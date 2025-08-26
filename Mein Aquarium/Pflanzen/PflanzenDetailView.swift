import SwiftUI
import SwiftData
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

// Hinweis: Für projektweiten Einsatz sollte die PlatformImage-Typalias und Image-Extension in eine zentrale Datei ausgelagert werden, um Redeklarationen zu vermeiden.

struct PflanzenDetailView: View {
    let pflanze: Pflanze
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var note: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AvatarSection(imageData: pflanze.images?.first, name: pflanze.name, art: pflanze.art, plantedDate: pflanze.plantedDate)
                NotesSection(notes: $note)
                FotosSection(imageData: pflanze.images?.first)
            }
            .padding(20)
        }
        .navigationTitle(pflanze.name)
        .confirmationDialog(
            "Möchtest du diese Pflanze wirklich löschen?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                modelContext.delete(pflanze)
                dismiss()
            }
            Button("Abbrechen", role: .cancel) {}
        }
        .sheet(isPresented: $showEditSheet) {
            if let aquarium = pflanze.aquarium {
                PflanzenFormView(
                    aquarium: aquarium,
                    pflanze: pflanze,
                    onSave: { _ in
                        showEditSheet = false
                    }
                )
                .frame(minWidth: 400, minHeight: 300)
            } else {
                Text("Kein Aquarium zugeordnet.")
                    .frame(minWidth: 400, minHeight: 300)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .secondaryAction) {
                Button("Bearbeiten", systemImage: "pencil") {
                    showEditSheet.toggle()
                }
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Löschen", systemImage: "trash")
                }
            }
        }
        .onAppear {
            note = pflanze.note ?? ""
        }
        .onChange(of: note) { oldValue, newValue in
            pflanze.note = newValue
            try? modelContext.save()
        }
    }
}

// MARK: - AvatarSection

private struct AvatarSection: View {
    let imageData: Data?
    let name: String
    let art: String
    let plantedDate: Date
    
    private var formattedPlantedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: plantedDate)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            avatarImage
                .frame(width: 110, height: 110)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.accentColor.opacity(0.4), lineWidth: 2))
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.largeTitle.weight(.semibold))
                    .foregroundColor(.primary)
                Text(art)
                    .font(.title3.weight(.medium))
                    .foregroundColor(.secondary)
                Text("Eingesetzt am \(formattedPlantedDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private var avatarImage: some View {
        if let imageData {
            #if canImport(AppKit)
            if let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholderImage
            }
            #elseif canImport(UIKit)
            if let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholderImage
            }
            #else
            placeholderImage
            #endif
        } else {
            placeholderImage
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.15))
            Image(systemName: "leaf.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.accentColor)
        }
    }
}

// MARK: - NotesSection

private struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notizen")
                .font(.title3.bold())
                .foregroundColor(.primary)
            
            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Notizen hinzufügen...")
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                        .padding(.horizontal, 8)
                }
                TextEditor(text: $notes)
                    .padding(8)
                    .cornerRadius(10)
                    .font(.body)
                    .foregroundColor(.primary)
                    .frame(minHeight: 110)
            }
        }
        .padding()
    }
}

// MARK: - FotosSection

private struct FotosSection: View {
    let imageData: Data?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fotos")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            if let imageData {
                #if canImport(AppKit)
                if let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                } else {
                    noPhotosText
                }
                #elseif canImport(UIKit)
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                } else {
                    noPhotosText
                }
                #else
                noPhotosText
                #endif
            } else {
                noPhotosText
            }
        }
        .padding()
    }
    
    private var noPhotosText: some View {
        Text("Keine weiteren Fotos vorhanden.")
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(.top, 6)
    }
}
