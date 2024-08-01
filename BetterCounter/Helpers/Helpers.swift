import Foundation
import SwiftData

// MARK: - Item Modification Functions

// Async function to save the new name of a CountedItem and save it to the context
@MainActor
func saveNewName(_ item: CountedItem, newName: String, context: ModelContext) async throws {
    item.countedItemName = newName
    try await saveContext(context)
}

// Async function to increment the count and save the context
@MainActor
func incrementCount(_ item: CountedItem, context: ModelContext) async throws {
    item.countedItemNumber += 1
    try await saveContext(context)
}

// Async function to decrement the count and save it if the count is above zero
@MainActor
func decrementCount(_ item: CountedItem, context: ModelContext) async throws {
    guard item.countedItemNumber > 0 else { return }
    item.countedItemNumber -= 1
    try await saveContext(context)
}

// MARK: - Group Membership Functions

// Async function to toggle group membership of a CountedItem
@MainActor
func toggleGroupMembership(_ item: CountedItem, group: ItemGroups, context: ModelContext) async throws {
    if let index = item.itemGroups?.firstIndex(of: group) {
        item.itemGroups?.remove(at: index)
    } else {
        if item.itemGroups == nil { item.itemGroups = [] }
        item.itemGroups?.append(group)
    }
    try await saveContext(context)
}

// NOTE: Synchronous function to add a new group and assign it to a CountedItem
@MainActor
func addGroup(
    newGroupName: String,
    availableGroups: [ItemGroups],
    selectedGroups: inout Set<ItemGroups>,
    context: ModelContext
) throws {
    // Check if the new group name is empty and throw a custom error if so
    guard !newGroupName.isEmpty else {
        throw AppError.emptyGroupName
    }

    // Check if the group already exists in availableGroups
    if !availableGroups.contains(where: { $0.name == newGroupName }) {
        // Create a new group with the provided name and a default color
        let newGroup = ItemGroups(name: newGroupName, color: "#FFFFFF")
        context.insert(newGroup)  // Insert the new group into the context
        selectedGroups.insert(newGroup)  // Add the new group to selectedGroups
    }

    // Save the context synchronously
    try context.save()
}

// MARK: - Utility Functions

// Async function to get all unique groups from the CountedItems
func allGroups(items: [CountedItem]) async throws -> [ItemGroups] {
    let uniqueGroups = try await withThrowingTaskGroup(of: [ItemGroups].self) { group in
        for item in items {
            group.addTask {
                return item.itemGroups ?? []
            }
        }

        var allGroups: [ItemGroups] = []
        for try await itemGroups in group {
            allGroups.append(contentsOf: itemGroups)
        }

        return Set(allGroups) // Remove duplicates
    }

    return Array(uniqueGroups)
}

// MARK: - Item Filtering and Sorting

// Async function to count the items in a specific group
func countItems(in group: ItemGroups, items: [CountedItem]) async -> Int {
    return await Task {
        items.filter { $0.itemGroups?.contains(group) ?? false }.count
    }.value
}

// Async function to filter and sort items
func filterSortItems<T: Identifiable & Equatable>(
    items: [T],
    searchText: String,
    selectedGroup: ItemGroups?,
    sortOrder: SortOrder,
    sortDirection: SortDirection,
    matchesSearchText: @escaping (T, String) -> Bool,
    sortByName: KeyPath<T, String>,
    sortByNumber: KeyPath<T, Int>
) async -> [T] {
    // Filter and sort the items asynchronously
    return await Task {
        let filteredItems = items.filter { item in
            let matchesGroup = selectedGroup.map { (item as? CountedItem)?.itemGroups?.contains($0) ?? true } ?? true
            let matchesText = searchText.isEmpty || matchesSearchText(item, searchText.lowercased())
            return matchesGroup && matchesText
        }

        return filteredItems.sorted {
            switch sortOrder {
            case .name:
                return sortDirection == .ascending ? $0[keyPath: sortByName] < $1[keyPath: sortByName] : $0[keyPath: sortByName] > $1[keyPath: sortByName]
            case .count:
                return sortDirection == .ascending ? $0[keyPath: sortByNumber] < $1[keyPath: sortByNumber] : $0[keyPath: sortByNumber] > $1[keyPath: sortByNumber]
            }
        }
    }.value
}

// MARK: - Data Erasure Functions

// Async function to erase a value from multiple collections
func eraseData<T: Equatable>(from collections: inout [[T]], value: T) async {
    var localCollections = collections
    await Task {
        for i in 0..<localCollections.count {
            localCollections[i].removeAll { $0 == value }
        }
    }.value
    collections = localCollections
}

// Async function to erase a value from a set
func eraseData<T: Equatable>(from set: inout Set<T>, value: T) async {
    var localSet = set
    _ = await Task { localSet.remove(value) }.value
    set = localSet
}

// MARK: - Grouping and Filtering Items

// Async function to group items by their groups
func groupItems(_ items: [CountedItem]) async -> [ItemGroups: [CountedItem]] {
    return await Task {
        var grouped: [ItemGroups: [CountedItem]] = [:]
        for item in items {
            if let groups = item.itemGroups {
                for group in groups {
                    grouped[group, default: []].append(item)
                }
            }
        }
        return grouped
    }.value
}

// Async function to filter items by group and search text
func filteredItems(for group: ItemGroups, in groupedItems: [ItemGroups: [CountedItem]], searchText: String) async -> [CountedItem] {
    return await Task {
        groupedItems[group]?.filter { searchText.isEmpty || $0.countedItemName.lowercased().contains(searchText.lowercased()) } ?? []
    }.value
}

// MARK: - Context and Collection Utilities

// Utility function to save context asynchronously
@MainActor
func saveContext(_ context: ModelContext) async throws {
    try await Task {
        try context.save()
    }.value
}

// Utility function to update an inout collection asynchronously
func updateCollectionAsync<T: Hashable>(_ collection: inout Set<T>, item: T) async {
    var localCollection = collection
    await Task {
        if localCollection.contains(item) {
            localCollection.remove(item)
        } else {
            localCollection.insert(item)
        }
    }.value
    collection = localCollection
}

// Utility function to modify a collection asynchronously
func modifyCollectionAsync<T: Equatable>(_ collection: inout [T], value: T, add: Bool = true) async {
    var localCollection = collection
    await Task {
        if add {
            localCollection.append(value)
        } else {
            localCollection.removeAll { $0 == value }
        }
    }.value
    collection = localCollection
}

// MARK: - Group Selection

// Synchronous function to toggle the presence of a group in the selected groups set
func toggleGroup<Group: Hashable>(_ group: Group, selectedGroups: inout Set<Group>) {
    if selectedGroups.contains(group) {
        selectedGroups.remove(group)
    } else {
        selectedGroups.insert(group)
    }
}

// NOTE: Function to configure and save an item without 'async' and 'await'
@MainActor
func configureAndSaveItem(
    newItem: CountedItem,
    context: ModelContext,
    selectedGroups: Set<ItemGroups>,
    configure: (CountedItem, String, Int, Set<ItemGroups>) -> Void
) throws {
    // Configure the new item using the closure
    configure(newItem, newItem.countedItemName, newItem.countedItemNumber, selectedGroups)

    // Insert the item into the context
    context.insert(newItem)

    // Save the context
    try context.save()
    print("Item saved successfully!")
}
