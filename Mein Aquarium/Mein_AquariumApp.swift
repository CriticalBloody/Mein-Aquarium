//
//  Mein_AquariumApp.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 26.06.25.
//

import SwiftUI
import SwiftData

@main
struct Mein_AquariumApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Aquarium.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject var globalRanges = GlobalParameterRanges()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(globalRanges)
        }
        .modelContainer(for: [Aquarium.self, WaterParameter.self])
        .environmentObject(globalRanges)
    }
}
