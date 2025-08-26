//
//  ParameterRange.swift
//  Mein Aquarium
//
//  Created by Lars Taube on 12.07.25.
//

import Foundation
import SwiftData
import Combine

struct ParameterRange: Codable {
    var min: Double
    var max: Double
}

class GlobalParameterRanges: ObservableObject {
    static let shared = GlobalParameterRanges()
    @Published var pH = ParameterRange(min: 6.5, max: 7.5)
    @Published var kh = ParameterRange(min: 4.0, max: 8.0)
    @Published var gh = ParameterRange(min: 6.0, max: 12.0)
    @Published var nitrit = ParameterRange(min: 0.0, max: 0.2)
    @Published var nitrat = ParameterRange(min: 0.0, max: 25.0)
}
