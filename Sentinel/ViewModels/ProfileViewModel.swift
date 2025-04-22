import Foundation
import SwiftUI

final class ProfileViewModel: ObservableObject {
    // Bindable properties
    @Published var user = TestData.user
    
    // Use a reference to the global settings manager
    private var settingsManager: SettingsManager
    
    // Computed property to read settings from the manager
    var settings: Settings {
        settingsManager.settings
    }
    
    // Appearance style property
    @Published var appearanceStyle: AppearanceStyle = .system
    
    // Flag to track if we should follow system appearance
    @Published var followSystem: Bool = false
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        self.followSystem = settings.preferredColorScheme == nil
        self.appearanceStyle = AppearanceStyle.fromColorScheme(settings.preferredColorScheme)
    }
    
    // Method to update the settings manager reference
    func updateSettingsManager(_ manager: SettingsManager) {
        self.settingsManager = manager
        self.objectWillChange.send()
        self.followSystem = settings.preferredColorScheme == nil
        self.appearanceStyle = AppearanceStyle.fromColorScheme(settings.preferredColorScheme)
    }
    
    // Toggle functions
    func toggleDarkMode(_ on: Bool) {
        settingsManager.toggleDarkMode(on)
        followSystem = false
    }
    
    func toggleFollowSystem(_ on: Bool) {
        followSystem = on
        settingsManager.toggleFollowSystem(on)
    }
    
    // Update appearance style
    func updateAppearanceStyle(_ style: AppearanceStyle) {
        appearanceStyle = style
        settingsManager.setColorScheme(style.toColorScheme())
        followSystem = style == .system
    }
}