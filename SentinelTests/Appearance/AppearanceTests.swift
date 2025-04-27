import XCTest
@testable import Sentinel

final class AppearanceTests: XCTestCase {
    
    func testAppearanceStyleConversion() {
        // Test conversion from AppearanceStyle to ColorScheme
        XCTAssertEqual(AppearanceStyle.light.toColorScheme(), .light)
        XCTAssertEqual(AppearanceStyle.dark.toColorScheme(), .dark)
        XCTAssertNil(AppearanceStyle.system.toColorScheme())
        
        // Test conversion from ColorScheme to AppearanceStyle
        XCTAssertEqual(AppearanceStyle.fromColorScheme(.light), .light)
        XCTAssertEqual(AppearanceStyle.fromColorScheme(.dark), .dark)
        XCTAssertEqual(AppearanceStyle.fromColorScheme(nil), .system)
    }
    
    func testSettingsManagerPersistence() throws {
        // Create a unique key for test
        let testKey = "test.settings.\(UUID().uuidString)"
        
        // Create a settings manager with our test key
        let manager = SettingsManager(storageKey: testKey)
        
        // Set a specific theme
        manager.setColorScheme(.dark)
        
        // Allow time for the change to be saved
        let expectation = XCTestExpectation(description: "Settings saved")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.2)
        
        // Create a new manager with the same key
        let newManager = SettingsManager(storageKey: testKey)
        
        // Verify the theme persisted
        XCTAssertEqual(newManager.colorScheme, .dark)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: testKey)
    }
}