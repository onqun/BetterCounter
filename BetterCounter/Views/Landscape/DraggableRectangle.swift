import SwiftUI

/// A SwiftUI view that displays a draggable `SmartRectangle` and checks for collisions with other rectangles.
struct SmartRectangleView: View {
    @ObservedObject var rectangle: SmartRectangle
    var allRectangles: [SmartRectangle]
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            // Rectangle shape with dynamic border color based on collision state
            Rectangle()
                .fill(rectangle.color)
                .frame(width: rectangle.rectangleSize.width, height: rectangle.rectangleSize.height) // Use the precomputed size
                .cornerRadius(8)
                .shadow(radius: 5)
                .border(rectangle.isTouching ? Color.yellow : Color.black, width: 2)  // Border color changes if touching

            // Display item name and count in the center of the rectangle
            VStack {
                Text(rectangle.countedItem.countedItemName)
                    .padding()

                Text("\(rectangle.countedItem.countedItemNumber)")
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.top, 5)
            }
        }
        .frame(width: rectangle.rectangleSize.width, height: rectangle.rectangleSize.height)  // Ensure size is consistent
        .contentShape(Rectangle())  // Set the interactive area to match the rectangle's frame
        .offset(x: rectangle.position.width + dragOffset.width, y: rectangle.position.height + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation  // Update the drag offset

                    // Calculate the new position during dragging
                    let newPosition = CGSize(
                        width: rectangle.position.width + dragOffset.width,
                        height: rectangle.position.height + dragOffset.height
                    )

                    // Check for collisions with other rectangles
                    checkCollision(at: newPosition)
                }
                .onEnded { _ in
                    // Apply the drag offset to the permanent position
                    rectangle.position.width += dragOffset.width
                    rectangle.position.height += dragOffset.height
                    dragOffset = .zero  // Reset the drag offset

                    // Perform a final collision check
                    checkCollision(at: rectangle.position)
                }
        )
    }

    /// Function to check if this rectangle is touching any other rectangle
    func checkCollision(at newPosition: CGSize) {
        let currentFrame = CGRect(origin: CGPoint(x: newPosition.width, y: newPosition.height), size: rectangle.rectangleSize)

        // Reset the `isTouching` state for all rectangles
        allRectangles.forEach { $0.isTouching = false }

        // Check if the current rectangle intersects with any other rectangles
        for otherRect in allRectangles where otherRect !== rectangle {
            let otherFrame = CGRect(origin: CGPoint(x: otherRect.position.width, y: otherRect.position.height), size: otherRect.rectangleSize)

            // If the two rectangles intersect, mark them as touching
            if currentFrame.intersects(otherFrame) {
                // Update the `isTouching` state for both rectangles
                DispatchQueue.main.async {
                    rectangle.isTouching = true
                    otherRect.isTouching = true
                }
            }
        }
    }
}

#Preview {
    // Sample data for preview
    let preview = Preview()

    preview.addExamples(ItemGroups.sampleGroup)
    preview.addExamples(CountedItem.sampleItems)

    let items = CountedItem.sampleItems
    let group = ItemGroups.sampleGroup.first!

    // Associate groups with items for testing
    items.forEach { $0.itemGroups = [group] }

    // Initialize a SmartRectangle for the preview
    let smartRectangle = SmartRectangle(
        countedItem: items.first!,
        itemGroups: [group],
        color: group.hexColor,
        position: CGSize(width: 150, height: 150)
    )

    return SmartRectangleView(rectangle: smartRectangle, allRectangles: [smartRectangle])
        .padding()  // Adds padding around the preview for clarity
        .modelContainer(preview.container)
}
