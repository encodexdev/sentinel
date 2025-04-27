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

final class ThemeSwitchingTests: XCTestCase {
    
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
    
    @MainActor
    func testThemeSwitching() throws {
        // First check current theme (likely system or light)
        let initialStyle = app.currentInterfaceStyle()
        
        // Navigate to profile tab (assuming we have a Profile tab)
        let profileTab = app.tabBars.buttons.element(boundBy: 3) // Usually the last tab
        XCTAssertTrue(profileTab.waitForExistence(timeout: 2), "Profile tab should exist")
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
        let optionButton = app.buttons[targetOption]
        XCTAssertTrue(optionButton.waitForExistence(timeout: 2), "\(targetOption) option should appear")
        optionButton.tap()
        
        // Wait for theme to change
        sleep(1) // Small delay to allow UI to update
        
        // Dismiss settings
        app.buttons["Done"].tap()
        
        // Check if theme changed properly
        let newStyle = app.currentInterfaceStyle()
        XCTAssertEqual(newStyle, targetMode, "Theme should have changed to \(targetMode)")
        
        // Go back to settings to verify the setting persisted
        profileTab.tap()
        settingsButton.tap()
        
        // Wait for settings to appear
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2), "Settings screen should appear again")
        
        // Check theme again
        let finalStyle = app.currentInterfaceStyle()
        XCTAssertEqual(finalStyle, targetMode, "Theme change should have persisted")
    }
}