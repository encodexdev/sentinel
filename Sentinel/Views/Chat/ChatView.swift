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
        
        // Only show Submit button in normal mode when report is ready
        if !viewModel.isEmergencyFlow {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button("Submit") {
              showingSubmitConfirmation = true
            }
            .fontWeight(.bold)
            .disabled(!viewModel.isReportReadyForSubmission)
            .opacity(viewModel.isReportReadyForSubmission ? 1.0 : 0.5)
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
  @ObservedObject var viewModel: ChatViewModel
  let showSubmitConfirmation: Binding<Bool>
  let showRestartConfirmation: Binding<Bool>
  
  var body: some View {
    VStack(spacing: 0) {
      ChatMessageList()
      ChatInputBar()
    }
    .background(Color("Background"))
    .onAppear {
      // Set up notification observer for submit button in chat
      NotificationCenter.default.addObserver(forName: Notification.Name("ShowSubmitConfirmation"), 
                                            object: nil, 
                                            queue: .main) { _ in
        // Add a slight delay to avoid view update conflicts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          showSubmitConfirmation.wrappedValue = true
        }
      }
    }
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
        isPresented: Binding(
          get: { viewModel.showCancelEmergencyConfirmation },
          set: { viewModel.showCancelEmergencyConfirmation = $0 }
        ),
        titleVisibility: .visible
      ) {
        Button("Cancel Emergency", role: .destructive) {
          // Use a dispatch to main async to avoid view update cycle issues
          DispatchQueue.main.async {
            viewModel.cancelEmergency()
          }
        }
        Button("Keep Emergency Active", role: .cancel) { }
      } message: {
        Text("This will end the emergency mode but keep your incident on file. Emergency responders may still arrive.")
      }
      
      // Emergency options dialog
      .confirmationDialog(
        "Request Emergency Assistance",
        isPresented: Binding(
          get: { viewModel.showEmergencyOptions },
          set: { 
            viewModel.showEmergencyOptions = $0
            // If the dialog is being dismissed without selecting an option,
            // we need to reset the processing flag
            if !$0 {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.isProcessingAIResponse = false
              }
            }
          }
        ),
        titleVisibility: .visible
      ) {
        Button("Police", role: .destructive) {
          // Process emergency after the dialog is dismissed
          let emergencyLevel = "Police"
          viewModel.showEmergencyOptions = false
          // Use a slight delay to ensure the dialog has finished dismissing
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.sendEmergencyMessage(level: emergencyLevel)
            // Note: No need to reset isProcessingAIResponse as sendEmergencyMessage will use it
          }
        }
        Button("Security", role: .destructive) {
          // Process emergency after the dialog is dismissed
          let emergencyLevel = "Security"
          viewModel.showEmergencyOptions = false
          // Use a slight delay to ensure the dialog has finished dismissing
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.sendEmergencyMessage(level: emergencyLevel)
            // Note: No need to reset isProcessingAIResponse as sendEmergencyMessage will use it
          }
        }
        Button("Medical", role: .destructive) {
          // Process emergency after the dialog is dismissed
          let emergencyLevel = "Medical" 
          viewModel.showEmergencyOptions = false
          // Use a slight delay to ensure the dialog has finished dismissing
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.sendEmergencyMessage(level: emergencyLevel)
            // Note: No need to reset isProcessingAIResponse as sendEmergencyMessage will use it
          }
        }
        Button("Cancel", role: .cancel) { 
          // When Cancel is tapped, reset the processing flag
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.isProcessingAIResponse = false
          }
        }
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
        
      // Report ready for submission in light mode
      ChatView()
        .environmentObject(createSubmissionReadyViewModel())
        .previewDisplayName("Submit Ready - Light")
        
      // Report ready for submission in dark mode
      ChatView()
        .environmentObject(createSubmissionReadyViewModel())
        .preferredColorScheme(.dark)
        .previewDisplayName("Submit Ready - Dark")
    }
  }
  
  // Helper to create a view model in emergency mode for previews
  static func createEmergencyViewModel() -> ChatViewModel {
    let vm = ChatViewModel()
    
    // Simulate emergency mode
    vm.sendEmergencyMessage(level: "Police")
    
    return vm
  }
  
  // Helper to create a view model with report ready for submission
  static func createSubmissionReadyViewModel() -> ChatViewModel {
    let vm = ChatViewModel()
    
    // Add sample messages for a completed report
    vm.items = [
      .text(ChatMessage(
        id: "1",
        role: .assistant,
        content: "What type of incident would you like to report?",
        timestamp: Date().addingTimeInterval(-300),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "2",
        role: .user,
        content: "Suspicious Person",
        timestamp: Date().addingTimeInterval(-240),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "3",
        role: .assistant,
        content: "Thanks for reporting a Suspicious Person incident. Can you describe what happened?",
        timestamp: Date().addingTimeInterval(-220),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "4",
        role: .user,
        content: "Someone was trying car door handles in the parking lot",
        timestamp: Date().addingTimeInterval(-180),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "5",
        role: .assistant,
        content: "I've recorded your report. Would you like to submit it now or add more details?",
        timestamp: Date().addingTimeInterval(-60),
        messageType: .chat
      ))
    ]
    
    // Set report as ready for submission - since we have 2 user messages, this is correct
    vm.isReportReadyForSubmission = true
    
    return vm
  }
}
