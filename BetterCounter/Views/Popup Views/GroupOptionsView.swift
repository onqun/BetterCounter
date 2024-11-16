// GroupOptionsView.swift

import SwiftUI
import SwiftData

@MainActor
struct GroupOptionsView: View {
    @Binding var selectedGroup: ItemGroups?

    var items: [CountedItem]
    var precomputedGroups: [ItemGroups]
    var precomputedGroupCounts: [ItemGroups: Int]  // Store counts for each group

    var body: some View {
        Menu {
            // Option to show all groups (enable grouping)
            Button(action: {
                selectedGroup = nil
            }) {
                HStack {
                    Text("All Groups")
                    Spacer()
                    if selectedGroup == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            // List all available groups with their item counts
            ForEach(precomputedGroups, id: \.self) { group in
                Button(action: {
                    selectedGroup = group
                }) {
                    HStack {
                        Text("\(group.name) (\(precomputedGroupCounts[group] ?? 0))")
                        Spacer()
                        if selectedGroup == group {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Groups", systemImage: "folder")
                .padding()
        }
    }
}

#Preview("GroupOptionsView Preview") {
    // Initialize ModelContainer directly without using a separate Preview struct
    let container = try! ModelContainer(for: ItemGroups.self, CountedItem.self)

    // Sample data
    let group1 = ItemGroups(name: "Group A", color: "#FF5733")
    let group2 = ItemGroups(name: "Group B", color: "#33FF57")
    let item1 = CountedItem(countedItemName: "Sample Item 1", countedItemNumber: 10, itemGroups: [group1])
    let item2 = CountedItem(countedItemName: "Sample Item 2", countedItemNumber: 5, itemGroups: [group2])
    let items = [item1, item2]
    let itemGroups = [group1, group2]

    // Precompute groups and their counts
    let precomputedGroups = itemGroups
    let precomputedGroupCounts = Dictionary(uniqueKeysWithValues: precomputedGroups.map { group in
        (group, items.filter { $0.itemGroups?.contains(group) ?? false }.count)
    })

    GroupOptionsView(
        selectedGroup: .constant(group1),
        items: items,
        precomputedGroups: precomputedGroups,
        precomputedGroupCounts: precomputedGroupCounts
    )
}
