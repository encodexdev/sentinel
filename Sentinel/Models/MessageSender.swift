import Foundation

enum MessageSender: String, Codable {
  case user
  case assistant
  case system
  case tool
}
