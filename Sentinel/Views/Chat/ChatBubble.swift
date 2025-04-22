import SwiftUI

struct ChatBubble: View {
  let message: Message
  var maxWidth: CGFloat = UIScreen.main.bounds.width * 0.75

  var body: some View {
    HStack {
      if message.sender == .assistant {
        bubble
        Spacer(minLength: 40)
      } else {
        Spacer(minLength: 40)
        bubble
      }
    }
    .padding(.horizontal, 10)
  }

  private var bubble: some View {
    Text(message.content)
      .padding(12)
      .foregroundColor(message.sender == .user ? .white : .primary)
      .background(
        message.sender == .user
          ? Color("AccentBlue")
          : Color("CardBackground")
      )
      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
      .frame(maxWidth: maxWidth, alignment: message.sender == .user ? .trailing : .leading)
  }
}
