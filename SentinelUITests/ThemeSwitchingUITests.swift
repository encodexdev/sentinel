import XCTest

final class ThemeSwitchingUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Launch with UI testing flag
        app.launchArguments = ["UI-TESTING"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testThemeSwitching() throws {
        // Navigate to profile tab (last tab)
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
        
        // Find appearance section
        let appearanceSection = app.staticTexts["Appearance"]
        XCTAssertTrue(appearanceSection.waitForExistence(timeout: 2), "Appearance section should exist")
        
        // Find and tap on the theme picker
        let themePicker = app.cells.containing(.staticText, identifier: "Theme").firstMatch
        XCTAssertTrue(themePicker.exists, "Theme picker should exist")
        themePicker.tap()
        
        // Select Dark mode
        let darkOption = app.cells.staticTexts["Dark"].firstMatch
        if darkOption.waitForExistence(timeout: 2) {
            darkOption.tap()
        } else {
            // If Dark mode isn't visible, select Light mode instead
            let lightOption = app.cells.staticTexts["Light"].firstMatch
            XCTAssertTrue(lightOption.waitForExistence(timeout: 2), "Light option should appear")
            lightOption.tap()
        }
        
        // Wait for theme to change
        sleep(1) // Small delay to allow UI to update
        
        // Dismiss settings
        app.buttons["Done"].tap()
        
        // Verify by going back to settings
        settingsButton.tap()
        
        // Wait for settings to appear again
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 2), "Settings screen should appear again")
        
        // This is a basic verification that the app didn't crash after theme change
        // In a more comprehensive test, we would check specific UI elements to verify 
        // they actually changed appearance
    }
}