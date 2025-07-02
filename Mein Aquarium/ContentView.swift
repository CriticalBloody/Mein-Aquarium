//
//  ContentView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 26.06.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            AquariumMainView()
                .tabItem {
                    Label("Aquarien", systemImage: "house")
                }
            BewohnerView()
                .tabItem {
                    Label("Bewohner", systemImage: "fish")
                }
            SettingsView()
                .tabItem {
                    Label("Einstellungen", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Aquarium.self, inMemory: true)
}
