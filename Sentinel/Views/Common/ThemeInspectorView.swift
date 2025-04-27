import SwiftUI

/// A view that helps UI tests determine the current theme
struct ThemeInspectorView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        // This view will be hidden in normal app usage
        // It's only for UI testing to detect the current theme
        Text(colorScheme == .dark ? "dark-mode" : "light-mode")
            .opacity(0)
            .frame(width: 1, height: 1)
            .accessibility(identifier: "themeInspector-\(colorScheme == .dark ? "dark" : "light")")
    }
}

extension View {
    /// Adds a theme inspector to the view for UI testing
    func withThemeInspector() -> some View {
        self.overlay(
            // Only show for UI tests
            Group {
                if ProcessInfo.processInfo.arguments.contains("UI-TESTING") {
                    ThemeInspectorView()
                }
            }
        )
    }
}