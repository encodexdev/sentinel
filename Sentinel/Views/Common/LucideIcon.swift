import SwiftUI
import LucideIcons
import UIKit

/// A wrapper for Lucide icons to make them easier to use and style in SwiftUI
struct LucideIcon: View {
    /// The Lucide icon UIImage to display
    let icon: UIImage
    
    /// Size of the icon (width and height will be the same)
    var size: CGFloat = 24
    
    /// Color of the icon
    var color: Color = .primary
    
    /// Optional opacity for the icon
    var opacity: CGFloat = 1.0
    
    /// Optional rotation angle in degrees
    var rotation: Double = 0
    
    var body: some View {
        Image(uiImage: icon
            .withRenderingMode(.alwaysTemplate)
            .resized(to: CGSize(width: size, height: size))
        )
        .renderingMode(.template)
        .foregroundColor(color)
        .opacity(opacity)
        .rotationEffect(Angle(degrees: rotation))
    }
}

/// Convenience initializers for common Lucide icons
extension LucideIcon {
    /// Create a shield user icon
    static func shieldUser(
        size: CGFloat = 24,
        color: Color = .primary,
        opacity: CGFloat = 1.0,
        rotation: Double = 0
    ) -> LucideIcon {
        LucideIcon(
            icon: Lucide.shieldUser,
            size: size,
            color: color,
            opacity: opacity,
            rotation: rotation
        )
    }
    
    /// Create a map pin icon
    static func mapPin(
        size: CGFloat = 24,
        color: Color = .primary,
        opacity: CGFloat = 1.0,
        rotation: Double = 0
    ) -> LucideIcon {
        LucideIcon(
            icon: Lucide.mapPin,
            size: size,
            color: color,
            opacity: opacity,
            rotation: rotation
        )
    }
    
    /// Create a warning icon
    static func warning(
        size: CGFloat = 24,
        color: Color = .primary,
        opacity: CGFloat = 1.0,
        rotation: Double = 0
    ) -> LucideIcon {
        LucideIcon(
            icon: Lucide.messageSquareWarning,
            size: size,
            color: color,
            opacity: opacity,
            rotation: rotation
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        LucideIcon.shieldUser(size: 32, color: .blue)
        LucideIcon.mapPin(size: 32, color: .red)
        LucideIcon.warning(size: 32, color: .orange)
        
        LucideIcon(icon: Lucide.house, size: 32, color: .green)
    }
    .padding()
}
