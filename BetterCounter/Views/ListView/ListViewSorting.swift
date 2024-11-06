import SwiftUI
import SwiftData

// MARK: - ListViewSorting
/// The main view that displays items sorted and grouped, using a ViewModel.
struct ListViewSorting: View {
    @StateObject private var viewModel: ListViewSortingViewModel

    init(context: ModelContext, sortOrder: SortOrder, sortDirection: SortDirection, selectedGroup: ItemGroups?, searchText: String) {
        let viewModel = ListViewSortingViewModel(context: context, sortOrder: sortOrder, sortDirection: sortDirection, selectedGroup: selectedGroup, searchText: searchText)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.items.isEmpty {
                    ContentUnavailableView("No Items", systemImage: "exclamationmark.triangle")
                } else {
                    ItemListView(viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - ItemListView
/// A separate view for rendering the list of items.
struct ItemListView: View {
    @ObservedObject var viewModel: ListViewSortingViewModel

    var body: some View {
        List {
            ForEach(viewModel.groupedItems.keys.sorted(by: { $0.name < $1.name }), id: \.self) { group in
                GroupDisclosureView(group: group, viewModel: viewModel)
            }
        }
        .listStyle(.plain)
    }
}

struct GroupDisclosureView: View {
    let group: ItemGroups
    @ObservedObject var viewModel: ListViewSortingViewModel

    var body: some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: {
                    viewModel.expandedGroups.contains(group.id)
                },
                set: { isExpanded in
                    viewModel.toggleGroupExpansion(for: group.id, isExpanded: isExpanded)
                }
            )
        ) {
            ForEach(viewModel.groupedItems[group] ?? []) { item in
                // Pass the array of ItemGroups directly
                ItemView(item: item, allGroups: Array(viewModel.groupedItems.keys))
            }
        } label: {
            Text("\(group.name) (\(viewModel.groupedItems[group]?.count ?? 0))")
        }
    }
}

// MARK: - Preview
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
