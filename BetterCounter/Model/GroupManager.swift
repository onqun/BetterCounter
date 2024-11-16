//
//  GroupManager.swift
//  BetterCounter
//
//  Created by Ongun Palaoğlu on 15.11.2024.
//

import Foundation
import SwiftData
import UIKit // Needed for UIColor conversions
import SwiftUI // Needed for Color conversions

class GroupManager {
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// Creates a new group with a unique name and color.
    /// - Parameters:
    ///   - name: The name of the group.
    ///   - color: An optional hex string representing the group's color.
    /// - Throws: `ValidationError` if the group name or color is invalid or duplicate.
    /// - Returns: The newly created `ItemGroups` instance.
    func createGroup(name: String, color: String? = nil) throws -> ItemGroups {
        // Trim whitespace and ensure the name is not empty
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw ValidationError.emptyGroupName
        }

        // Check for duplicate group name (case-insensitive)
        let fetchDescriptor = FetchDescriptor<ItemGroups>(
            predicate: #Predicate { $0.name.lowercased() == trimmedName.lowercased() }
        )

        let existingGroups = try context.fetch(fetchDescriptor)
        if !existingGroups.isEmpty {
            throw ValidationError.duplicateGroupName
        }

        // Retrieve all existing group colors
        let existingColors = existingGroups.compactMap { $0.color.uppercased() }

        // Assign a unique color if none is provided
        let assignedColor: String
        if let providedColor = color, let _ = UIColor(hex: providedColor), !existingColors.contains(providedColor.uppercased()) {
            assignedColor = providedColor.uppercased()
        } else {
            assignedColor = generateUniqueColor(existingColors: existingColors)
        }

        // Create the new group
        let newGroup = ItemGroups(name: trimmedName, color: assignedColor)
        context.insert(newGroup)
        try context.save()
        return newGroup
    }

    /// Generates a unique hex color string that isn't already used by existing groups.
    /// - Parameter existingColors: An array of hex strings representing colors already in use.
    /// - Returns: A unique hex color string.
    private func generateUniqueColor(existingColors: [String]) -> String {
        // Define a list of predefined colors
        let predefinedColors = [
            "#FF5733", // Orange
            "#33FF57", // Green
            "#3357FF", // Blue
            "#FF33A1", // Pink
            "#A133FF", // Purple
            "#33FFF6", // Cyan
            "#FF8F33", // Amber
            "#8FFF33", // Lime
            "#FF3333", // Red
            "#33FF8F"  // Mint
            // Add more colors as needed
        ]

        // Iterate through predefined colors to find an unused one
        for color in predefinedColors {
            if !existingColors.contains(color.uppercased()) {
                return color
            }
        }

        // If all predefined colors are used, generate a random color
        return randomHexColor()
    }

    /// Generates a random hex color string.
    /// - Returns: A hex color string.
    private func randomHexColor() -> String {
        let r = Int.random(in: 0...255)
        let g = Int.random(in: 0...255)
        let b = Int.random(in: 0...255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    enum ValidationError: LocalizedError {
        case duplicateGroupName
        case emptyGroupName
        case duplicateGroupColor

        var errorDescription: String? {
            switch self {
            case .duplicateGroupName:
                return "A group with this name already exists."
            case .emptyGroupName:
                return "Group name cannot be empty."
            case .duplicateGroupColor:
                return "A group with this color already exists."
            }
        }
    }
}
