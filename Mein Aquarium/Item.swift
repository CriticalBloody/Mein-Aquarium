//
//  Item.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 26.06.25.
//

import Foundation
import SwiftData
import Combine

@Model
class Aquarium {
    var name: String
    var width: Double
    var height: Double
    var depth: Double
    var liters: Double {
        (width * height * depth) / 1000
    }
    @Attribute(.externalStorage)
    var image: Data?
    
    init(name: String, width: Double, height: Double, depth: Double, image: Data? = nil) {
        self.name = name
        self.width = width
        self.height = height
        self.depth = depth
        self.image = image
    }
}

@Model
class WaterParameter {
    @Attribute(.unique) var id: UUID
    var date: Date
    var ph: Double?
    var nitrit: Double?
    var nitrat: Double?
    var kh: Double?
    var gh: Double?
    var note: String?
    // Weitere Werte wie Kupfer, Eisen, Chlor, ... nach Bedarf

    @Relationship var aquarium: Aquarium?

    init(id: UUID = UUID(), date: Date = .now, ph: Double? = nil, nitrit: Double? = nil, nitrat: Double? = nil, kh: Double? = nil, gh: Double? = nil, note: String? = nil, aquarium: Aquarium? = nil) {
        self.id = id
        self.date = date
        self.ph = ph
        self.nitrit = nitrit
        self.nitrat = nitrat
        self.kh = kh
        self.gh = gh
        self.note = note
        self.aquarium = aquarium
    }
}

// Sollwert-Modell (z.B. GlobalSettings.swift)
struct ParameterRange: Codable {
    var min: Double
    var max: Double
}

class GlobalParameterRanges: ObservableObject {
    static let shared = GlobalParameterRanges()
    @Published var pH = ParameterRange(min: 6.5, max: 7.5)
    @Published var nitrit = ParameterRange(min: 0.0, max: 0.2)
    @Published var nitrat = ParameterRange(min: 0.0, max: 25.0)
    @Published var kh = ParameterRange(min: 4.0, max: 8.0)
    @Published var gh = ParameterRange(min: 6.0, max: 12.0)
}
