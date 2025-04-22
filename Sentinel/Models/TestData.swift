import Foundation
import MapKit
import SwiftUI

enum TestData {
  static let user = User(
    id: "u1",
    fullName: "John Doe",
    role: "Security Officer",
    // TODO: Use a real image URL for the avatar through DB
    avatarURL: "https://cdn-icons-png.flaticon.com/512/8631/8631487.png"
      .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      .flatMap(URL.init),
    isOnDuty: true
  )

  static let settings = Settings(
    preferredColorScheme: nil, // Follow system by default
    notificationsEnabled: true,
    locationEnabled: true
  )

  static let incidents: [Incident] = [
    Incident(
      id: "1",
      title: "Suspicious Person",
      description: "Loitering near main entrance",
      location: "Lobby",
      time: Date().addingTimeInterval(-3600),
      status: .open
    ),
    Incident(
      id: "2",
      title: "Broken Window",
      description: "East wing, 3rd floor window shattered",
      location: "3rd Floor, East Wing",
      time: Date().addingTimeInterval(-7200),
      status: .inProgress
    ),
  ]

  static let teamIncidents =
    incidents + [
      Incident(
        id: "3",
        title: "Medical Emergency",
        description: "Visitor fainted in conference room",
        location: "Conference Room B",
        time: Date().addingTimeInterval(-10800),
        status: .resolved
      )
    ]

  static let messages: [Message] = [
    Message(
      id: "m1",
      sender: .assistant,
      content: "What type of incident would you like to report?",
      timestamp: Date()
    ),
    Message(
      id: "m2",
      sender: .user,
      content: "Suspicious Person",
      timestamp: Date().addingTimeInterval(5)
    ),
  ]

}
