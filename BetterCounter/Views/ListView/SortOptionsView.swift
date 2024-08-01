//
//  SortOptionsView.swift
//  BetterCounter
//
//  Created by Ongun Palaoğlu on 9.08.2024.
//
import SwiftUI

// MARK: - SortOptionsView
/// A simple view to display sorting options in a menu format.
struct SortOptionsView: View {
    @Binding var sortOrder: SortOrder
    @Binding var sortDirection: SortDirection

    var body: some View {
        Menu {
            ForEach(SortOrder.allCases, id: \.self) { order in
                Button(action: {
                    updateSortOrder(to: order)
                }) {
                    HStack {
                        Text(order.displayName)
                        Spacer()
                        Image(systemName: icon(for: order))
                    }
                }
            }
        } label: {
            Label("Sort Options", systemImage: "arrow.up.arrow.down.circle")
                .padding()
        }
    }

    private func updateSortOrder(to order: SortOrder) {
        if sortOrder == order {
            sortDirection.toggle()
        } else {
            sortOrder = order
            sortDirection = .ascending
        }
    }

    private func icon(for order: SortOrder) -> String {
        sortOrder == order ? sortDirection.icon : SortDirection.ascending.icon
    }
}
