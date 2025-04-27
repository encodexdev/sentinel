import Combine
import Foundation
import SwiftUI

final class SettingsManager: ObservableObject {
  // The main settings property - this is the source of truth
  @Published private(set) var settings: Settings
  // We also publish each specific setting to make binding easier
  @Published private(set) var appearanceStyle: AppearanceStyle = .system
  @Published private(set) var notificationsEnabled: Bool = true
  @Published private(set) var locationEnabled: Bool = true

  private let settingsKey: String
  private var cancellables = Set<AnyCancellable>()

  init(storageKey: String = "app.sentinel.settings") {
    self.settingsKey = storageKey

    // Load saved settings or fallback to defaults
    if let data = UserDefaults.standard.data(forKey: settingsKey),
      let saved = try? JSONDecoder().decode(Settings.self, from: data)
    {
      settings = saved
    } else {
      settings = Settings(
        preferredColorScheme: nil,
        notificationsEnabled: true,
        locationEnabled: true)
    }

    // Initialize the published properties
    updateDerivedProperties()

    // Persist any settings changes
    $settings
      .sink { [weak self] newSettings in
        guard let self = self, let data = try? JSONEncoder().encode(newSettings) else { return }
        UserDefaults.standard.set(data, forKey: self.settingsKey)
        self.updateDerivedProperties()
      }
      .store(in: &cancellables)
  }

  private func updateDerivedProperties() {
    appearanceStyle = AppearanceStyle.fromColorScheme(settings.preferredColorScheme)
    notificationsEnabled = settings.notificationsEnabled
    locationEnabled = settings.locationEnabled
  }

  var colorScheme: ColorScheme? {
    settings.preferredColorScheme
  }

  // Direct setter for appearanceStyle
  func setAppearanceStyle(_ style: AppearanceStyle) {
    var updated = settings
    updated.preferredColorScheme = style.toColorScheme()
    settings = updated
  }

  // Legacy method - kept for backward compatibility
  func setColorScheme(_ scheme: ColorScheme?) {
    var updated = settings
    updated.preferredColorScheme = scheme
    settings = updated
  }

  func setNotificationsEnabled(_ enabled: Bool) {
    var updated = settings
    updated.notificationsEnabled = enabled
    settings = updated
  }

  func setLocationEnabled(_ enabled: Bool) {
    var updated = settings
    updated.locationEnabled = enabled
    settings = updated
  }
}
