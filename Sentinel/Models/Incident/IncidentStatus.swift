import Foundation

enum IncidentStatus: String, Codable {
  case open = "Open"
  case inProgress = "In Progress"
  case resolved = "Resolved"
}
