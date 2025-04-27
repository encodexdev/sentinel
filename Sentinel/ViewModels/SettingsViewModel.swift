import Combine
import SwiftUI

final class SettingsViewModel: ObservableObject {
  // Reference to the settings manager - no need to duplicate state
  private(set) var settingsManager: SettingsManager
  
  // Forward the settings manager's published properties
  var appearanceStyle: Binding<AppearanceStyle> {
    Binding(
      get: { self.settingsManager.appearanceStyle },
      set: { self.settingsManager.setAppearanceStyle($0) }
    )
  }
  
  var notificationsEnabled: Binding<Bool> {
    Binding(
      get: { self.settingsManager.notificationsEnabled },
      set: { self.settingsManager.setNotificationsEnabled($0) }
    )
  }
  
  var locationEnabled: Binding<Bool> {
    Binding(
      get: { self.settingsManager.locationEnabled },
      set: { self.settingsManager.setLocationEnabled($0) }
    )
  }

  // Initialize with the settings manager
  init(settingsManager: SettingsManager) {
    self.settingsManager = settingsManager
  }
}
