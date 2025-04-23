import SwiftUI

struct ChatView: View {
  @StateObject private var viewModel = ChatViewModel()

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ChatMessageList()
        Divider()
        ChatInputBar()
      }
      .navigationTitle("Report Incident")
      .navigationBarTitleDisplayMode(.inline)
      // Global background handled by SentinelApp
      .environmentObject(viewModel)
    }
  }
}
