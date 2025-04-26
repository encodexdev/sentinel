import Foundation
import UIKit  // for UIImage if you embed images inline

enum ChatItem: Identifiable {
  case text(ChatMessage)
  case emergency(level: String, id: String = UUID().uuidString)
  case image(count: Int, id: String = UUID().uuidString)

  var id: String {
    switch self {
    case .text(let msg): return msg.id
    case .emergency(_, let id): return id
    case .image(_, let id): return id
    }
  }
}
