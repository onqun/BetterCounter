
//
//  SortOrder.swift
//  BetterCounter
//
//  Created by Ongun Palaoğlu on 1.11.2024.
//

import Foundation

// MARK: - SortOrder Enum
/// Defines the possible sorting criteria: by name or by count.
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
