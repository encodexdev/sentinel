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
          messageContent
        }
        Spacer(minLength: 40)
      } else {
        Spacer(minLength: 40)
        VStack(alignment: .trailing, spacing: 4) {
          // Emergency or image badges for user messages
          messageBadges
          messageContent
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
  
  @ViewBuilder
  private var messageContent: some View {
    if message.messageType == .loading {
      loadingBubble
    } else {
      textBubble
    }
  }

  private var textBubble: some View {
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
  
  private var loadingBubble: some View {
    TypingIndicator()
      .padding(12)
      .background(Color("CardBackground"))
      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
      .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
      .frame(maxWidth: maxWidth, alignment: .leading)
  }
}

// Separate view for the typing animation
struct TypingIndicator: View {
  // State for animations
  @State private var firstDotOffset: CGFloat = 0
  @State private var secondDotOffset: CGFloat = 0
  @State private var thirdDotOffset: CGFloat = 0
  
  var body: some View {
    HStack(spacing: 4) {
      Circle()
        .fill(Color.gray.opacity(0.6))
        .frame(width: 8, height: 8)
        .offset(y: firstDotOffset)
      
      Circle()
        .fill(Color.gray.opacity(0.6))
        .frame(width: 8, height: 8)
        .offset(y: secondDotOffset)
      
      Circle()
        .fill(Color.gray.opacity(0.6))
        .frame(width: 8, height: 8)
        .offset(y: thirdDotOffset)
    }
    .onAppear {
      startAnimation()
    }
  }
  
  private func startAnimation() {
    // Start animations with different delays
    withAnimation(Animation.easeInOut(duration: 0.4)
                  .repeatForever(autoreverses: true)) {
      firstDotOffset = -4
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      withAnimation(Animation.easeInOut(duration: 0.4)
                    .repeatForever(autoreverses: true)) {
        secondDotOffset = -4
      }
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
      withAnimation(Animation.easeInOut(duration: 0.4)
                    .repeatForever(autoreverses: true)) {
        thirdDotOffset = -4
      }
    }
  }
}

// MARK: - Previews

struct ChatBubble_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      // Standard message bubbles
      VStack(spacing: 16) {
        // User message
        ChatBubble(message: ChatMessage(
          id: "1",
          role: .user,
          content: "Hello, I want to report a suspicious person in the lobby.",
          timestamp: Date(),
          messageType: .chat
        ))
        
        // Assistant message
        ChatBubble(message: ChatMessage(
          id: "2",
          role: .assistant,
          content: "Thanks for reporting. Can you describe what makes this person suspicious?",
          timestamp: Date(),
          messageType: .chat
        ))
        
        // Long message
        ChatBubble(message: ChatMessage(
          id: "3",
          role: .user,
          content: "They're wearing a black hoodie and have been walking around the building for over 30 minutes, looking at the security cameras and checking door handles. They don't appear to have an ID badge.",
          timestamp: Date(),
          messageType: .chat
        ))
      }
      .padding()
      .background(Color("Background"))
      .previewDisplayName("Standard Chat Bubbles")
      
      // Special message types
      VStack(spacing: 16) {
        // Emergency message
        ChatBubble(message: ChatMessage(
          id: "4",
          role: .user,
          content: "Need immediate assistance! Intruder at east entrance!",
          timestamp: Date(),
          messageType: .emergency
        ))
        
        // Loading indicator message
        ChatBubble(message: ChatMessage(
          id: "loading",
          role: .assistant,
          content: "",
          timestamp: Date(),
          messageType: .loading
        ))
        
        // Image message
        ChatBubble(message: ChatMessage(
          id: "5",
          role: .user,
          content: "Here's a photo of the suspicious vehicle.",
          timestamp: Date(),
          messageType: .image
        ))
        
        // Assistant with image reference
        ChatBubble(message: ChatMessage(
          id: "6",
          role: .assistant,
          content: "I can see the vehicle in your photo. Is this the correct license plate: ABC-123?",
          timestamp: Date(),
          messageType: .chat
        ))
      }
      .padding()
      .background(Color("Background"))
      .previewDisplayName("Special Message Types")
      
      // Dark mode preview
      VStack(spacing: 16) {
        ChatBubble(message: ChatMessage(
          id: "7",
          role: .user,
          content: "This is how it looks in dark mode.",
          timestamp: Date(),
          messageType: .chat
        ))
        
        // Loading dark mode
        ChatBubble(message: ChatMessage(
          id: "loading_dark",
          role: .assistant,
          content: "",
          timestamp: Date(),
          messageType: .loading
        ))
        
        ChatBubble(message: ChatMessage(
          id: "8",
          role: .assistant,
          content: "Dark mode looks great!",
          timestamp: Date(),
          messageType: .chat
        ))
      }
      .padding()
      .background(Color("Background"))
      .preferredColorScheme(.dark)
      .previewDisplayName("Dark Mode")
    }
  }
}
