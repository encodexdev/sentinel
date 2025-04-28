import Combine
import SwiftUI
import UIKit
import Foundation
import ObjectiveC
import Security

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
    }
    
    // Check for API key in Info.plist
    if let plistKey = AppConfig.value(for: .openAIApiKey) {
      print("API key found in Info.plist")
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
