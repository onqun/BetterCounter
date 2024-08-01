import SwiftUI
import SwiftData

// Make ItemGroups conform to Equatable
@Model
final class ItemGroups: Equatable, Hashable, Identifiable {
    
    var id: UUID = UUID() // Ensure the identifier is of type UUID
    var name: String
    var color: String
    var items: [CountedItem]?
    
    // Mark the initializer as 'required'
    required init(name: String, color: String) {
        self.name = name
        self.color = color
    }
    
    var hexColor: Color {
        Color(hex: self.color) ?? .gray
    }
    
    // Equatable conformance
    static func == (lhs: ItemGroups, rhs: ItemGroups) -> Bool {
        return lhs.name == rhs.name && lhs.color == rhs.color
    }
    // Hashable conformance to enable ItemGroups usage in sets or dictionaries
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(color)
    }
    
    
}
