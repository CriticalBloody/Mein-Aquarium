import SwiftUI
import SwiftData
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

// Hinweis: Für projektweiten Einsatz sollte die PlatformImage-Typalias und Image-Extension in eine zentrale Datei ausgelagert werden, um Redeklarationen zu vermeiden.

struct BewohnerDetailView: View {
    let bewohner: Bewohner
    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var note: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AvatarSection(imageData: bewohner.images, name: bewohner.name, art: bewohner.art, birthDate: bewohner.birthDate, addedDate: bewohner.addedDate)
                
                NotesSection(notes: $note)
                
                FotosSection(imageData: bewohner.images)
            }
            .padding(20)
        }
        .navigationTitle(bewohner.name)
        .confirmationDialog(
            "Möchtest du diesen Bewohner wirklich löschen?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Löschen", role: .destructive) {
                modelContext.delete(bewohner)
                dismiss()
            }
            Button("Abbrechen", role: .cancel) {}
        }
        .sheet(isPresented: $showEditSheet) {
            if let aquarium = bewohner.aquarium {
                BewohnerFormView(
                    aquarium: aquarium,
                    bewohner: bewohner,
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
            note = bewohner.note ?? ""
        }
        .onChange(of: note) { oldValue, newValue in
            bewohner.note = newValue
            try? modelContext.save()
        }
    }
}

// MARK: - AvatarSection

private struct AvatarSection: View {
    let imageData: Data?
    let name: String
    let art: String
    let birthDate: Date
    let addedDate: Date
    
    private var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthDate)
    }
    
    private var formattedAddedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: addedDate)
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
                if birthDate == addedDate {
                    Text("Geboren am \(formattedBirthDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Geboren am \(formattedBirthDate)")
                        Text("Eingesetzt am \(formattedAddedDate)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
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
            Image(systemName: "fish.fill")
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
