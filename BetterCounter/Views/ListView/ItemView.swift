import SwiftUI
import SwiftData

struct ItemView: View {
    @Environment(\.modelContext) private var context
    @State private var showingPopup = false
    @State private var newGroupName = ""
    @State private var isShowingUpdatePopup = false
    @State private var selectedGroups: Set<ItemGroups>

    var item: CountedItem
    var allGroups: [ItemGroups]

    init(item: CountedItem, allGroups: [ItemGroups]) {
        self.item = item
        self.allGroups = allGroups
        // Ensure item.itemGroups is initialized
        if item.itemGroups == nil {
            item.itemGroups = []
        }
        // Initialize selectedGroups with the item's existing groups
        _selectedGroups = State(initialValue: Set(item.itemGroups ?? []))
    }

    var body: some View {
        HStack {
            // Display color circles next to item name if multiple groups
            if let itemGroups = item.itemGroups, itemGroups.count > 1 {
                HStack(spacing: 4) {
                    ForEach(itemGroups, id: \.self) { group in
                        Circle()
                            .fill(group.hexColor)
                            .frame(width: 12, height: 12)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                // Display item name
                Text(item.countedItemName)
                    .font(.subheadline)
                    .onTapGesture(count: 2) {
                        isShowingUpdatePopup = true
                    }

                // Custom Menu for selecting groups with checkmarks
                Menu {
                    ForEach(allGroups, id: \.self) { group in
                        Button(action: {
                            // Toggle group selection
                            if let index = item.itemGroups?.firstIndex(of: group) {
                                // Group is already selected; remove it
                                item.itemGroups?.remove(at: index)
                            } else {
                                // Group is not selected; add it
                                item.itemGroups?.append(group)
                            }
                            // Update the selected groups set
                            selectedGroups = Set(item.itemGroups ?? [])
                            // Save the context
                            do {
                                try context.save()
                            } catch {
                                print("Error saving context: \(error)")
                            }
                        }) {
                            HStack {
                                Text(group.name)
                                Spacer()
                                if let itemGroups = item.itemGroups, itemGroups.contains(group) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    // Menu label with conditional background color
                    HStack(spacing: 4) {
                        Text(item.itemGroups?.isEmpty ?? true ? "Select Groups" : item.itemGroups!.map { $0.name }.joined(separator: ", "))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        // Change background color if only one group
                        (item.itemGroups?.count == 1 ? item.itemGroups?.first?.hexColor : Color.blue) ?? Color.blue
                    )
                    .clipShape(Capsule())
                }
            }

            Spacer(minLength: 10)

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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 0)
        .background(Color.white)

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
    let group2 = ItemGroups(name: "Group B", color: "#33FF57")
    let item1 = CountedItem(countedItemName: "Sample Item", countedItemNumber: 10)
    item1.itemGroups = [group1]

    // Insert the samples into the preview container
    preview.container.mainContext.insert(group1)
    preview.container.mainContext.insert(group2)
    preview.container.mainContext.insert(item1)

    // Return the view to preview
    return ItemView(item: item1, allGroups: [group1, group2])
        .modelContainer(preview.container)
}
