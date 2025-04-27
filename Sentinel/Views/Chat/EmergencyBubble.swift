import SwiftUI

/// A styled bubble for emergency messages.
struct EmergencyBubble: View, Identifiable {
    let id = UUID().uuidString
    let level: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Emergency")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(level.capitalized) assistance requested")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.red)
        .cornerRadius(12)
        .padding(.horizontal, 12)
    }
}

struct EmergencyBubble_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode
            VStack(spacing: 16) {
                EmergencyBubble(level: "police")
                EmergencyBubble(level: "security")
                EmergencyBubble(level: "medical")
            }
            .padding()
            .background(Color("Background"))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Emergency Bubbles - Light")
            
            // Dark mode
            VStack(spacing: 16) {
                EmergencyBubble(level: "police")
                EmergencyBubble(level: "security")
            }
            .padding()
            .background(Color("Background"))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Emergency Bubbles - Dark")
            
            // In chat context
            VStack {
                Spacer()
                EmergencyBubble(level: "security")
                ChatBubble(message: ChatMessage(
                    id: "response1",
                    role: .assistant,
                    content: "Security has been notified. They are on their way to your location.",
                    timestamp: Date(),
                    messageType: .chat
                ))
            }
            .padding()
            .background(Color("Background"))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("In Chat Context")
        }
    }
}
