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
    @AppStorage("useDarkMode") private var useDarkMode = false
    @StateObject var globalRanges = GlobalParameterRanges()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalRanges)
                .preferredColorScheme(useDarkMode ? .dark : .light)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        #endif
        .modelContainer(for: [Aquarium.self, WaterParameter.self, Bewohner.self])
        .environmentObject(globalRanges)
    }
}
