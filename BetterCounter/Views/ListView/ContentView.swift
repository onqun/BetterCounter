import SwiftUI

struct ContentView: View {
    @StateObject private var orientationManager = OrientationManager()

    var body: some View {  // The `body` property must enclose the content
        Group {
            switch orientationManager.orientation {
            case .portrait:
                ListView()  // Show ListView for portrait orientation
            case .landscape:
                LandscapeView(countedItems: countedItems)  // Show LandscapeView for general landscape
            case .landscapeLeftWithCameraUp:
                LandscapeView(countedItems: countedItems)  // You can customize this view as needed
            }
        }
        .animation(.easeInOut, value: orientationManager.orientation)
    }

    // Mock data for CountedItems
    
    private var countedItems: [CountedItem] {
        let group = ItemGroups(name: "Group A", color: "#FF5733")
        let items = [
            CountedItem(countedItemName: "Item 1", countedItemNumber: 10),
            CountedItem(countedItemName: "Item 2", countedItemNumber: 15),
            CountedItem(countedItemName: "Item 3", countedItemNumber: 7)
        ]
        items.forEach { $0.itemGroups = [group] }
        return items
    }
}

#Preview {
    ContentView()
}
