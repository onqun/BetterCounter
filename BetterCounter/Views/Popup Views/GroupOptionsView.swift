import SwiftUI
import SwiftData

@MainActor
struct GroupOptionsView: View {
    @Binding var selectedGroup: ItemGroups?
    @Binding var isGroupingEnabled: Bool
    
    var items: [CountedItem]
    var precomputedGroups: [ItemGroups]
    var precomputedGroupCounts: [ItemGroups: Int]  // Store counts for each group

    var body: some View {
        Menu {
            // Toggle grouping functionality
            Button(action: { isGroupingEnabled.toggle() }) {
                HStack {
                    Text("Enable Grouping")
                    Spacer()
                    if isGroupingEnabled {
                        Image(systemName: "checkmark")
                    }
                }
            }

            // Option to show all groups
            Button(action: { selectedGroup = nil }) {
                HStack {
                    Text("All Groups")
                    if selectedGroup == nil {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }

            // List all available groups with their item counts
            ForEach(precomputedGroups, id: \.self) { group in
                Button(action: {
                    selectedGroup = group
                }) {
                    HStack {
                        Text("\(group.name) (\(precomputedGroupCounts[group] ?? 0))")
                        if selectedGroup == group {
                            Spacer()
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

#Preview {
    let preview = Preview()

    let items = CountedItem.sampleItems
    let itemGroups = ItemGroups.sampleGroup

    // Precompute groups and their counts (no async required for the preview)
    let precomputedGroups = itemGroups
    let precomputedGroupCounts = Dictionary(uniqueKeysWithValues: precomputedGroups.map { group in
        (group, items.filter { $0.itemGroups?.contains(group) ?? false }.count)
    })

    return GroupOptionsView(
        selectedGroup: .constant(itemGroups.first),
        isGroupingEnabled: .constant(true),
        items: items,
        precomputedGroups: precomputedGroups,
        precomputedGroupCounts: precomputedGroupCounts
    )
    .modelContainer(preview.container)
}
