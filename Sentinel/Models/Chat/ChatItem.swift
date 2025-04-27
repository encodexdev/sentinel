import Foundation
import UIKit

enum ChatItem: Identifiable {
  case text(ChatMessage)
  case emergency(level: String, id: String = UUID().uuidString)
  case image(images: [UIImage], id: String = UUID().uuidString, caption: String = "")
  case report(ReportData, id: String = UUID().uuidString)

  var id: String {
    switch self {
    case .text(let msg): return msg.id
    case .emergency(_, let id): return id
    case .image(_, let id, _): return id
    case .report(let report, _): return report.id
    }
  }
}
