// Aquarium.swift
// Mein Aquarium
//
// Created for project model definition.

import Foundation
import SwiftData
import Combine

@Model
class Aquarium {
    var id: UUID
    var name: String
    var width: Double
    var height: Double
    var depth: Double
    @Relationship var tests: [WaterParameter] = []
    @Relationship var bewohner: [Bewohner]?
    @Relationship var pflanzen: [Pflanze]?
    @Attribute var image: Data?
    
    // Computed property for liters
    var liters: Double {
        (width * height * depth) / 1000.0
    }

    init(name: String, width: Double, height: Double, depth: Double, image: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.width = width
        self.height = height
        self.depth = depth
        self.image = image
    }
}
