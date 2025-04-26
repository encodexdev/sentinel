import SwiftUI
import UIKit
import Combine

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
                    .ignoresSafeArea()
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
}
