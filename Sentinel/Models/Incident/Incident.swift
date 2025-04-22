import Foundation

struct Incident: Identifiable, Codable {
  let id: String
  let title: String
  let description: String?
  let location: String
  let time: Date
  let status: IncidentStatus
}
