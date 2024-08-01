import Combine
import SwiftUI

final class SmartRectangle: ObservableObject, Equatable {
    @Published var position: CGSize
    @Published var countedItem: CountedItem
    @Published var itemGroups: [ItemGroups]
    @Published var color: Color
    @Published var isTouching: Bool = false

    // Precompute or dynamically calculate the rectangle's size
    @Published private(set) var rectangleSize: CGSize  // Mark it as @Published for SwiftUI to observe

    // MARK: - Initializer
    init(
        countedItem: CountedItem, itemGroups: [ItemGroups],
        color: Color = .blue, position: CGSize = .zero
    ) {
        self.countedItem = countedItem
        self.itemGroups = itemGroups
        self.color = color
        self.position = position

        // Precompute size based on text length
        self.rectangleSize = SmartRectangle.calculateSize(
            for: countedItem.countedItemName)
    }

    // MARK: - Methods

    // If the countedItemName changes, recalculate the size
    func updateCountedItem(_ newItem: CountedItem) {
        countedItem = newItem
        rectangleSize = SmartRectangle.calculateSize(
            for: countedItem.countedItemName)
    }

    /// Static method to calculate the size based on text length
    static func calculateSize(for text: String) -> CGSize {
        let width = max(100, CGFloat(text.count) * 10)
        return CGSize(width: width, height: width + 50)
    }

    func drag(by offset: CGSize) {
        self.position.width += offset.width
        self.position.height += offset.height
    }

    /// Method to check if the rectangle intersects (touches) another rectangle
    func intersects(with other: SmartRectangle) -> Bool {
        let rect1 = CGRect(
            origin: CGPoint(x: position.width, y: position.height),
            size: rectangleSize)
        let rect2 = CGRect(
            origin: CGPoint(
                x: other.position.width, y: other.rectangleSize.height),
            size: other.rectangleSize)
        return rect1.intersects(rect2)
    }

    // MARK: - Equatable Conformance
    static func == (lhs: SmartRectangle, rhs: SmartRectangle) -> Bool {
        return lhs.position == rhs.position
            && lhs.countedItem.countedItemName
                == rhs.countedItem.countedItemName
            && lhs.countedItem.countedItemNumber
                == rhs.countedItem.countedItemNumber
            && lhs.color == rhs.color
    }
}
