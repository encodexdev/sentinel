import SwiftUI

struct ChatView: View {
  @StateObject private var viewModel = ChatViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ChatMessageList()
        Divider()
        ChatInputBar()
      }
      .navigationTitle("Report Incident")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Submit") {
            // TODO: Submit incident report
            dismiss()
          }
          .fontWeight(.bold)
        }
      }
      // Global background handled by SentinelApp
      .environmentObject(viewModel)
    }
  }
}
