import SwiftUI
import PhotosUI

struct ChatView: View {
  @StateObject private var viewModel = ChatViewModel()
  @Environment(\.dismiss) private var dismiss
  @State private var showingSubmitConfirmation = false
  @State private var showingRestartConfirmation = false

  var body: some View {
    NavigationStack {
      // Main content
      ChatContent(
        viewModel: viewModel,
        showSubmitConfirmation: $showingSubmitConfirmation,
        showRestartConfirmation: $showingRestartConfirmation
      )
      
      // Apply navigation styling
      .navigationTitle(viewModel.isEmergencyFlow ? "EMERGENCY" : "Report Incident")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(viewModel.isEmergencyFlow ? Color.red : Color("CardBackground"), for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(viewModel.isEmergencyFlow ? .dark : nil, for: .navigationBar)
      
      // Apply toolbar items
      .toolbar {
        // Leading toolbar item
        ToolbarItem(placement: .navigationBarLeading) {
          if viewModel.isEmergencyFlow {
            // Cancel button for emergency mode
            Button("Cancel") {
              viewModel.showCancelEmergencyConfirmation = true
            }
            .foregroundColor(.white)
          } else {
            // Restart button for normal mode
            Button("Restart") {
              // Only show confirmation if there's more than the initial message
              if viewModel.items.count > 1 || !viewModel.selectedImages.isEmpty {
                showingRestartConfirmation = true
              } else {
                // If no meaningful conversation yet, just restart directly
                viewModel.restartChat()
              }
            }
            .foregroundColor(.blue)
          }
        }
        
        // Only show Submit button in normal mode
        if !viewModel.isEmergencyFlow {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Submit") {
              showingSubmitConfirmation = true
            }
            .fontWeight(.bold)
          }
        }
      }
      
      // Apply confirmation dialogs
      .applyConfirmationDialogs(
        viewModel: viewModel,
        showSubmitConfirmation: $showingSubmitConfirmation,
        showRestartConfirmation: $showingRestartConfirmation,
        dismiss: dismiss
      )
      
      // Global environment object
      .environmentObject(viewModel)
    }
  }
}

// MARK: - Helper Components

// Main chat content component
struct ChatContent: View {
  let viewModel: ChatViewModel
  let showSubmitConfirmation: Binding<Bool>
  let showRestartConfirmation: Binding<Bool>
  
  var body: some View {
    VStack(spacing: 0) {
      ChatMessageList()
      ChatInputBar()
    }
    .background(Color("Background"))
  }
}


// Extension for applying confirmation dialogs
extension View {
  func applyConfirmationDialogs(
    viewModel: ChatViewModel,
    showSubmitConfirmation: Binding<Bool>,
    showRestartConfirmation: Binding<Bool>,
    dismiss: DismissAction
  ) -> some View {
    self
      // Submit confirmation dialog
      .confirmationDialog(
        "Submit Incident Report",
        isPresented: showSubmitConfirmation,
        titleVisibility: .visible
      ) {
        Button("Submit Report") {
          if viewModel.submitReport() {
            // Navigation is handled in the viewModel
            showSubmitConfirmation.wrappedValue = false
          }
        }
        Button("Cancel", role: .cancel) { }
      } message: {
        Text("This will submit your incident report including any images and messages.")
      }
      
      // Restart confirmation dialog
      .confirmationDialog(
        "Restart Incident Report",
        isPresented: showRestartConfirmation,
        titleVisibility: .visible
      ) {
        Button("Restart", role: .destructive) {
          viewModel.restartChat()
        }
        Button("Cancel", role: .cancel) { }
      } message: {
        Text("This will clear all messages and images in the current incident report. Are you sure you want to start over?")
      }
      
      // Cancel emergency confirmation dialog
      .confirmationDialog(
        "Cancel Emergency Assistance",
        isPresented: .init(
          get: { viewModel.showCancelEmergencyConfirmation },
          set: { viewModel.showCancelEmergencyConfirmation = $0 }
        ),
        titleVisibility: .visible
      ) {
        Button("Cancel Emergency", role: .destructive) {
          viewModel.cancelEmergency()
        }
        Button("Keep Emergency Active", role: .cancel) { }
      } message: {
        Text("This will end the emergency mode but keep your incident on file. Emergency responders may still arrive.")
      }
      
      // Emergency options dialog
      .confirmationDialog(
        "Request Emergency Assistance",
        isPresented: .init(
          get: { viewModel.showEmergencyOptions },
          set: { viewModel.showEmergencyOptions = $0 }
        ),
        titleVisibility: .visible
      ) {
        Button("Police", role: .destructive) {
          viewModel.sendEmergencyMessage(level: "Police")
        }
        Button("Security", role: .destructive) {
          viewModel.sendEmergencyMessage(level: "Security")
        }
        Button("Medical", role: .destructive) {
          viewModel.sendEmergencyMessage(level: "Medical")
        }
        Button("Cancel", role: .cancel) { }
      } message: {
        Text("Emergency services will be contacted immediately")
      }
  }
}

// MARK: - Previews
struct ChatView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      // Light mode standard chat
      ChatView()
        .environmentObject(ChatViewModel())
        .previewDisplayName("Light Mode")
      
      // Dark mode chat
      ChatView()
        .environmentObject(ChatViewModel())
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
      
      // Emergency flow in light mode
      ChatView()
        .environmentObject(createEmergencyViewModel())
        .previewDisplayName("Emergency - Light")
      
      // Emergency flow in dark mode
      ChatView()
        .environmentObject(createEmergencyViewModel())
        .preferredColorScheme(.dark)
        .previewDisplayName("Emergency - Dark")
    }
  }
  
  // Helper to create a view model in emergency mode for previews
  static func createEmergencyViewModel() -> ChatViewModel {
    let vm = ChatViewModel()
    
    // Simulate emergency mode
    vm.sendEmergencyMessage(level: "Police")
    
    return vm
  }
}
