import SwiftUI

/// A view that encircles two or more rectangles when they touch by drawing a larger rectangle around them.
struct RectangleEncircler: View {
    var rectangles: [SmartRectangle]  // All rectangles to monitor
    let padding: CGFloat = 20  // Padding around the touching rectangles
    var backgroundOffset: CGSize  // Include the same background offset

    var body: some View {
        ZStack {
            // Draw encircling rectangle only if two or more rectangles are touching
            if let boundingRect = calculateBoundingRectForTouchingRectangles() {
                // Draw a bigger rectangle around the bounding area
                Rectangle()
                    .stroke(Color.red, lineWidth: 3)  // Red border to make it visible
                    .background(Color.red.opacity(0.1))  // Light red background to ensure visibility
                    .frame(width: boundingRect.width + padding, height: boundingRect.height + padding)  // Add padding
                    .position(x: boundingRect.midX + backgroundOffset.width, y: boundingRect.midY + backgroundOffset.height)  // Apply background offset
            }
        }
    }

    /// Calculate the bounding rectangle for **touching rectangles only**.
    func calculateBoundingRectForTouchingRectangles() -> CGRect? {
        // Filter rectangles that are currently touching other rectangles
        let touchingRectangles = rectangles.filter { $0.isTouching }

        // We need at least 2 rectangles touching to draw the encircling rectangle
        guard touchingRectangles.count > 1 else { return nil }

        // Calculate the min and max X and Y coordinates to form the bounding rectangle
        let minX = touchingRectangles.map { $0.position.width }.min() ?? 0
        let maxX = touchingRectangles.map { $0.position.width + $0.rectangleSize.width }.max() ?? 0
        let minY = touchingRectangles.map { $0.position.height }.min() ?? 0
        let maxY = touchingRectangles.map { $0.position.height + $0.rectangleSize.height }.max() ?? 0

        // Return the bounding CGRect
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
