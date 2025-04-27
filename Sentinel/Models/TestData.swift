import Foundation
import MapKit
import SwiftUI

//TODO: Add default Data enum
enum TestData {
  static let user = User(
    id: "GB4589",
    fullName: "Marcus Brooks",
    role: "Security Officer",
    avatarURL: nil,
    avatarImageName: "ProfileImage",  // Use local image asset
    email: "marcus.brooks@gmail.com",
    phoneNumber: "(555) 123-4567",
    startDate: "08/15/2023",
    isOnDuty: true
  )

  static let settings = Settings(
    preferredColorScheme: nil,  // Follow system by default
    notificationsEnabled: false,
    locationEnabled: false
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
    Incident(
      id: "3",
      title: "Unauthorized Access",
      description: "Attempted access to server room without credentials",
      location: "IT Department",
      time: Date().addingTimeInterval(-14400),
      status: .open
    ),
    Incident(
      id: "4",
      title: "Fire Alarm Triggered",
      description: "Smoke detector activated in kitchen area",
      location: "Employee Lounge",
      time: Date().addingTimeInterval(-21600),
      status: .resolved
    )
  ]

  static let locationIncidents: [Incident] = [
    Incident(
      id: "5",
      title: "Medical Emergency",
      description: "Visitor fainted in conference room",
      location: "Conference Room B",
      time: Date().addingTimeInterval(-10800),
      status: .resolved
    ),
    Incident(
      id: "6",
      title: "Tailgating Reported",
      description: "Unknown person followed employee through security door",
      location: "South Entrance",
      time: Date().addingTimeInterval(-5400),
      status: .open
    ),
    Incident(
      id: "7",
      title: "Suspicious Package",
      description: "Unattended backpack in reception area",
      location: "Main Reception",
      time: Date().addingTimeInterval(-12600),
      status: .inProgress
    ),
    Incident(
      id: "8",
      title: "Elevator Malfunction",
      description: "Elevator 2 stuck between floors with passengers",
      location: "Building Core",
      time: Date().addingTimeInterval(-18000),
      status: .resolved
    )
  ]

  static let messages: [ChatMessage] = [
    ChatMessage(
      id: "m1",
      role: .assistant,
      content: "What type of incident would you like to report?",
      timestamp: Date(),
      messageType: .chat
    ),
    ChatMessage(
      id: "m2",
      role: .user,
      content: "Suspicious Person",
      timestamp: Date().addingTimeInterval(5),
      messageType: .chat
    ),
  ]

}
