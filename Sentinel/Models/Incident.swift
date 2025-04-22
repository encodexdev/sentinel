import Foundation

struct Incident: Identifiable, Codable {
    enum Status: String, Codable {
        case open = "Open"
        case inProgress = "In Progress"
        case resolved = "Resolved"
    }

    let id: String
    let title: String
    let description: String?
    let location: String
    let time: Date
    let status: Status
}
