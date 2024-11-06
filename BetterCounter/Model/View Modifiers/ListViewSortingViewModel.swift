import SwiftData
import SwiftUI

// MARK: - ListViewSortingViewModel
/// Handles the business logic for sorting, filtering, and grouping items.
class ListViewSortingViewModel: ObservableObject {
    @Published var items: [CountedItem] = []
    @Published var groupedItems: [ItemGroups: [CountedItem]] = [:]
    @Published var expandedGroups: Set<UUID> = []
    @Published var searchText: String
    

    var context: ModelContext
    var sortOrder: SortOrder
    var sortDirection: SortDirection
    var selectedGroup: ItemGroups?

    init(
        context: ModelContext, sortOrder: SortOrder,
        sortDirection: SortDirection, selectedGroup: ItemGroups?,
        searchText: String
    ) {
        self.context = context
        self.sortOrder = sortOrder
        self.sortDirection = sortDirection
        self.selectedGroup = selectedGroup
        self.searchText = searchText

        fetchData()
    }

    // MARK: - Data Fetching
    private func fetchData() {
        items = fetchItemsFromContext()
        updateFilteredAndSortedItems()
    }

    private func fetchItemsFromContext() -> [CountedItem] {
        // Example data fetching logic
        return []  // Replace with your actual fetching logic
    }

    // MARK: - Filtering and Sorting
    func updateFilteredAndSortedItems() {
        Task {
            let updatedItems = await filterSortItems(
                items: items,
                searchText: searchText,  // Use `searchText` here
                selectedGroup: selectedGroup,
                sortOrder: sortOrder,
                sortDirection: sortDirection,
                matchesSearchText: { item, text in
                    item.countedItemName.lowercased().contains(text)
                },
                sortByName: \.countedItemName,
                sortByNumber: \.countedItemNumber
            )
            DispatchQueue.main.async {
                self.items = updatedItems
                self.groupedItems = self.groupItems(self.items)  // Use the return value to update groupedItems
            }
        }
    }

    // Filter items by search text
    private func filterItems(_ items: [CountedItem], searchText: String)
        -> [CountedItem]
    {
        guard !searchText.isEmpty else {
            return items
        }
        return items.filter {
            $0.countedItemName.lowercased().contains(searchText.lowercased())
        }
    }

    // Inside ListViewSortingViewModel

    // Sort and group items
    private func sortAndGroupItems(_ items: [CountedItem]) -> [ItemGroups:
        [CountedItem]]
    {
        // Step 1: Filter items using the searchText
        let filteredItems = filterItems(items, searchText: searchText)

        // Step 2: Sort the filtered items
        let sortedItems: [CountedItem]
        switch sortOrder {
        case .name:
            if sortDirection == .ascending {
                sortedItems = filteredItems.sorted {
                    $0.countedItemName < $1.countedItemName
                }
            } else {
                sortedItems = filteredItems.sorted {
                    $0.countedItemName > $1.countedItemName
                }
            }
        case .count:
            if sortDirection == .ascending {
                sortedItems = filteredItems.sorted {
                    $0.countedItemNumber < $1.countedItemNumber
                }
            } else {
                sortedItems = filteredItems.sorted {
                    $0.countedItemNumber > $1.countedItemNumber
                }
            }
        }

        // Step 3: Group the sorted items and return the grouped dictionary
        return groupItems(sortedItems)
    }

    // Group items by their groups and return the dictionary
    private func groupItems(_ items: [CountedItem]) -> [ItemGroups:
        [CountedItem]]
    {
        var grouped: [ItemGroups: [CountedItem]] = [:]
        for item in items {
            if let groups = item.itemGroups {
                for group in groups {
                    grouped[group, default: []].append(item)
                }
            }
        }
        return grouped
    }

    // MARK: - Async Fetch Function (Mock)
    private func fetchItems() async throws -> [CountedItem] {
        try await Task.sleep(nanoseconds: 1_000_000_000)  // 1-second delay for demonstration
        let group1 = ItemGroups(name: "Group A", color: "#FF5733")
        let group2 = ItemGroups(name: "Group B", color: "#33FF57")
        let item1 = CountedItem(
            countedItemName: "Sample Item 1", countedItemNumber: 10)
        let item2 = CountedItem(
            countedItemName: "Sample Item 2", countedItemNumber: 5)
        item1.itemGroups = [group1]
        item2.itemGroups = [group2]
        return [item1, item2]
    }

    // MARK: - Group Expansion Handling
    func toggleGroupExpansion(for id: UUID, isExpanded: Bool) {
        if isExpanded {
            expandedGroups.insert(id)
        } else {
            expandedGroups.remove(id)
        }
    }
}
