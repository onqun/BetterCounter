import SwiftUI
import SwiftData

// MARK: - PopupMode Enum
/// Enum to define the mode of the popup: either adding a new item or updating an existing one.
enum PopupMode {
    case add
    case update
}

// MARK: - NewItemPopupView
/// A view for adding or updating a `CountedItem`, with fields to enter item details and select groups.
struct NewItemPopupView: View {
    @Binding var isShowing: Bool
    var mode: PopupMode
    var itemToUpdate: CountedItem? // Optional, only set if updating an item

    @Environment(\.modelContext) private var context
    @State private var itemName: String = ""
    @State private var itemCount: Int = 0
    @State private var itemGroupName = ""
    @State private var selectedGroups = Set<ItemGroups>()

    // Automatically fetch all available `ItemGroups` from the SwiftData context
    @Query private var availableGroups: [ItemGroups]

    // MARK: - Initialization Logic for Updates
    /// Sets up the view with the details of the item to update, if available.
    private func setupItemForUpdate() {
        guard let item = itemToUpdate else { return }
        itemName = item.countedItemName
        itemCount = item.countedItemNumber
        if let groups = item.itemGroups {
            selectedGroups = Set(groups)
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // Dimmed background to create a modal effect
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss the popup when tapping outside
                    isShowing = false
                }

            // Popup content
            VStack {
                Text(mode == .add ? "Add New Item" : "Update Item")
                    .font(.headline)
                    .padding()

                // ScrollView for input fields
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // Item Name Field
                        TextField("Name", text: $itemName)
                            .disableAutocorrection(true)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        // Item Count Stepper
                        Stepper(value: $itemCount, in: 0...10000000, step: 1) {
                            Text("Count: \(itemCount)")
                        }

                        // Group Name Field for adding new groups
                        TextField("Add New Group", text: $itemGroupName, onCommit: {
                            guard !itemGroupName.isEmpty else { return }
                            do {
                                try addGroup(newGroupName: itemGroupName, availableGroups: availableGroups, selectedGroups: &selectedGroups, context: context)
                                itemGroupName = ""
                            } catch {
                                print("Failed to add group: \(error)")
                            }
                        })
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                        // List of Available Groups
                        Section(header: Text("Groups")) {
                            ForEach(availableGroups, id: \.self) { group in
                                HStack {
                                    Text(group.name)
                                    Spacer()
                                    if selectedGroups.contains(group) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .onTapGesture {
                                                toggleGroup(group, selectedGroups: &selectedGroups)
                                            }
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                            .onTapGesture {
                                                toggleGroup(group, selectedGroups: &selectedGroups)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }

                // Action Buttons: Add/Update and Cancel
                HStack {
                    Button(mode == .add ? "Add" : "Update") {
                        Task {
                            if mode == .add {
                                // Logic for adding a new item
                                let newItem = CountedItem(countedItemName: itemName, countedItemNumber: itemCount)
                                do {
                                    try configureAndSaveItem(newItem: newItem, context: context, selectedGroups: selectedGroups) { item, _, _, groups in
                                        item.itemGroups = Array(groups)
                                    }
                                    isShowing = false
                                } catch {
                                    print("Failed to save item: \(error)")
                                }
                            } else if mode == .update, let item = itemToUpdate {
                                // Logic for updating an existing item
                                item.countedItemName = itemName
                                item.countedItemNumber = itemCount
                                item.itemGroups = Array(selectedGroups)
                                do {
                                    try context.save()
                                    isShowing = false
                                } catch {
                                    print("Failed to update item: \(error)")
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(itemName.isEmpty) // Disable if the item name is empty

                    Button("Cancel") {
                        isShowing = false
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 20)
            .frame(maxWidth: 350, maxHeight: 400)
            .onAppear {
                if mode == .update {
                    setupItemForUpdate()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NewItemPopupView(isShowing: .constant(true), mode: .add)
}
