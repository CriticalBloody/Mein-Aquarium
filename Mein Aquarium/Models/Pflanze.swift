//
//  Pflanze.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 17.07.25.
//

import Foundation
import SwiftData
import Combine

@Model
class Pflanze {
    var id: UUID
    var name: String
    var art: String
    var plantedDate: Date
    @Relationship var aquarium: Aquarium?
    @Attribute var images: [Data]?
    var note: String?

    init(name: String, art: String, plantedDate: Date, aquarium: Aquarium, images: [Data]? = nil, note: String? = nil, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.art = art
        self.plantedDate = plantedDate
        self.aquarium = aquarium
        self.images = images
        self.note = note
    }
}
