import Foundation
import SwiftUI

struct User: Codable {
    let id: String
    let fullName: String
    let role: String
    let avatarURL: URL?
    let avatarImageName: String? // For local images
    let email: String
    let phoneNumber: String
    let startDate: String
    let isOnDuty: Bool
    
    // Helper method to get avatar image
    func getAvatarImage() -> Image? {
        if let imageName = avatarImageName {
            return Image(imageName)
        }
        return nil
    }
}
