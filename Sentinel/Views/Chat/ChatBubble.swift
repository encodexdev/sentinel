import SwiftUI

struct ChatBubble: View {
  let message: ChatMessage
  var maxWidth: CGFloat = UIScreen.main.bounds.width * 0.75

  var body: some View {
    HStack {
      if message.role == .assistant {
        VStack(alignment: .leading, spacing: 4) {
          // Emergency or image badges for assistant messages
          messageBadges
          bubble
        }
        Spacer(minLength: 40)
      } else {
        Spacer(minLength: 40)
        VStack(alignment: .trailing, spacing: 4) {
          // Emergency or image badges for user messages
          messageBadges
          bubble
        }
      }
    }
    .padding(.horizontal, 10)
  }
  
  // Message type badges
  @ViewBuilder
  private var messageBadges: some View {
    if message.messageType == .emergency {
      HStack(spacing: 4) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.caption)
        Text("EMERGENCY")
          .font(.caption)
          .fontWeight(.bold)
      }
      .foregroundColor(.white)
      .padding(.horizontal, 8)
      .padding(.vertical, 2)
      .background(Color.red)
      .cornerRadius(8)
    } else if message.messageType == .image {
      HStack(spacing: 4) {
        Image(systemName: "photo.fill")
          .font(.caption)
        Text("IMAGE ATTACHED")
          .font(.caption)
      }
      .foregroundColor(.white)
      .padding(.horizontal, 8)
      .padding(.vertical, 2)
      .background(Color.blue)
      .cornerRadius(8)
    }
  }

  private var bubble: some View {
    Text(message.content)
      .padding(12)
      .foregroundColor(message.role == .user ? .white : .primary)
      .background(
        message.messageType == .emergency 
          ? Color.red.opacity(0.8)
          : message.role == .user
            ? Color("AccentBlue")
            : Color("CardBackground")
      )
      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
      .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
      .frame(maxWidth: maxWidth, alignment: message.role == .user ? .trailing : .leading)
  }
}
