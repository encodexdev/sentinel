import Combine
import SwiftUI

final class SettingsViewModel: ObservableObject {
  @Published var appearanceStyle: AppearanceStyle = .system
  @Published var notificationsEnabled: Bool = false
  @Published var locationEnabled: Bool = false

  private var settingsManager: SettingsManager?
  private var cancellables = Set<AnyCancellable>()

  init(settingsManager: SettingsManager?) {
    self.settingsManager = settingsManager
    if let manager = settingsManager {
      bind(to: manager)
    }
  }

  private func bind(to manager: SettingsManager) {
    // Initial sync
    sync(from: manager.settings)

    // Observe future changes
    manager.$settings
      .receive(on: DispatchQueue.main)
      .sink { [weak self] newSettings in
        self?.sync(from: newSettings)
      }
      .store(in: &cancellables)
  }

  private func sync(from settings: Settings) {
    appearanceStyle = AppearanceStyle.fromColorScheme(settings.preferredColorScheme)
    notificationsEnabled = settings.notificationsEnabled
    locationEnabled = settings.locationEnabled
  }

  func updateTheme(to style: AppearanceStyle) {
    settingsManager?.setColorScheme(style.toColorScheme())
  }

  func toggleNotifications(_ enabled: Bool) {
    settingsManager?.setNotificationsEnabled(enabled)
  }

  func toggleLocation(_ enabled: Bool) {
    settingsManager?.setLocationEnabled(enabled)
  }

  // If the manager instance changes (e.g. when injecting environment object)
  func updateSettingsManager(_ manager: SettingsManager) {
    cancellables.forEach { $0.cancel() }
    cancellables.removeAll()
    settingsManager = manager
    bind(to: manager)
  }
}
