import Combine
import SwiftUI
import UIKit

@main
struct SentinelApp: App {
  // Create a global settings manager
  @StateObject private var settingsManager = SettingsManager()
  // Flag to determine if we're running UI tests
  private let isRunningUITests: Bool
  
  init() {
    // Check if we're running UI tests
    self.isRunningUITests = ProcessInfo.processInfo.arguments.contains("UI-TESTING")
    configureTabBarAppearance()
  }

  var body: some Scene {
    WindowGroup {
      ZStack {
        MainTabView()
      }
      .environmentObject(settingsManager)
      .preferredColorScheme(settingsManager.colorScheme)
      .withThemeInspector()
    }
  }

  private func configureTabBarAppearance() {
    let tabBarAppearance = UITabBarAppearance()
    tabBarAppearance.configureWithOpaqueBackground()
     tabBarAppearance.backgroundColor = UIColor(named: "CardBackground")

    UITabBar.appearance().standardAppearance = tabBarAppearance
    if #available(iOS 15.0, *) {
      UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
  }
}
