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
    settings.preferredColorScheme = scheme
  }

  // Toggle dark mode on/off (nil = follow system)
  func toggleDarkMode(_ on: Bool) {
    settings.preferredColorScheme = on ? .dark : .light
  }

  func toggleFollowSystem(_ follow: Bool) {
    settings.preferredColorScheme = follow ? nil : .light
  }

  private func saveSettings() {
    guard let data = try? JSONEncoder().encode(settings) else {
      return
    }

    UserDefaults.standard.set(data, forKey: settingsKey)
  }
}
