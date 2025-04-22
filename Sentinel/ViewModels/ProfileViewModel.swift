import Foundation
import SwiftUI

final class ProfileViewModel: ObservableObject {
  // Bindable properties
  @Published var user = TestData.user
  @Published var settings = TestData.settings

  // Toggle functions (for now, just update in‑memory)
  func toggleDarkMode(_ on: Bool) {
    settings.preferredColorScheme = on ? .dark : .light
  }
}
