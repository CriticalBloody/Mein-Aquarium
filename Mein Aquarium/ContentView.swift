//
//  ContentView.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 26.06.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var aquariums: [Aquarium]
    @State private var selectedAquarium: Aquarium?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack {
            TabView {
                AquariumMainView(selectedAquarium: $selectedAquarium)
                    .ignoresSafeArea(.container, edges: .top)
                    .tabItem {
                        Label("Aquarien", systemImage: "house")
                    }
                if !aquariums.isEmpty {
                    BewohnerView()
                        .tabItem {
                            Label("Bewohner", systemImage: "fish")
                        }
                } else {
                    Text("Kein Aquarium vorhanden")
                        .tabItem {
                            Label("Bewohner", systemImage: "fish")
                        }
                }
                if !aquariums.isEmpty {
                    PflanzenView()
                        .tabItem {
                            Label("Pflanzen", systemImage: "leaf")
                        }
                } else {
                    Text("Keine Pflanzen vorhanden")
                        .tabItem {
                            Label("Bewohner", systemImage: "leaf")
                        }
                }
                
                SettingsView()
                    .tabItem {
                        Label("Einstellungen", systemImage: "gear")
                    }
            }
            .navigationDestination(item: $selectedAquarium) { bindingAquarium in
                AquariumDetailView(aquarium: bindingAquarium, path: $path)
            }
        }
    }
}
