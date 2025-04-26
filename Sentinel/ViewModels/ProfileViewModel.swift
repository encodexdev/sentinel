import Foundation
import SwiftUI

final class ProfileViewModel: ObservableObject {
    // Bindable properties
    @Published var user = TestData.user
}
