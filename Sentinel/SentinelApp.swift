import SwiftUI

@main
struct SentinelApp: App {
    // Create a global settings manager
    @StateObject private var settingsManager = SettingsManager()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                // Apply color scheme from settings
                .preferredColorScheme(settingsManager.colorScheme)
                // Make settings manager available to all views
                .environmentObject(settingsManager)
        }
    }
}