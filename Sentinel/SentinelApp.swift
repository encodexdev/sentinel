import Combine
import Foundation
import ObjectiveC
import Security
import SwiftUI
import UIKit

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
    // Check for API key in keychain
    if let keyInKeychain = KeychainManager.retrieve(key: AppConfig.Keys.openAIApiKey.rawValue) {
      print("API key found in keychain")
      // Print the first few characters of the key (safer than printing the whole key)
      print("Key value (masked): \(String(keyInKeychain.prefix(10)))...")
    }

    // Check for API key in Info.plist
    if let plistKey = AppConfig.value(for: .openAIApiKey) {
      print("API key found in Info.plist")
      print("Info.plist key value (masked): \(String(plistKey.prefix(10)))...")
    }
    // Initialize OpenAIService to validate configuration
    do {
      let service = try OpenAIService()
      print("OpenAIService initialized successfully")
    } catch let error {
      print("OpenAIService initialization failed: \(error)")
    }

  }
}
