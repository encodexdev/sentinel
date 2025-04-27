# Sentinel Tests

This directory contains tests for the Sentinel app using XCTest framework.

## Test Structure

The tests are organized by feature area:

- **Appearance/** - Tests for theme switching functionality
- **Chat/** - Tests for chat functionality
- **ViewModels/** - Tests for view model logic

## Running Tests

### In Xcode

1. Open the Sentinel project in Xcode
2. Select the SentinelTests scheme
3. Choose a simulator (iPhone 16 Pro recommended)
4. Press `Cmd+U` to run all tests
5. Alternatively, click the diamond-shaped "play" button next to individual test methods

### Using Command Line

Run tests from the command line using:

```bash
cd /path/to/sentinel
xcodebuild test -scheme SentinelTests -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

For a quieter output, use xcbeautify or xcpretty:

```bash
xcodebuild test -scheme SentinelTests -destination 'platform=iOS Simulator,name=iPhone 16 Pro' | xcbeautify
```

## Adding New Tests

To add new tests:

1. Create a new .swift file in the appropriate subdirectory
2. Import XCTest and the Sentinel app:
   ```swift
   import XCTest
   @testable import Sentinel
   ```
3. Create a test class that subclasses XCTestCase:
   ```swift
   final class FeatureTests: XCTestCase {
       // Test methods go here
   }
   ```
4. Add test methods that start with "test":
   ```swift
   func testSomeFunctionality() {
       // Test code
   }
   ```

## Theme Testing

The theme switching tests verify that:
1. The app correctly applies theme changes
2. Theme settings are persisted
3. The SettingsView correctly uses the app's SettingsManager

If the theme switching test fails, check:
1. The SettingsManager is being properly injected through SwiftUI's environment
2. The ViewModel correctly updates the theme
3. The view refreshes after theme changes (using `.id()`)