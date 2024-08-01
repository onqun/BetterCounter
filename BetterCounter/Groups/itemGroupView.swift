import SwiftUI
import SwiftData

struct ItemGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var countedItem: CountedItem
    @Query(sort: \ItemGroups.name) var itemGroups: [ItemGroups]
    
    var body: some View {
        NavigationStack {
            Group {
                if itemGroups.isEmpty {
                    ContentUnavailableView {
                        Image(systemName: "bookmark.fill")
                            .font(.largeTitle)
                    } description: {
                        Text("You need to create a group first")
                    } actions: {
                        Button("Create a Group") {
                            createGroup()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(itemGroups) { group in
                            HStack {
                                Button {
                                    addRemove(itemGroup: group)
                                } label: {
                                    Image(systemName: countedItem.itemGroups?.contains(where: { $0.id == group.id }) == true ? "checkmark.circle.fill" : "circle")
                                }
                                .foregroundColor(group.hexColor)
                                Text(group.name)
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(countedItem.countedItemName)
 
    }
    
    func addRemove(itemGroup: ItemGroups) {
        guard let itemGroups = countedItem.itemGroups else {
            countedItem.itemGroups = [itemGroup]
            return
        }
        
        if let index = itemGroups.firstIndex(where: { $0.id == itemGroup.id }) {
            countedItem.itemGroups?.remove(at: index)
        } else {
            countedItem.itemGroups?.append(itemGroup)
        }
    }
    
    func createGroup() {
        let newGroup = ItemGroups(name: "New Group", color: "#FFFFFF")
        context.insert(newGroup)
        
        // Automatically associate the new group with the counted item
        addRemove(itemGroup: newGroup)
        
        do {
            try context.save()
        } catch {
            print("Error saving new group: \(error)")
        }
    }
}

#Preview {
    let preview = Preview()

    let items = CountedItem.sampleItems
    let groups = ItemGroups.sampleGroup
    
    preview.addExamples(items)
    preview.addExamples(groups)
    
    // Assign the group to the item correctly
    items[1].itemGroups?.append(groups[0])

    // Correct the initialization of ItemGroupView with the correct parameter name
    return ItemGroupView(countedItem: items[1])
        .modelContainer(preview.container) // Ensure modelContainer correctly takes preview.container as an argument.
}
