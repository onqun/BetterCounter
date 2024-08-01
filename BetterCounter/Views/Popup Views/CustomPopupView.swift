import SwiftUI
import SwiftData

@MainActor
struct CustomPopupView: View {
    @Environment(\.modelContext) private var context
    @Binding var showingPopup: Bool
    @Binding var newGroupName: String

    @Query private var availableGroups: [ItemGroups]
    var item: CountedItem
    @State private var selectedGroups = Set<ItemGroups>()

    var body: some View {
        VStack(spacing: 10) {
            ForEach(availableGroups) { group in
                HStack {
                    Text(group.name)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(group.hexColor.opacity(0.2))
                        )
                    Spacer()
                    if item.itemGroups?.contains(group) == true {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .onTapGesture {
                                Task { @MainActor in
                                    // Ensure that operations involving `context` run on the main actor
                                    do {
                                        try await toggleGroupMembership(item, group: group, context: context)
                                    } catch {
                                        print("Error toggling group membership: \(error)")
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                            .onTapGesture {
                                Task { @MainActor in
                                    // Ensure that operations involving `context` run on the main actor
                                    do {
                                        try await toggleGroupMembership(item, group: group, context: context)
                                    } catch {
                                        print("Error toggling group membership: \(error)")
                                    }
                                }
                            }
                            .contentShape(Rectangle())
                    }
                }
                .padding(.bottom, 2)
            }
            Divider()
            HStack {
                TextField("Add Group", text: $newGroupName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        Task { @MainActor in
                            // Ensure that operations involving `context` run on the main actor
                            do {
                                try  addGroup(
                                    newGroupName: newGroupName,
                                    availableGroups: availableGroups,
                                    selectedGroups: &selectedGroups,
                                    context: context
                                )
                                newGroupName = "" // Reset the group name after adding
                            } catch {
                                print("Error adding new group: \(error)")
                            }
                        }
                    }
                    .contentShape(Rectangle())
            }
            .padding()
            Button("Close") {
                showingPopup = false
            }
            .padding()
            .background(Color.red.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
            .contentShape(Rectangle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 8)
        .frame(width: 250)
    }
}
