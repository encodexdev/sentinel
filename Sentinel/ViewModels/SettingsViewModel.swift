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
    @Published var settingsManager: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    
    // Appearance mode
    @Published var appearanceMode: AppearanceMode = .system
    
    // Notification settings
    @Published var notificationsEnabled: Bool = false
    
    // Location settings
    @Published var locationEnabled: Bool = false
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        self.updateFromSettings()
        
        // Setup publisher to observe changes in the settings manager
        settingsManager.$settings
            .sink { [weak self] newSettings in
                self?.updateFromSettings()
            }
            .store(in: &cancellables)
        
        // Setup publishers to update settings when view model properties change
        // React to changes in the UI bindings by calling the appropriate methods
        $appearanceMode
            .dropFirst() // Skip the initial value to avoid triggering on initialization
            .sink { [weak self] newMode in
                guard let self = self else { return }
                self.updateAppearanceMode(newMode)
            }
            .store(in: &cancellables)
            
        $notificationsEnabled
            .dropFirst() // Skip the initial value
            .sink { [weak self] enabled in
                guard let self = self else { return }
                self.toggleNotifications(enabled)
            }
            .store(in: &cancellables)
            
        $locationEnabled
            .dropFirst() // Skip the initial value
            .sink { [weak self] enabled in
                guard let self = self else { return }
                self.toggleLocationServices(enabled)
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
    }
    
    // Update appearance mode
    private func updateAppearanceMode(_ mode: AppearanceMode) {
        settingsManager.setColorScheme(mode.toColorScheme())
    }
    
    // Toggle notifications
    private func toggleNotifications(_ enabled: Bool) {
        settingsManager.setNotificationsEnabled(enabled)
    }
    
    // Toggle location services
    private func toggleLocationServices(_ enabled: Bool) {
        settingsManager.setLocationEnabled(enabled)
    }
}

