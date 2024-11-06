import SwiftUI

/// A SwiftUI view that displays a draggable `SmartRectangle` and checks for collisions with other rectangles.
/// An electric effect animation appears when rectangles are close to each other.
struct SmartRectangleView: View {
    @ObservedObject var rectangle: SmartRectangle
    var allRectangles: [SmartRectangle]
    @State private var dragOffset: CGSize = .zero
    @State private var showElectricEffect: Bool = false
    @State private var showingPopup = false  // New state to show the update popup


    var body: some View {
        ZStack {
            // Rectangle shape
            Rectangle()
                .fill(rectangle.color)
                .frame(width: rectangle.rectangleSize.width, height: rectangle.rectangleSize.height)
                .cornerRadius(8)
                .shadow(radius: 5)
                .border(rectangle.isTouching ? Color.yellow : Color.black, width: 2)


            // Item name and count
            VStack {
                Text(rectangle.countedItem.countedItemName)
                    .padding(.bottom, 10)
                if let firstGroup = rectangle.countedItem.itemGroups?.first {
                    Button(action: {
                        showingPopup = true
                    }) {
                        HStack {
                            Text(firstGroup.name)
                            Image(systemName: "chevron.down")
                        }
                        .font(.footnote)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(firstGroup.hexColor.opacity(0.2))
                        )
                    }
                    .contentShape(Rectangle())
                }
                
                Text("\(rectangle.countedItem.countedItemNumber)")
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.top, 5)
            }
        }
        .frame(width: rectangle.rectangleSize.width, height: rectangle.rectangleSize.height)
        .contentShape(Rectangle())
        .offset(x: rectangle.position.width + dragOffset.width, y: rectangle.position.height + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                    let newPosition = CGSize(
                        width: rectangle.position.width + dragOffset.width,
                        height: rectangle.position.height + dragOffset.height
                    )
                    checkCollision(at: newPosition)
                }
                .onEnded { _ in
                    rectangle.position.width += dragOffset.width
                    rectangle.position.height += dragOffset.height
                    dragOffset = .zero
                    checkCollision(at: rectangle.position)
                }
        )
    }

    /// Function to check if this rectangle is touching any other rectangle
    func checkCollision(at newPosition: CGSize) {
        let currentFrame = CGRect(origin: CGPoint(x: newPosition.width, y: newPosition.height), size: rectangle.rectangleSize)

        // Reset the `isTouching` state for all rectangles
        allRectangles.forEach { $0.isTouching = false }

        var collisionDetected = false

        // Check for collisions
        for otherRect in allRectangles where otherRect !== rectangle {
            let otherFrame = CGRect(origin: CGPoint(x: otherRect.position.width, y: otherRect.position.height), size: otherRect.rectangleSize)

            if currentFrame.intersects(otherFrame) {
                collisionDetected = true
                DispatchQueue.main.async {
                    rectangle.isTouching = true
                    otherRect.isTouching = true
                }
            }
        }

        // Show or hide electric effect based on collision
        showElectricEffect = collisionDetected
    }
}


#Preview {
    let sampleItem = CountedItem(countedItemName: "Sample", countedItemNumber: 1)
    let sampleGroup = ItemGroups(name: "Group", color: "#FF5733")
    sampleItem.itemGroups = [sampleGroup]
    let rectangle = SmartRectangle(countedItem: sampleItem, itemGroups: [sampleGroup], color: .blue, position: .zero)
    
    return SmartRectangleView(rectangle: rectangle, allRectangles: [rectangle])
}
