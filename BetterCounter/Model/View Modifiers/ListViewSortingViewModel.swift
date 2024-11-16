// ListViewSortingViewModel.swift

import SwiftData
import SwiftUI
import Combine

class ListViewSortingViewModel: ObservableObject {
    // Use a Set to store unique PersistentIdentifiers of expanded groups
    @Published var expandedGroups: Set<PersistentIdentifier> = []
    
    // Dictionary mapping ItemGroups to their items
    @Published var groupedItems: [ItemGroups: [CountedItem]] = [:]
    
    // All items fetched from the context
    @Published var items: [CountedItem] = []
    
    private var context: ModelContext
    private var cancellables = Set<AnyCancellable>()
    
    init(context: ModelContext, sortOrder: SortOrder, sortDirection: SortDirection, selectedGroup: ItemGroups?, searchText: String) {
        self.context = context
        // Initialize and fetch items based on sortOrder, sortDirection, selectedGroup, and searchText
        fetchItems(sortOrder: sortOrder, sortDirection: sortDirection, selectedGroup: selectedGroup, searchText: searchText)
    }
    
    func fetchItems(sortOrder: SortOrder, sortDirection: SortDirection, selectedGroup: ItemGroups?, searchText: String) {
        // Fetch and sort items from the context based on the parameters
        // Replace this placeholder with your actual fetching and sorting logic
        
        // Example:
        let request: FetchRequest<CountedItem> = CountedItem.fetchRequest()
        // Apply sorting and filtering to the request based on sortOrder, sortDirection, selectedGroup, searchText
        
        do {
            let fetchedItems = try context.fetch(request)
            self.items = fetchedItems.filter { item in
                // Apply filtering logic based on selectedGroup and searchText
                var matchesGroup = true
                if let selectedGroup = selectedGroup {
                    matchesGroup = item.itemGroups?.contains(selectedGroup) ?? false
                }
                var matchesSearch = true
                if !searchText.isEmpty {
                    matchesSearch = item.countedItemName.localizedCaseInsensitiveContains(searchText)
                }
                return matchesGroup && matchesSearch
            }
            self.groupedItems = Dictionary(grouping: self.items, by: { $0.itemGroups?.first ?? ItemGroups.ungroupedGroup })
        } catch {
            print("Error fetching items: \(error)")
        }
    }
    
    func toggleGroupExpansion(for groupId: PersistentIdentifier, isExpanded: Bool) {
        if isExpanded {
            expandedGroups.insert(groupId)
        } else {
            expandedGroups.remove(groupId)
        }
    }
}
