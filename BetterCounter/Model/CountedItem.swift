import SwiftUI
import SwiftData

@Model
final class CountedItem: Identifiable, Equatable {
    var id: UUID
    var countedItemName: String
    var countedItemNumber: Int
    @Relationship(inverse: \ItemGroups.items)
    var itemGroups: [ItemGroups]?
    
    // Initializer
    init(id: UUID = UUID(),
         countedItemName: String,
         countedItemNumber: Int) {
        self.id = id
        self.countedItemName = countedItemName
        self.countedItemNumber = countedItemNumber
    }
    
    // Equatable conformance
    static func == (lhs: CountedItem, rhs: CountedItem) -> Bool {
        return lhs.id == rhs.id &&
        lhs.countedItemName == rhs.countedItemName &&
        lhs.countedItemNumber == rhs.countedItemNumber
    }
}
