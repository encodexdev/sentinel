import SwiftUI

struct AvatarView: View {
  let name: String

  private var initials: String {
    let parts = name.split(separator: " ")
    return parts.compactMap { $0.first }.prefix(2).map(String.init).joined()
  }

  var body: some View {
    Circle()
      .fill(Color.gray.opacity(0.3))
      .frame(width: 64, height: 64)
      .overlay(
        Text(initials)
          .font(.headline)
          .foregroundColor(.white)
      )
  }
}
