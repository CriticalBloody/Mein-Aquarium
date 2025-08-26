//
//  AquariumMainView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 26.06.25.
//

import SwiftUI
import SwiftData
#if os(macOS)
import AppKit
#endif

struct AquariumMainView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    // SwiftData-Abfrage für Aquarien
    @Query private var aquariums: [Aquarium]
    
    // State-Variablen für Test-Sheets
    @State private var showTestSheet = false
    @State private var selectedAquariumForTest: Aquarium?
    @State private var showAddTestForm = false
    
    @State private var showAddAquariumSheet = false
    @State private var showAddBewohnerSheet = false
    @State private var showAddPflanzeSheet = false
    
    @State private var showAddBewohnerForm = false
    @State private var showAddPflanzeForm = false
    
    @Binding var selectedAquarium: Aquarium?
    
    @Environment(\.colorScheme) var colorScheme

    @State private var currentIndex = 0
    @State private var path = NavigationPath()
    
    @State private var toolPage = 0
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                Color.systemBackground.ignoresSafeArea()

                GeometryReader { geometry in
                    // Crash-Schutz: Keine Aquarien vorhanden
                    if aquariums.isEmpty {
                        EmptyView()
                    } else {
                        let safeIndex = aquariums.indices.contains(currentIndex) ? currentIndex : 0
                        let aquarium = aquariums[safeIndex]
                        ZStack(alignment: .bottomLeading) {
    #if os(iOS)
                            if let imageData = aquarium.image, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: heroHeight)
                                    .clipped()
                                    .blur(radius: 25)
                                
                            } else {
                                Color.gray
                                    .frame(width: geometry.size.width, height: heroHeight)
                            }
    #elseif os(macOS)
                            if let imageData = aquarium.image, let nsImage = NSImage(data: imageData) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: heroHeight)
                                    .clipped()
                                
                            } else {
                                Color.gray
                                    .frame(width: geometry.size.width, height: heroHeight)
                            }
    #endif
                            VStack(alignment: .leading, spacing: 45) {
                                Text(aquarium.name)
                                    .font(.title)
                                    .foregroundColor(.primary)
                                    .shadow(radius: 10)
                                Text("\(aquarium.liters, specifier: "%.1f") Liter")
                                    .font(.title3).foregroundColor(.primary.opacity(0.95))
    #if os(iOS)
                                if let imageData = aquarium.image, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 0.5, height: 88)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(radius: 8)
                                }
    #elseif os(macOS)
                                if let imageData = aquarium.image, let nsImage = NSImage(data: imageData) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 0.5, height: 88)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(radius: 8)
                                }
    #endif
                            }
                            .padding([.leading, .bottom], 30)

                            // Links/Rechts Buttons
                            if currentIndex > 0 {
                                Button(action: { currentIndex -= 1 }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.primary)
                                        .frame(width: 54, height: 54)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .position(x: 36, y: heroHeight/2)
                            }
                            if currentIndex < aquariums.count - 1 {
                                Button(action: { currentIndex += 1 }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.primary)
                                        .frame(width: 54, height: 54)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                .position(x: geometry.size.width - 36, y: heroHeight/2)
                            }
                        }
                        .frame(height: heroHeight)
                        .clipped()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            path.append(aquarium)
                        }
                        // Verlauf als Overlay über das Bild und nach unten
                        .overlay(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.clear, .systemBackground]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 180)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .allowsHitTesting(false)
                        )
                    }
                }
                
                VStack {
                    Spacer().frame(height: heroHeight - 5) // Weniger Abstand zu Werkzeuge
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 10) {
                            Text("Werkzeuge")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                                .padding(.leading, 32)
                        }
                        
                        // ScrollView mit expliziten Buttons statt ForEach
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 24) {
                                Button(action: {
                                    showAddAquariumSheet = true
                                }) {
                                    VStack(spacing: 10) {
                                        Image(systemName: "square.grid.3x1.folder.badge.plus")
                                            .font(.system(size: 34, weight: .semibold))
                                            .foregroundColor(.accentColor)
                                        Text("Aquarium\nhinzufügen")
                                            .font(.footnote)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                    .frame(width: 130, height: 130)
                                    .cornerRadius(16)
                                }
                                Button(action: {
                                    if aquariums.count == 1, let onlyAquarium = aquariums.first {
                                        selectedAquariumForTest = onlyAquarium
                                        showAddTestForm = true
                                    } else {
                                        selectedAquariumForTest = nil
                                        showTestSheet = true
                                    }
                                }) {
                                    VStack(spacing: 10) {
                                        Image("test.plus")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 34)
                                            .foregroundColor(.accentColor)
                                        Text("Test\nhinzufügen")
                                            .font(.footnote)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                    .frame(width: 130, height: 130)
                                    .cornerRadius(16)
                                }
                                Button(action: {
                                    showAddBewohnerSheet = true
                                }) {
                                    VStack(spacing: 10) {
                                        Image("fish.plus")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 34)
                                            .foregroundColor(.accentColor)
                                        Text("Bewohner\nhinzufügen")
                                            .font(.footnote)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                    .frame(width: 130, height: 130)
                                    .cornerRadius(16)
                                }
                                Button(action: {
                                    showAddPflanzeSheet = true
                                }) {
                                    VStack(spacing: 10) {
                                        Image("leaf.plus")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 34)
                                            .foregroundColor(.accentColor)
                                        Text("Pflanze\nhinzufügen")
                                            .font(.footnote)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                    .frame(width: 130, height: 130)
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                        .frame(height: 140)
                    }
                    .padding(.bottom, 24)
                    Spacer(minLength: 0)
                }
            }
            // Sheets bleiben unverändert, außer Bewohner und Pflanze:
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
    #if os(iOS)
                        .pickerStyle(.wheel)
    #endif
                        .padding(.horizontal)
                        Button(action: {
                            showTestSheet = false
                            showAddTestForm = true
                        }) {
                            Text("Weiter")
                            Image(systemName: "checkmark")
                        }
                        .disabled(selectedAquariumForTest == nil)
                        .buttonStyle(.borderedProminent)
                        Spacer()
                    }
                    .padding()
                }
            }
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
            .sheet(isPresented: $showAddAquariumSheet) {
                AquariumFormView()
            }
            .sheet(isPresented: $showAddBewohnerSheet) {
                if aquariums.count == 1, let onlyAquarium = aquariums.first {
                    BewohnerFormView(aquarium: onlyAquarium)
                } else {
                    VStack(spacing: 20) {
                        Text("Zu welchem Aquarium möchtest du den Bewohner hinzufügen?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal, 24)
                        Picker("Aquarium", selection: $selectedAquariumForTest) {
                            ForEach(aquariums) { aquarium in
                                Text(aquarium.name).tag(Optional(aquarium))
                            }
                        }
    #if os(iOS)
                        .pickerStyle(.wheel)
    #endif
                        .padding(.horizontal)
                        Button(action: {
                            showAddBewohnerSheet = false
                            if selectedAquariumForTest != nil {
                                showAddBewohnerForm = true
                            }
                        }) {
                            Text("Weiter")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .disabled(selectedAquariumForTest == nil)
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal, 24)
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding()
                }
            }
            .sheet(isPresented: $showAddBewohnerForm) {
                if let aquarium = selectedAquariumForTest {
                    BewohnerFormView(aquarium: aquarium)
                } else {
                    Text("Kein Aquarium ausgewählt.")
                        .padding()
                }
            }
            .sheet(isPresented: $showAddPflanzeSheet) {
                if aquariums.count == 1, let onlyAquarium = aquariums.first {
                    PflanzenFormView(aquarium: onlyAquarium)
                } else if aquariums.isEmpty {
                    Text("Kein Aquarium vorhanden.")
                        .padding()
                } else {
                    VStack(spacing: 20) {
                        Text("Zu welchem Aquarium möchtest du die Pflanze hinzufügen?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal, 24)
                        Picker("Aquarium", selection: $selectedAquariumForTest) {
                            ForEach(aquariums) { aquarium in
                                Text(aquarium.name).tag(Optional(aquarium))
                            }
                        }
    #if os(iOS)
                        .pickerStyle(.wheel)
    #endif
                        .padding(.horizontal)
                        Button(action: {
                            showAddPflanzeSheet = false
                            if selectedAquariumForTest != nil {
                                showAddPflanzeForm = true
                            }
                        }) {
                            Text("Weiter")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .disabled(selectedAquariumForTest == nil)
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal, 24)
                        Spacer()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding()
                }
            }
            .sheet(isPresented: $showAddPflanzeForm) {
                if let aquarium = selectedAquariumForTest {
                    PflanzenFormView(aquarium: aquarium)
                } else {
                    Text("Kein Aquarium ausgewählt.")
                        .padding()
                }
            }
            .navigationDestination(for: Aquarium.self) { aquarium in
                AquariumDetailView(aquarium: aquarium, path: $path)
            }
            .onChange(of: aquariums, initial: false) { oldValue, newValue in
                if newValue.isEmpty {
                    currentIndex = 0
                } else if currentIndex >= newValue.count {
                    currentIndex = max(0, newValue.count - 1)
                }
            }
        }
    }
}

private let heroHeight: CGFloat = 420 // Erhöhtes Karussell für mehr Präsenz

// MARK: - Plattformübergreifender SystemBackground Helper
extension Color {
    static var systemBackground: Color {
    #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
    #else
        return Color(.systemBackground)
    #endif
    }
}
