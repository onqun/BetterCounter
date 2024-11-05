import SwiftUI

struct MyCollectionView: View {
    @Namespace private var namespace
    @Environment(\.modelContext) private var context

    // Array of SmartRectangle instances
    @State private var rectangles: [SmartRectangle]

    // Initializer to populate the rectangles array
    init(countedItems: [CountedItem]) {
        _rectangles = State(initialValue: countedItems.map { item in
            SmartRectangle(
                countedItem: item,
                itemGroups: item.itemGroups ?? [],
                color: .blue, // Customize the color as needed
                position: CGSize(width: CGFloat.random(in: 0...200), height: CGFloat.random(in: 0...400)) // Random initial positions for demo
            )
        })
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                // Loop through rectangles and render SmartRectangleView
                ForEach(rectangles, id: \.idd) { rectangle in
                    SmartRectangleView(rectangle: rectangle, allRectangles: rectangles)
                        .matchedGeometryEffect(id: rectangle.idd, in: namespace)
                        .onTapGesture {
                            withAnimation {
                                // Handle tap gesture, e.g., show details or edit
                            }
                        }
                }
            }
            .padding()
        }
    }
}
