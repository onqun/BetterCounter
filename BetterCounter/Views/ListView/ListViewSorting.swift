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
                    // Convert group.id to UUID if possible
                    viewModel.expandedGroups.contains(group.id)
                },
                set: { isExpanded in
                    // Convert group.id to UUID if possible
                        viewModel.toggleGroupExpansion(for: group.id, isExpanded: isExpanded)
                }
            )
        ) {
            ForEach(viewModel.groupedItems[group] ?? []) { item in
                ItemView(item: item)
            }
        } label: {
            Text("\(group.name) (\(viewModel.groupedItems[group]?.count ?? 0))")
        }
    }
}
// MARK: - Preview
#Preview {
    let preview = Preview()

    // Sample data for preview
    let group1 = ItemGroups(name: "Group A", color: "#FF5733")
    let group2 = ItemGroups(name: "Group B", color: "#33FF57")
    let item1 = CountedItem(countedItemName: "Sample Item 1", countedItemNumber: 10)
    let item2 = CountedItem(countedItemName: "Sample Item 2", countedItemNumber: 5)
    item1.itemGroups = [group1]
    item2.itemGroups = [group2]

    return ListViewSorting(context: preview.container.mainContext, sortOrder: .name, sortDirection: .ascending, selectedGroup: nil, searchText: "")
        .modelContainer(preview.container)
}
