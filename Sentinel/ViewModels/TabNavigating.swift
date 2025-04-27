import SwiftUI

/// Protocol for ViewModels that need tab navigation functionality
protocol TabNavigating {
    func openTab(_ tab: TabSelection)
}

/// Default implementation of TabNavigating for ViewModels
extension TabNavigating {
    /// Switch to Home tab
    func openHomeTab() {
        openTab(.home)
    }
    
    /// Switch to Report tab
    func openReportTab() {
        openTab(.report)
    }
    
    /// Switch to Map tab
    func openMapTab() {
        openTab(.map)
    }
    
    /// Switch to Incidents tab
    func openIncidentsTab() {
        openTab(.incidents)
    }
    
    /// Base implementation using TabState
    func openTab(_ tab: TabSelection) {
        TabState.shared.switchTo(tab)
    }
}