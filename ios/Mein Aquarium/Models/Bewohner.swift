//
//  Bewohner.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 12.07.25.
//

import Foundation
import SwiftData
import Combine

@Model
class Bewohner {
    var id: UUID
    var name: String
    var art: String
    var birthDate: Date
    var addedDate: Date
    @Relationship var aquarium: Aquarium?
    @Attribute var images: Data?
    var note: String?

    init(name: String, art: String, birthDate: Date, addedDate: Date, aquarium: Aquarium, images: Data? = nil, note: String? = nil, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.art = art
        self.birthDate = birthDate
        self.addedDate = addedDate
        self.aquarium = aquarium
        self.images = images
        self.note = note
    }
}
