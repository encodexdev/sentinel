import XCTest
@testable import Sentinel

final class SettingsViewModelTests: XCTestCase {
    
    func testSettingsViewModelSync() {
        // Create a settings manager with default values
        let settingsManager = SettingsManager()
        
        // Set specific values
        settingsManager.setColorScheme(.dark)
        settingsManager.setNotificationsEnabled(true)
        settingsManager.setLocationEnabled(false)
        
        // Create a view model with this manager
        let viewModel = SettingsViewModel(settingsManager: settingsManager)
        
        // Verify initial sync
        XCTAssertEqual(viewModel.appearanceStyle, .dark)
        XCTAssertTrue(viewModel.notificationsEnabled)
        XCTAssertFalse(viewModel.locationEnabled)
        
        // Change settings in manager
        settingsManager.setColorScheme(.light)
        settingsManager.setNotificationsEnabled(false)
        settingsManager.setLocationEnabled(true)
        
        // Verify view model updated
        XCTAssertEqual(viewModel.appearanceStyle, .light)
        XCTAssertFalse(viewModel.notificationsEnabled)
        XCTAssertTrue(viewModel.locationEnabled)
    }
    
    func testSettingsViewModelUpdatesManager() {
        // Create a settings manager with default values
        let settingsManager = SettingsManager()
        
        // Create a view model with this manager
        let viewModel = SettingsViewModel(settingsManager: settingsManager)
        
        // Initial state
        XCTAssertNil(settingsManager.colorScheme) // System theme
        
        // Update theme via view model
        viewModel.updateTheme(to: .dark)
        
        // Verify manager updated
        XCTAssertEqual(settingsManager.colorScheme, .dark)
        
        // Update notifications via view model
        viewModel.toggleNotifications(false)
        
        // Verify manager updated
        XCTAssertFalse(settingsManager.settings.notificationsEnabled)
        
        // Update location via view model
        viewModel.toggleLocation(false)
        
        // Verify manager updated
        XCTAssertFalse(settingsManager.settings.locationEnabled)
    }
    
    func testSettingsViewModelWithNilManager() {
        // Create a view model with nil manager
        let viewModel = SettingsViewModel(settingsManager: nil)
        
        // Default values
        XCTAssertEqual(viewModel.appearanceStyle, .system)
        XCTAssertFalse(viewModel.notificationsEnabled)
        XCTAssertFalse(viewModel.locationEnabled)
        
        // These should not crash
        viewModel.updateTheme(to: .dark)
        viewModel.toggleNotifications(true)
        viewModel.toggleLocation(true)
        
        // Create a real manager
        let settingsManager = SettingsManager()
        
        // Update the view model with a real manager
        viewModel.updateSettingsManager(settingsManager)
        
        // Now settings should affect the manager
        viewModel.updateTheme(to: .light)
        XCTAssertEqual(settingsManager.colorScheme, .light)
    }
}