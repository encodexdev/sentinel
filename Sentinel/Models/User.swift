import Foundation

struct User: Codable {
    let id: String
    let fullName: String
    let role: String
    let avatarURL: URL?
    let isOnDuty: Bool
}
