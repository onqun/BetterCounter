import SwiftUI
import SwiftData

struct ListView: View {
    @State private var sortOrder = SortOrder.name
    @State private var sortDirection = SortDirection.ascending
    @State private var selectedGroup: ItemGroups?
    @State private var searchText: String = ""
    @State private var isGroupingEnabled = true
    @State private var isShowingNewItemPopup = false
    @State private var isShowingUpdatePopup = false
    @State private var selectedItem: CountedItem? // Added selectedItem for updates

    @Environment(\.modelContext) private var context

    @Query(sort: \CountedItem.countedItemName) private var items: [CountedItem]
    @Query private var precomputedGroups: [ItemGroups]

    private var precomputedGroupCounts: [ItemGroups: Int] {
        var counts: [ItemGroups: Int] = [:]
        for group in precomputedGroups {
            let count = items.filter { $0.itemGroups?.contains(group) ?? false }.count
            counts[group] = count
        }
        return counts
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        SortOptionsView(sortOrder: $sortOrder, sortDirection: $sortDirection)
                        GroupOptionsView(
                            selectedGroup: $selectedGroup,
                            isGroupingEnabled: $isGroupingEnabled,
                            items: items,
                            precomputedGroups: precomputedGroups,
                            precomputedGroupCounts: precomputedGroupCounts
                        )
                    }
                    .padding()

                    TextField("Search...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 50)

                    if isGroupingEnabled {
                        groupedListView()
                    } else {
                        ungroupedListView()
                    }
                }
                .navigationTitle("My List")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingNewItemPopup = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { /* Settings action */ }) {
                            Image(systemName: "gear")
                        }
                    }
                }

                if isShowingNewItemPopup {
                    NewItemPopupView(isShowing: $isShowingNewItemPopup, mode: .add)
                        .transition(.scale)
                }

                if isShowingUpdatePopup, let item = selectedItem {
                    NewItemPopupView(isShowing: $isShowingUpdatePopup, mode: .update, itemToUpdate: item)
                        .transition(.scale)
                }
            }
        }
    }

    @ViewBuilder
    func groupedListView() -> some View {
        List {
            ForEach(precomputedGroups, id: \.self) { group in
                Section(header: Text(group.name)) {
                    let filteredItems = itemsForGroup(group)
                    if filteredItems.isEmpty {
                        Text("No items in this group")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    } else {
                        ForEach(filteredItems, id: \.id) { item in
                            // Pass allGroups argument to ItemView
                            ItemView(item: item, allGroups: precomputedGroups)
                                .onTapGesture {
                                    selectedItem = item
                                    isShowingUpdatePopup = true
                                }
                        }
                        .onDelete { indexSet in
                            Task {
                                await handleDelete(at: indexSet, from: filteredItems)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    func ungroupedListView() -> some View {
        List {
            let sortedItems = sortedItemsList()
            ForEach(sortedItems, id: \.id) { item in
                // Pass allGroups argument to ItemView
                ItemView(item: item, allGroups: precomputedGroups)
                    .onTapGesture {
                        selectedItem = item
                        isShowingUpdatePopup = true
                    }
            }
            .onDelete { indexSet in
                Task {
                    await handleDelete(at: indexSet, from: sortedItems)
                }
            }
        }
        .listStyle(.plain)
    }

    func itemsForGroup(_ group: ItemGroups) -> [CountedItem] {
        return items.filter { item in
            item.itemGroups?.contains(group) ?? false &&
            (searchText.isEmpty || item.countedItemName.localizedCaseInsensitiveContains(searchText))
        }
    }

    func sortedItemsList() -> [CountedItem] {
        return items.sorted { (lhs: CountedItem, rhs: CountedItem) in
            switch sortOrder {
            case .name:
                return sortDirection == .ascending ? lhs.countedItemName < rhs.countedItemName : lhs.countedItemName > rhs.countedItemName
            case .count:
                return sortDirection == .ascending ? lhs.countedItemNumber < rhs.countedItemNumber : lhs.countedItemNumber > rhs.countedItemNumber
            }
        }
    }

    func handleDelete(at offsets: IndexSet, from itemList: [CountedItem]) async {
        for index in offsets {
            let item = itemList[index]
            context.delete(item)
        }

        do {
            try context.save()
        } catch {
            print("Failed to save context after deletion: \(error)")
        }
    }
}

#Preview {
    let preview = Preview()
    let items = CountedItem.sampleItems
    let itemGroups = ItemGroups.sampleGroup

    preview.addExamples(items)
    preview.addExamples(itemGroups)

    return ListView()
        .modelContainer(preview.container)
}
