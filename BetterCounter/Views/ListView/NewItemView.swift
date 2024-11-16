import SwiftUI
import SwiftData

struct NewItemPopupView: View {
    @Binding var isShowing: Bool
    var mode: PopupMode
    var itemToUpdate: CountedItem? // Optional, only set if updating an item

    @Environment(\.modelContext) private var context
    @State private var itemName: String = ""
    @State private var itemCount: Int = 0
    @State private var newGroupName: String = ""
    @State private var selectedGroups: Set<ItemGroups> = []
    @State private var newGroupColor: Color = .blue
    @State private var errorMessage: String?

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
            VStack(spacing: 20) {
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

                        // Add New Group Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Add New Group")
                                .font(.subheadline)

                            HStack {
                                TextField("Group Name", text: $newGroupName)
                                    .disableAutocorrection(true)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                ColorPicker("", selection: $newGroupColor)
                                    .labelsHidden()
                            }

                            Button(action: {
                                addNewGroup()
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Group")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(newGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.green.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .disabled(newGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }

                        // List of Available Groups
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Select Groups")
                                .font(.subheadline)

                            ForEach(availableGroups) { group in
                                HStack {
                                    Text(group.name)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(group.groupColor.opacity(0.2))
                                        )
                                    Spacer()
                                    Image(systemName: selectedGroups.contains(group) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedGroups.contains(group) ? .green : .gray)
                                        .onTapGesture {
                                            toggleGroupSelection(group)
                                        }
                                        .contentShape(Rectangle())
                                }
                            }
                        }
                    }
                    .padding()
                }

                // Error Message Display
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                // Action Buttons: Add/Update and Cancel
                HStack {
                    Button(mode == .add ? "Add" : "Update") {
                        Task {
                            if mode == .add {
                                addItem()
                            } else if mode == .update, let item = itemToUpdate {
                                updateItem(item)
                            }
                        }
                    }
                    .padding()
                    .background((itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

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
            .frame(maxWidth: 350, maxHeight: 600)
            .onAppear {
                if mode == .update {
                    setupItemForUpdate()
                }
            }
        }
    }

    // MARK: - Functions

    /// Toggles the selection of a group
    private func toggleGroupSelection(_ group: ItemGroups) {
        if selectedGroups.contains(group) {
            selectedGroups.remove(group)
        } else {
            selectedGroups.insert(group)
        }
    }

    /// Adds a new group after validating its uniqueness
    private func addNewGroup() {
        do {
            let groupManager = GroupManager(context: context)
            let colorHex = newGroupColor.toHexString() ?? "#000000"
            let newGroup = try groupManager.createGroup(name: newGroupName, color: colorHex)
            selectedGroups.insert(newGroup)
            newGroupName = ""
            newGroupColor = .blue
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Adds a new item with the selected groups
    private func addItem() {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Item name cannot be empty."
            return
        }

        let newItem = CountedItem(countedItemName: trimmedName, countedItemNumber: itemCount)
        newItem.itemGroups = Array(selectedGroups)
        context.insert(newItem)

        do {
            try context.save()
            isShowing = false
        } catch {
            errorMessage = "Failed to save item: \(error.localizedDescription)"
        }
    }

    /// Updates an existing item with the selected groups
    private func updateItem(_ item: CountedItem) {
        let trimmedName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Item name cannot be empty."
            return
        }

        item.countedItemName = trimmedName
        item.countedItemNumber = itemCount
        item.itemGroups = Array(selectedGroups)

        do {
            try context.save()
            isShowing = false
        } catch {
            errorMessage = "Failed to update item: \(error.localizedDescription)"
        }
    }
}
