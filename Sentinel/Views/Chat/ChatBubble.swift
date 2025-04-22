import SwiftUI

struct ChatBubble: View {
  let message: Message

  var body: some View {
    HStack {
      if message.sender == .assistant { Spacer() }
      Text(message.content)
        .padding(10)
        .background(message.sender == .user ? Color.accentColor : Color("CardBackground"))
        .foregroundColor(message.sender == .user ? .white : .primary)
        .cornerRadius(8)
      if message.sender == .user { Spacer() }
    }
  }
}
