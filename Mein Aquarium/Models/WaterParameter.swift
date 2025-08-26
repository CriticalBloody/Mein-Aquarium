//
//  WaterParameter.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 12.07.25.
//

import Foundation
import SwiftData
import Combine

@Model
class WaterParameter {
    @Attribute(.unique) var id: UUID
    var date: Date
    var ph: Double?
    var kh: Double?
    var gh: Double?
    var nitrit: Double?
    var nitrat: Double?
    var note: String?
    // Weitere Werte wie Kupfer, Eisen, Chlor, ... nach Bedarf

    @Relationship var aquarium: Aquarium?

    init(id: UUID = UUID(), date: Date = .now, ph: Double? = nil, kh: Double? = nil, gh: Double? = nil, nitrit: Double? = nil, nitrat: Double? = nil, note: String? = nil, aquarium: Aquarium? = nil) {
        self.id = id
        self.date = date
        self.ph = ph
        self.kh = kh
        self.gh = gh
        self.nitrit = nitrit
        self.nitrat = nitrat
        self.note = note
        self.aquarium = aquarium
    }
}
