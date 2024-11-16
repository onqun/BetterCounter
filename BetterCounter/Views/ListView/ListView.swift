import SwiftUI
import SwiftData

struct ListView: View {
    @State private var sortOrder = SortOrder.name
    @State private var sortDirection = SortDirection.ascending
    @State private var selectedGroup: ItemGroups?
    @State private var searchText: String = ""
    @State private var isShowingNewItemPopup = false
    @State private var isShowingUpdatePopup = false
    @Binding var presentSideMenu: Bool
    @State private var selectedItem: CountedItem?
    @State private var cachedFilteredAndSortedItems: [CountedItem] = []

    @Environment(\.modelContext) private var context

    @Query private var items: [CountedItem]
    @Query private var precomputedGroups: [ItemGroups]

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        SortOptionsView(sortOrder: $sortOrder, sortDirection: $sortDirection)
                        GroupOptionsView(
                            selectedGroup: $selectedGroup,
                            items: items,
                            precomputedGroups: precomputedGroups,
                            precomputedGroupCounts: precomputedGroupCounts()
                        )
                    }
                    .padding()

                    TextField("Search...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 50)

                    // Adjusted the view logic
                    itemListView()
                }
                .navigationTitle("My List")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingNewItemPopup = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        
                        Button(action: {
                            presentSideMenu.toggle()
                        }) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .onAppear(perform: updateFilteredAndSortedItems)
                .onChange(of: searchText) { _ in
                    updateFilteredAndSortedItems()
                }
                .onChange(of: sortOrder) { _ in
                    updateFilteredAndSortedItems()
                }
                .onChange(of: sortDirection) { _ in
                    updateFilteredAndSortedItems()
                }
                .onReceive(items.publisher.collect()) { _ in
                    updateFilteredAndSortedItems()
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
    func itemListView() -> some View {
        if let selectedGroup = selectedGroup {
            // Display items filtered by the selected group
            let filteredItems = cachedFilteredAndSortedItems.filter { item in
                item.itemGroups?.contains(selectedGroup) ?? false
            }
            if filteredItems.isEmpty {
                Text("No items in this group")
                    .font(.footnote)
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(filteredItems, id: \.id) { item in
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
                .listStyle(.plain)
            }
        } else {
            // Display all items grouped by their groups
            let groupedItems = groupItemsByGroups()
            let sortedGroupKeys = groupedItems.keys.sorted(by: { $0.name < $1.name })

            if groupedItems.isEmpty {
                Text("No items available")
                    .font(.footnote)
                    .foregroundColor(.gray)
            } else {
                List {
                    ForEach(sortedGroupKeys, id: \.id) { group in
                        Section(header: Text(group.name)) {
                            let itemsInGroup = groupedItems[group] ?? []
                            ForEach(itemsInGroup, id: \.id) { item in
                                ItemView(item: item, allGroups: precomputedGroups)
                                    .onTapGesture {
                                        selectedItem = item
                                        isShowingUpdatePopup = true
                                    }
                            }
                            .onDelete { indexSet in
                                Task {
                                    await handleDelete(at: indexSet, from: itemsInGroup)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
    }

    func updateFilteredAndSortedItems() {
        cachedFilteredAndSortedItems = filteredAndSortedItems()
    }

    func groupItemsByGroups() -> [ItemGroups: [CountedItem]] {
        var groupedItems: [ItemGroups: [CountedItem]] = [:]

        let ungroupedGroup = ItemGroups.ungroupedGroup

        let itemsToGroup = cachedFilteredAndSortedItems

        for item in itemsToGroup {
            let groups = item.itemGroups ?? []
            if groups.isEmpty {
                groupedItems[ungroupedGroup, default: []].append(item)
            } else {
                for group in groups {
                    groupedItems[group, default: []].append(item)
                }
            }
        }

        return groupedItems
    }

    func filteredAndSortedItems() -> [CountedItem] {
        let filteredItems = items.filter { item in
            searchText.isEmpty || item.countedItemName.localizedCaseInsensitiveContains(searchText)
        }

        return filteredItems.sorted { lhs, rhs in
            switch sortOrder {
            case .name:
                return sortDirection == .ascending ? lhs.countedItemName < rhs.countedItemName : lhs.countedItemName > rhs.countedItemName
            case .count:
                return sortDirection == .ascending ? lhs.countedItemNumber < rhs.countedItemNumber : lhs.countedItemNumber > rhs.countedItemNumber
            }
        }
    }

    func precomputedGroupCounts() -> [ItemGroups: Int] {
        var counts: [ItemGroups: Int] = [:]
        for group in precomputedGroups {
            let count = items.filter { $0.itemGroups?.contains(group) ?? false }.count
            counts[group] = count
        }
        return counts
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
