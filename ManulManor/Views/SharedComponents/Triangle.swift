import SwiftUI

// Triangle shape - kept for backward compatibility
// DEPRECATED: No longer needed for Manul's ears since we now use SVGs
// This shape may still be used elsewhere in the app
@available(*, deprecated, message: "Use SVG images instead for complex shapes")
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
} 