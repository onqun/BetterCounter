// ItemGroups.swift

import SwiftUI
import SwiftData

@Model
final class ItemGroups: Hashable, Equatable {
    let id: PersistentIdentifier
    let name: String
    var color: String
    var items: [CountedItem]? // Relationship to CountedItem

    // Initializer
    required init(name: String, color: String) {
        self.id = PersistentIdentifier()
        self.name = name
        self.color = color
    }

    // Equatable conformance
    static func == (lhs: ItemGroups, rhs: ItemGroups) -> Bool {
        return lhs.id == rhs.id
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Computed property for Color representation
    var groupColor: Color {
        Color(hex: color) ?? .gray
    }

    // Static ungrouped group
    static let ungroupedGroup = ItemGroups(name: "Ungrouped", color: "#FFFFFF")
}
