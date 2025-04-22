import Foundation

struct Message: Identifiable, Codable {

  let id: String
  let sender: MessageSender
  let content: String
  let timestamp: Date
}
