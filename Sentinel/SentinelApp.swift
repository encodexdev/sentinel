import Combine
import SwiftUI
import UIKit
import Foundation
import ObjectiveC

@main
struct SentinelApp: App {
  // Create a global settings manager
  @StateObject private var settingsManager = SettingsManager()

  init() {
    configureTabBarAppearance()
    debugApiKeyConfiguration()
  }

  var body: some Scene {
    WindowGroup {
      ZStack {
        MainTabView()
      }
      .environmentObject(settingsManager)
      .preferredColorScheme(settingsManager.colorScheme)
      .id(settingsManager.colorScheme)
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
  
  private func debugApiKeyConfiguration() {
    // Import the environment provider module to access the provider
    _ = EnvironmentProvider.shared
    
    // Try to initialize OpenAIService with available API key
    do {
      let service = try OpenAIService()
      print("OpenAIService initialized successfully")
    } catch let error {
      print("OpenAIService initialization failed: \(error)")
    }
  }
}
