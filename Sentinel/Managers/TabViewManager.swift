import SwiftUI
import UIKit

enum TabIndex: Int {
    case home = 0
    case report = 1
    case map = 2
    case incidents = 3
}

class TabViewManager {
    static let shared = TabViewManager()
    
    private init() {}
    
    func switchToTab(_ tab: TabIndex) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
           let tabBar = keyWindow.rootViewController as? UITabBarController {
            tabBar.selectedIndex = tab.rawValue
        }
    }
}