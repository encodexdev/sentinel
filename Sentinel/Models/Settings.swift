import Foundation
import SwiftUI

struct Settings: Codable {
  // nil = System
  var preferredColorScheme: ColorScheme?
  var notificationsEnabled: Bool
  var locationEnabled: Bool
}

// Extension to make ColorScheme Codable
extension ColorScheme: Codable {
  enum CodingKeys: String, CodingKey {
    case rawValue
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rawValue = try container.decode(Int.self, forKey: .rawValue)
    self = rawValue == 1 ? .dark : .light
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self == .dark ? 1 : 0, forKey: .rawValue)
  }
}
