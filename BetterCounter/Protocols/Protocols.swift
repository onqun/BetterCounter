//
//  Protocols.swift
//  BetterCounter
//
//  Created by Ongun Palaoğlu on 16.11.2024.
//

import SwiftUI
import UIKit

protocol HexColorConvertible {
    init?(hex: String)
    func toHexString(includeAlpha: Bool) -> String?
}
