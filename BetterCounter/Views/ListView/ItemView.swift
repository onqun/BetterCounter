import SwiftUI
import SwiftData

struct ItemView: View {
    @Environment(\.modelContext) private var context
    @State private var showingPopup = false
    @State private var newGroupName = ""
    @State private var isShowingUpdatePopup = false  // New state to show the update popup

    var item: CountedItem

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Display item name
                Text(item.countedItemName)
                    .font(.subheadline)
                    .onTapGesture(count: 2) {  // Double-tap gesture to show update popup
                        isShowingUpdatePopup = true
                    }

                // Display the first group name, if available
                if let firstGroup = item.itemGroups?.first {
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
            }

            Spacer()

            // Display and update item count
            Text("\(item.countedItemNumber)")
                .font(.headline)
                .padding()
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            Task {
                                do {
                                    try await decrementCount(item, context: context)
                                } catch {
                                    print("Error decrementing count: \(error)")
                                }
                            }
                        }
                        .exclusively(
                            before: TapGesture()
                                .onEnded {
                                    Task {
                                        do {
                                            try await incrementCount(item, context: context)
                                        } catch {
                                            print("Error incrementing count: \(error)")
                                        }
                                    }
                                }
                        )
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Make the HStack fill the width
        .padding(.horizontal, 0) // Remove horizontal padding
        .background(Color.white) // Optional: Add a background to see the full width

        // Popup overlay for group selection
        if showingPopup {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showingPopup = false
                }

            CustomPopupView(
                showingPopup: $showingPopup,
                newGroupName: $newGroupName,
                item: item
            )
            .transition(.move(edge: .bottom))
        }

        // Popup overlay for item update
        if isShowingUpdatePopup {
            NewItemPopupView(
                isShowing: $isShowingUpdatePopup,
                mode: .update,
                itemToUpdate: item
            )
            .transition(.move(edge: .bottom))
        }
    }
}

#Preview {
    let preview = Preview()

    // Sample data
    let group1 = ItemGroups(name: "Group A", color: "#FF5733")
    let item1 = CountedItem(countedItemName: "Sample Item", countedItemNumber: 10)
    item1.itemGroups = [group1]

    // Insert the samples into the preview container
    preview.container.mainContext.insert(group1)
    preview.container.mainContext.insert(item1)

    // Return the view to preview
    return ItemView(item: item1)
        .modelContainer(preview.container)
}
