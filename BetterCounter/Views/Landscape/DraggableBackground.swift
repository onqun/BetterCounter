import SwiftUI

/// A view representing a draggable background. This allows users to pan the canvas around.
struct DraggableBackground: View {
    @Binding var backgroundPosition: CGSize  // Bind to the current background position
    @State private var dragOffset: CGSize = .zero  // Track the temporary drag offset

    var body: some View {
        Color.white
            .edgesIgnoringSafeArea(.all)  // Background should fill the screen
            .offset(x: backgroundPosition.width + dragOffset.width, y: backgroundPosition.height + dragOffset.height)  // Move the background as it's dragged
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Apply only the current drag offset while dragging
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        // Add the dragOffset to backgroundPosition when drag ends
                        backgroundPosition.width += dragOffset.width
                        backgroundPosition.height += dragOffset.height
                        dragOffset = .zero // Reset dragOffset after applying it
                    }
            )
            .animation(.easeInOut(duration: 0.3), value: backgroundPosition) // Smooth animation when the background settles
    }
}
