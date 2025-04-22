import Foundation

final class ChatViewModel: ObservableObject {
  @Published var messages: [Message] = TestData.messages
  @Published var inputText: String = ""

  func sendMessage() {
    guard !inputText.isEmpty else { return }
    let new = Message(
      id: UUID().uuidString,
      sender: .user,
      content: inputText,
      timestamp: Date()
    )
    messages.append(new)
    inputText = ""

    // Stub an AI reply after a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      let reply = Message(
        id: UUID().uuidString,
        sender: .assistant,
        content: "Got it. Tell me where this happened.",
        timestamp: Date()
      )
      self.messages.append(reply)
    }
  }
}
