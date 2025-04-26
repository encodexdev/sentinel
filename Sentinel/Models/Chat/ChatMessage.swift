import Foundation

struct ChatMessage: Identifiable, Codable {
  let id: String
  let role: ChatRole
  let content: String
  let timestamp: Date
  var messageType: MessageType = .chat

  init(id: String, role: ChatRole, content: String, timestamp: Date, messageType: MessageType)
  {
    self.id = id
    self.role = role
    self.content = content
    self.timestamp = timestamp
    self.messageType = messageType
  }
}

extension ChatMessage {
    /// Creates an emergency ChatMessage for the given level.
    init(emergencyLevel level: String) {
        self.init(
            id: UUID().uuidString,
            role: .user,
            content: "EMERGENCY: \(level) assistance requested",
            timestamp: Date(),
            messageType: .emergency
        )
    }

    /// Creates an image ChatMessage indicating how many images were uploaded.
    init(imageUploadCount count: Int) {
        self.init(
            id: UUID().uuidString,
            role: .user,
            content: "Uploaded \(count) image(s)",
            timestamp: Date(),
            messageType: .image
        )
    }
}
