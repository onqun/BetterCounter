//
//  SortDirection.swift
//  BetterCounter
//
//  Created by Ongun Palaoğlu on 1.11.2024.
//

import Foundation

// MARK: - SortDirection Enum
enum SortDirection {
    case ascending
    case descending

    var icon: String {
        switch self {
        case .ascending: return "arrow.up"
        case .descending: return "arrow.down"
        }
    }

    mutating func toggle() {
        self = (self == .ascending) ? .descending : .ascending
    }
}

// MARK: - SortOrder Enum
enum SortOrder: String, CaseIterable, Identifiable {
    case name
    case count

    var id: String { self.rawValue }

    var displayName: String {
        switch self {
        case .name: return "Name"
        case .count: return "Count"
        }
    }
}
