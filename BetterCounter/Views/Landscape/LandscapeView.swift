import SwiftUI
import SwiftData

/// The main view that manages the canvas, including the background and rectangles.
/// - Rectangles are automatically positioned in a grid layout on initialization.
/// - Rectangles can be dragged freely around the canvas.
struct LandscapeView: View {
    
    @Namespace private var namespace
    var countedItems: [CountedItem]
    @State private var backgroundPosition: CGSize = .zero  // Track background panning
    @State private var rectangles: [SmartRectangle] = []  // Store the SmartRectangle instances

    @Environment(\.modelContext) private var context: ModelContext

    let columns = 3  // Number of columns for grid layout
    let spacing: CGFloat = 20.0  // Spacing between rectangles in the grid

    var body: some View {
        ZStack {
            // Draggable background to pan the entire view
            Color.white
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.easeInOut) {
                                backgroundPosition.width += value.translation.width
                                backgroundPosition.height += value.translation.height
                            }
                        }
                )

            // Display the rectangles
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                    // Loop through rectangles and render SmartRectangleView
                    ForEach(rectangles.indices, id: \.self) { index in
                        SmartRectangleView(rectangle: rectangles[index], allRectangles: rectangles)
                            .matchedGeometryEffect(id: rectangles[index].idd, in: namespace)
                            .onTapGesture {
                                withAnimation {
                                    // Handle tap gesture, e.g., show details or edit
                                }
                            }
                    }
                }
                .padding()
            }

            // Add RectangleEncircler and pass the background offset to it
            RectangleEncircler(rectangles: rectangles, backgroundOffset: backgroundPosition)
        }
        .padding()
        .onAppear {
            setupRectangles()  // Initialize the rectangles on appear
            alignRectanglesInGrid()  // Automatically arrange rectangles in grid
        }
    }

    // MARK: - Functions

    /// Sets up the initial rectangles with random positions.
    func setupRectangles() {
        rectangles = countedItems.map { item in
            let group = item.itemGroups?.first ?? ItemGroups(name: "No Group", color: "#CCCCCC")
            return SmartRectangle(
                countedItem: item,
                itemGroups: [group],
                color: group.hexColor,
                position: .zero  // Initialize with zero position
            )
        }
    }

    /// Automatically arranges all rectangles into a grid layout.
    func alignRectanglesInGrid() {
        // For each item, assign a new position within the grid.
        for (index, _) in rectangles.enumerated() {
            let gridPosition = calculateGridPosition(for: index)
            rectangles[index].position = gridPosition
        }
    }

    /// Calculates the position of the rectangle in the grid, starting from the top-left corner.
    func calculateGridPosition(for index: Int) -> CGSize {
        let row = index / columns
        let col = index % columns
        let xPosition = CGFloat(col) * (150 + spacing)  // Adjust width and spacing
        let yPosition = CGFloat(row) * (150 + spacing)  // Adjust height and spacing
        return CGSize(width: xPosition, height: yPosition)  // Grid starts at (0, 0)
    }
}

#Preview {
    let preview = Preview()

    // Insert sample data into the preview container
    preview.addExamples(ItemGroups.sampleGroup)
    preview.addExamples(CountedItem.sampleItems)
    
    let items = CountedItem.sampleItems
    let group = ItemGroups.sampleGroup.first!
    
    items.forEach { $0.itemGroups = [group] }
    
    return LandscapeView(countedItems: items)
        .frame(width: 800, height: 400)
        .padding()
        .modelContainer(preview.container)
}
