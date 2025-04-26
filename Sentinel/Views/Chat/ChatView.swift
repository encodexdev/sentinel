import SwiftUI
import PhotosUI

struct ChatView: View {
  @StateObject private var viewModel = ChatViewModel()
  @Environment(\.dismiss) private var dismiss
  @State private var showingSubmitConfirmation = false

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
            showingSubmitConfirmation = true
          }
          .fontWeight(.bold)
        }
      }
      .confirmationDialog(
        "Submit Incident Report",
        isPresented: $showingSubmitConfirmation,
        titleVisibility: .visible
      ) {
        Button("Submit Report") {
          if viewModel.submitReport() {
            dismiss()
          }
        }
        Button("Cancel", role: .cancel) { }
      } message: {
        Text("This will submit your incident report including any images and messages.")
      }
      // Global background handled by SentinelApp
      .environmentObject(viewModel)
    }
  }
}
