import UIKit

extension UIColor {
    
    /// Initializes a UIColor from a hex string.
    /// - Parameter hex: The hex string, which can optionally start with a "#".
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        // Handle shorthand hex codes (e.g., "FFF" -> "FFFFFF")
        if hexSanitized.count == 3 {
            hexSanitized = hexSanitized.map { "\($0)\($0)" }.joined()
        } else if hexSanitized.count == 4 {
            hexSanitized = hexSanitized.map { "\($0)\($0)" }.joined()
        }
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        
        if length == 6 {
            let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
            let b = CGFloat(rgb & 0x0000FF) / 255
            
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        } else if length == 8 {
            let r = CGFloat((rgb & 0xFF000000) >> 24) / 255
            let g = CGFloat((rgb & 0x00FF0000) >> 16) / 255
            let b = CGFloat((rgb & 0x0000FF00) >> 8) / 255
            let a = CGFloat(rgb & 0x000000FF) / 255
            
            self.init(red: r, green: g, blue: b, alpha: a)
        } else {
            return nil
        }
    }
    
    /// Converts a UIColor to a hex string.
    /// - Parameter includeAlpha: Whether to include the alpha component.
    /// - Returns: The hex string representation of the color.
    func toHexString(includeAlpha: Bool = false) -> String? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        
        if includeAlpha {
            return String(format: "#%02X%02X%02X%02X",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255),
                          Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X",
                          Int(r * 255),
                          Int(g * 255),
                          Int(b * 255))
        }
    }
    
    /// Retrieves a UIColor from a predefined name.
    /// - Parameter name: The name of the color.
    /// - Returns: The corresponding UIColor, or nil if not found.
    static func from(name: String) -> UIColor? {
        let namedColors: [String: String] = [
            "red": "#FF0000",
            "green": "#00FF00",
            "blue": "#0000FF",
            "black": "#000000",
            "white": "#FFFFFF",
            // Add more named colors as needed
        ]
        
        if let hex = namedColors[name.lowercased()] {
            return UIColor(hex: hex)
        }
        
        return nil
    }
}
