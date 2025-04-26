import Foundation
import SwiftUI
import Combine

enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    func toColorScheme() -> ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    static func fromColorScheme(_ scheme: ColorScheme?) -> AppearanceMode {
        if scheme == nil {
            return .system
        } else if scheme == .light {
            return .light
        } else {
            return .dark
        }
    }
}

final class SettingsViewModel: ObservableObject {
    // Reference to the global settings manager
    private var settingsManager: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    
    // Appearance mode selection
    @Published var appearanceMode: AppearanceMode = .system {
        didSet {
            if oldValue != appearanceMode {
                updateAppearanceMode(appearanceMode)
            }
        }
    }
    
    // Notification settings
    @Published var notificationsEnabled: Bool = false {
        didSet {
            if oldValue != notificationsEnabled {
                toggleNotifications(notificationsEnabled)
            }
        }
    }
    
    // Location settings
    @Published var locationEnabled: Bool = false {
        didSet {
            if oldValue != locationEnabled {
                toggleLocationServices(locationEnabled)
            }
        }
    }
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        self.updateFromSettings()
        
        // Setup publisher to observe changes in the settings manager
        settingsManager.$settings
            .sink { [weak self] newSettings in
                self?.updateFromSettings()
            }
            .store(in: &cancellables)
    }
    
    // Update the view model from the settings manager
    func updateFromSettings() {
        self.appearanceMode = AppearanceMode.fromColorScheme(settingsManager.settings.preferredColorScheme)
        self.notificationsEnabled = settingsManager.settings.notificationsEnabled
        self.locationEnabled = settingsManager.settings.locationEnabled
    }
    
    // Update the settings manager reference
    func updateSettingsManager(_ manager: SettingsManager) {
        self.settingsManager = manager
        self.updateFromSettings()
        
        // Setup publisher to observe changes in the new settings manager
        settingsManager.$settings
            .sink { [weak self] newSettings in
                self?.updateFromSettings()
            }
            .store(in: &cancellables)
    }
    
    // Update appearance mode
    private func updateAppearanceMode(_ mode: AppearanceMode) {
        var updatedSettings = settingsManager.settings
        updatedSettings.preferredColorScheme = mode.toColorScheme()
        settingsManager.settings = updatedSettings
    }
    
    // Toggle notifications
    private func toggleNotifications(_ enabled: Bool) {
        var updatedSettings = settingsManager.settings
        updatedSettings.notificationsEnabled = enabled
        settingsManager.settings = updatedSettings
    }
    
    // Toggle location services
    private func toggleLocationServices(_ enabled: Bool) {
        var updatedSettings = settingsManager.settings
        updatedSettings.locationEnabled = enabled
        settingsManager.settings = updatedSettings
    }
}