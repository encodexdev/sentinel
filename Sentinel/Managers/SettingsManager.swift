import Combine
import Foundation
import SwiftUI

final class SettingsManager: ObservableObject {
  @Published private(set) var settings: Settings

  private let settingsKey = "app.sentinel.settings"
  private var cancellables = Set<AnyCancellable>()

  init() {
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

    // Persist any settings changes
    $settings
      .sink { newSettings in
        guard let data = try? JSONEncoder().encode(newSettings) else { return }
        UserDefaults.standard.set(data, forKey: self.settingsKey)
      }
      .store(in: &cancellables)
  }

  var colorScheme: ColorScheme? {
    settings.preferredColorScheme
  }

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
