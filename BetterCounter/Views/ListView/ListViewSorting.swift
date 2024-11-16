// ListViewSorting.swift

import SwiftUI
import SwiftData

// MARK: - ListViewSorting
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
            .navigationTitle("BetterCounter")
            .toolbar {
                // Add toolbar items here if needed
            }
        }
    }
}

// MARK: - ItemListView
struct ItemListView: View {
    @ObservedObject var viewModel: ListViewSortingViewModel

    var body: some View {
        List {
            ForEach(viewModel.groupedItems.keys.sorted(by: { $0.name < $1.name }), id: \.self) { group in
                GroupDisclosureView(group: group, viewModel: viewModel, allGroups: viewModel.allGroups)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - GroupDisclosureView
struct GroupDisclosureView: View {
    let group: ItemGroups
    @ObservedObject var viewModel: ListViewSortingViewModel
    var allGroups: [ItemGroups] // Ensure this property is correctly passed

    var body: some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { viewModel.expandedGroups.contains(group.id) },
                set: { isExpanded in viewModel.toggleGroupExpansion(for: group.id, isExpanded: isExpanded) }
            )
        ) {
            ForEach(viewModel.groupedItems[group] ?? []) { item in
                ItemView(item: item)
            }
        } label: {
            Text("\(group.name) (\(viewModel.groupedItems[group]?.count ?? 0))")
                .font(.headline)
        }
    }
}

// MARK: - ItemView
struct ItemView: View {
    let item: CountedItem

    var body: some View {
        HStack {
            Text(item.countedItemName)
                .font(.body)
            Spacer()
            Text("Count: \(item.countedItemNumber)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct ListViewSorting_Previews: PreviewProvider {
    static var previews: some View {
        // Using the user's defined sample sets for preview
        ListViewSorting(
            context: ModelContainer(for: ItemGroups.self, CountedItem.self).mainContext,
            sortOrder: .name,
            sortDirection: .ascending,
            selectedGroup: ItemGroups.sampleGroup.first,
            searchText: ""
        )
    }
}
