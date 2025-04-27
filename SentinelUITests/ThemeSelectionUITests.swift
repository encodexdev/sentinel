import XCTest

// Helper for testing theme-related properties
extension XCUIApplication {
    enum InterfaceStyle {
        case light
        case dark
        case unknown
    }
    
    // Determine the current interface style using the ThemeInspectorView
    func currentInterfaceStyle() -> InterfaceStyle {
        // Look for our hidden theme inspector elements
        let isDarkMode = otherElements["themeInspector-dark"].exists
        let isLightMode = otherElements["themeInspector-light"].exists
        
        if isDarkMode {
            return .dark
        } else if isLightMode {
            return .light
        } else {
            return .unknown
        }
    }
}

final class ThemeSelectionUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Launch with UI testing flag that can be detected in the app
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testThemeSwitching() throws {
        // First check current theme (likely system or light)
        let initialStyle = app.currentInterfaceStyle()
        
        // Navigate to profile tab (assuming we have a Profile tab)
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")
        
        // Tap the last tab (Profile)
        let profileTab = tabBar.buttons.element(boundBy: tabBar.buttons.count - 1)
        XCTAssertTrue(profileTab.exists, "Profile tab should exist")
        profileTab.tap()
        
        // Tap on settings gear icon
        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2), "Settings button should exist")
        settingsButton.tap()
        
        // Wait for settings screen to appear
        let settingsTitle = app.navigationBars["Settings"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2), "Settings screen should appear")
        
        // Find and tap on the theme picker
        let themePicker = app.otherElements["themePicker"]
        XCTAssertTrue(themePicker.waitForExistence(timeout: 2), "Theme picker should exist")
        themePicker.tap()
        
        // Target the opposite of current mode
        let targetMode: XCUIApplication.InterfaceStyle = (initialStyle == .dark) ? .light : .dark
        let targetOption = (targetMode == .dark) ? "Dark" : "Light"
        
        // Select target mode
        let optionButton = app.staticTexts[targetOption]
        XCTAssertTrue(optionButton.waitForExistence(timeout: 2), "\(targetOption) option should appear")
        optionButton.tap()
        
        // Wait for theme to change
        sleep(1) // Small delay to allow UI to update
        
        // Dismiss settings
        app.buttons["Done"].tap()
        
        // Check if theme changed properly
        let newIsDarkMode = app.otherElements["themeInspector-dark"].exists
        let newIsLightMode = app.otherElements["themeInspector-light"].exists
        
        if targetMode == .dark {
            XCTAssertTrue(newIsDarkMode, "Theme should have changed to dark mode")
            XCTAssertFalse(newIsLightMode, "Light mode should be disabled")
        } else {
            XCTAssertTrue(newIsLightMode, "Theme should have changed to light mode")
            XCTAssertFalse(newIsDarkMode, "Dark mode should be disabled")
        }
        
        // Go back to settings to verify the setting persisted
        profileTab.tap()
        
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2), "Settings button should exist again")
        settingsButton.tap()
        
        // Wait for settings to appear again
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2), "Settings screen should appear again")
        
        // Check theme again
        let finalStyle = app.currentInterfaceStyle()
        XCTAssertEqual(finalStyle, targetMode, "Theme change should have persisted")
    }
}