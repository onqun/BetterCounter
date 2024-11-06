import SwiftUI
import SwiftData

struct ItemView: View {
    @Environment(\.modelContext) private var context
    @State private var showingPopup = false
    @State private var newGroupName = ""
    @State private var isShowingUpdatePopup = false
    @State private var selectedGroup: ItemGroups?  // State to hold the selected group

    var item: CountedItem
    var allGroups: [ItemGroups]  // Pass all available groups to the view

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Display item name
                Text(item.countedItemName)
                    .font(.subheadline)
                    .onTapGesture(count: 2) {  // Double-tap gesture to show update popup
                        isShowingUpdatePopup = true
                    }

                // Dropdown menu for selecting groups
                Picker("Select Group", selection: $selectedGroup) {
                    ForEach(allGroups, id: \.self) { group in
                        Text(group.name).tag(group as ItemGroups?)
                    }
                }
                .pickerStyle(MenuPickerStyle())  // Use MenuPickerStyle for a dropdown appearance
                .onChange(of: selectedGroup) {
                    if let newGroup = $0 {
                        item.itemGroups = [newGroup]
                        do {
                            try context.save()
                        } catch {
                            print("Error saving context: \(error)")
                        }
                    }
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
    return ItemView(item: item1, allGroups: [group1, group2])  // Pass all available groups
        .modelContainer(preview.container)
}
