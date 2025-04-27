import Foundation
import UIKit

/// Model representing the data for an incident report message
struct ReportData: Identifiable {
  /// Unique identifier for the report
  let id: String

  /// Brief incident title
  let title: String

  /// Detailed description of the incident
  let description: String

  /// Where the incident occurred
  let location: String

  /// When the incident occurred
  let timestamp: Date

  /// Current status (open, in-progress, resolved)
  let status: IncidentStatus

  /// Array of user messages that contributed to this report
  let userComments: [String]

  /// Any images associated with the report
  let images: [UIImage]

  /// Creates a new report with the given attributes
  /// - Parameters:
  ///   - id: Unique identifier for the report
  ///   - title: Brief incident title
  ///   - description: Detailed description
  ///   - location: Where the incident occurred
  ///   - timestamp: When the incident occurred
  ///   - status: Current status (usually .open or .inProgress)
  ///   - userComments: Array of user messages that contributed to this report
  ///   - images: Any images associated with the report
  init(
    id: String = UUID().uuidString,
    title: String,
    description: String,
    location: String,
    timestamp: Date = Date(),
    status: IncidentStatus = .inProgress,
    userComments: [String] = [],
    images: [UIImage] = []
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.location = location
    self.timestamp = timestamp
    self.status = status
    self.userComments = userComments
    self.images = images
  }

  /// Creates an Incident model from this report data
  func toIncident() -> Incident {
    return Incident(
      id: id,
      title: title,
      description: description,
      location: location,
      time: timestamp,
      status: status
    )
  }
}
