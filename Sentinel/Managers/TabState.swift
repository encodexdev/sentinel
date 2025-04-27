import SwiftUI

/// Tab indices enum to provide type-safe tab selection
enum TabSelection: Int {
    case home = 0
    case report = 1
    case map = 2
    case incidents = 3
}

/// Observable object to manage tab selection state
class TabState: ObservableObject {
    /// The currently selected tab
    @Published var selectedTab: Int = 0
    
    /// Singleton instance
    static let shared = TabState()
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Switch to a specified tab
    func switchTo(_ tab: TabSelection) {
        selectedTab = tab.rawValue
    }
}