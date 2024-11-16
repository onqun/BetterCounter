// Color+Extension.swift

import SwiftUI

extension Color {
    init?(hex: String) {
        // Trim whitespaces, newlines, and convert to uppercase
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Remove '#' prefix if present
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }
        
        // The hex string should now be either 6 or 8 characters
        guard hexSanitized.count == 6 || hexSanitized.count == 8 else {
            return nil
        }
        
        // If 6 characters, append "FF" for full opacity
        if hexSanitized.count == 6 {
            hexSanitized += "FF"
        }
        
        // Now hexSanitized has 8 characters (ARGB)
        let scanner = Scanner(string: hexSanitized)
        var hexNumber: UInt64 = 0
        
        // Attempt to scan the hex number
        guard scanner.scanHexInt64(&hexNumber) else {
            return nil
        }
        
        // Extract RGBA components
        let r = Double((hexNumber & 0xFF000000) >> 24) / 255
        let g = Double((hexNumber & 0x00FF0000) >> 16) / 255
        let b = Double((hexNumber & 0x0000FF00) >> 8) / 255
        let a = Double(hexNumber & 0x000000FF) / 255
        
        // Initialize Color with RGBA components
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
