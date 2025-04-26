import Combine
import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
  @Published var settings: Settings

  // The current color scheme preference
  @Published var colorScheme: ColorScheme?

  // UserDefaults key
  private let settingsKey = "app.sentinel.settings"

  // For storing subscriptions
  private var cancellables = Set<AnyCancellable>()

  init() {
    // Initialize with default settings first
    var initialSettings = TestData.settings

    // Try to load saved settings from storage
    if let savedData = UserDefaults.standard.data(forKey: settingsKey),
      let savedSettings = try? JSONDecoder().decode(Settings.self, from: savedData)
    {
      initialSettings = savedSettings
    }

    self.settings = initialSettings

    self.colorScheme = settings.preferredColorScheme

    $settings
      .sink { [weak self] newSettings in
        self?.colorScheme = newSettings.preferredColorScheme
        self?.saveSettings()
      }
      .store(in: &cancellables)
  }

  func setColorScheme(_ scheme: ColorScheme?) {
    self.colorScheme = scheme  // Directly update colorScheme property first
    
    var updatedSettings = settings
    updatedSettings.preferredColorScheme = scheme
    settings = updatedSettings  // Then update settings to trigger persistence
  }

  // Toggle dark mode on/off (nil = follow system)
  func toggleDarkMode(_ on: Bool) {
    let scheme = on ? ColorScheme.dark : ColorScheme.light
    self.colorScheme = scheme  // Directly update colorScheme
    
    var updatedSettings = settings
    updatedSettings.preferredColorScheme = scheme
    settings = updatedSettings  // Trigger the @Published update
  }

  func toggleFollowSystem(_ follow: Bool) {
    let scheme: ColorScheme? = follow ? nil : .light
    self.colorScheme = scheme  // Directly update colorScheme
    
    var updatedSettings = settings
    updatedSettings.preferredColorScheme = scheme
    settings = updatedSettings  // Trigger the @Published update
  }
  
  // Set notifications enabled/disabled
  func setNotificationsEnabled(_ enabled: Bool) {
    var updatedSettings = settings
    updatedSettings.notificationsEnabled = enabled
    settings = updatedSettings  // Trigger the @Published update
  }
  
  // Set location services enabled/disabled
  func setLocationEnabled(_ enabled: Bool) {
    var updatedSettings = settings
    updatedSettings.locationEnabled = enabled
    settings = updatedSettings  // Trigger the @Published update
  }

  private func saveSettings() {
    guard let data = try? JSONEncoder().encode(settings) else {
      return
    }

    UserDefaults.standard.set(data, forKey: settingsKey)
  }
}
