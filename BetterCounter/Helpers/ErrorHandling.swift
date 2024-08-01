//
//  ErrorHandling.swift
//  BetterCounter
//
//  Created by Ongun Palaoğlu on 31.10.2024.
//

import Foundation

/// A global enum to represent different types of errors that can occur in the app, with error codes.
enum AppError: Int, Error {
    case emptyGroupName = 1001
    case contextSaveError = 1002
    case groupAlreadyExists = 1003
    case invalidData = 1004
    case unknownError = 9999

    /// A user-friendly description for each error.
    var localizedDescription: String {
        switch self {
        case .emptyGroupName:
            return "Group name cannot be empty."
        case .contextSaveError:
            return "Failed to save data."
        case .groupAlreadyExists:
            return "The group already exists."
        case .invalidData:
            return "Invalid data provided."
        case .unknownError:
            return "An unknown error has occurred."
        }
    }
}
