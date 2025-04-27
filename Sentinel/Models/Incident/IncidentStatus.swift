import Foundation

enum IncidentStatus: String, Codable {
  case open = "Open"
  case inProgress = "Pending"
  case resolved = "Resolved"
}
