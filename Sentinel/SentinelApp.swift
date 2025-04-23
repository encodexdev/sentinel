import SwiftUI
import UIKit

@main
struct SentinelApp: App {
    // Create a global settings manager
    @StateObject private var settingsManager = SettingsManager()
    
    init() {
        configureTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color("CardBackground")
                    .ignoresSafeArea() // fill behind everything
                
                MainTabView()
                    // Apply color scheme from settings
                    .preferredColorScheme(settingsManager.colorScheme)
                    // Make settings manager available to all views
                    .environmentObject(settingsManager)
            }
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