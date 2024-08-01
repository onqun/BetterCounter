import SwiftUI

struct OverlapChecker {
    static func createEnclosingRectangle(rect1Position: CGSize, rect2Position: CGSize, rectSize: CGSize) -> CGRect? {
        let rect1Frame = CGRect(origin: CGPoint(x: rect1Position.width, y: rect1Position.height), size: rectSize)
        let rect2Frame = CGRect(origin: CGPoint(x: rect2Position.width, y: rect2Position.height), size: rectSize)
        
        // Check if they intersect
        if rect1Frame.intersects(rect2Frame) {
            // Create a rectangle that can contain both rect1Frame and rect2Frame
            let enclosingRect = rect1Frame.union(rect2Frame)
            print("okay")
            return enclosingRect
        }
        
        return nil  // Return nil if no overlap
    }
}
