import SwiftUI

// MARK: - ChatMessageList

struct ChatMessageList: View {
  // MARK: - Properties
  
  @EnvironmentObject var vm: ChatViewModel

  /// Available incident type options for suggestion chips
  private let incidentTypes = ["Suspicious Person", "Theft", "Vandalism", "Other"]

  // MARK: - Body
  
  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(vm.items) { item in
            switch item {
            case .text(let msg):
              // MARK: Text Message Bubbles
              ChatBubble(message: msg)
                .id(item.id)
              
              // MARK: Suggestion Chips
              if vm.shouldShowChips(after: item) {
                SuggestionChips(
                  suggestions: incidentTypes,
                  emergencyOption: true
                ) {
                  vm.selectIncidentType($0)
                }
                .padding(.top, 8)
              }
              
              // MARK: Cancel Emergency Chip
              if vm.shouldShowCancelChip(after: item) {
                SuggestionChips(
                  suggestions: [],
                  cancelEmergency: true
                ) {
                  if $0 == "Cancel Emergency" {
                    vm.showCancelEmergencyConfirmation = true
                  }
                }
                .padding(.top, 8)
              }
              
              // MARK: Submit Report Chip
              if vm.shouldShowSubmitChip(after: item) {
                SuggestionChips(
                  suggestions: [],
                  submitReport: true
                ) {
                  if $0 == "Submit Report" {
                    // Show submit confirmation dialog
                    NotificationCenter.default.post(name: Notification.Name("ShowSubmitConfirmation"), object: nil)
                  }
                }
                .padding(.top, 8)
              }
              
            case .emergency(let level, _):
              // MARK: Emergency Notification
              EmergencyBubble(level: level)
                .id(item.id)
                
            case .image(let count, _):
              // MARK: Image Upload Indicator
              ImageBubble(count: count)
                .id(item.id)
            }
          }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
      }
      .onChange(of: vm.items.count) { _ in
        vm.scrollToBottom(proxy)
      }
      // Add a spacer view at the bottom to serve as a scroll anchor
      .safeAreaInset(edge: .bottom) {
        Color.clear.frame(height: 60)
      }
    }
    .background(Color("Background"))
  }
}

// MARK: - Previews

struct ChatMessageList_Previews: PreviewProvider {
  // Regular chat conversation
  static var standardViewModel: ChatViewModel {
    let vm = ChatViewModel()
    
    // Add sample messages for a normal incident report
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
        content: "I noticed someone with a hoodie trying door handles in the parking garage level 2",
        timestamp: Date().addingTimeInterval(-180),
        messageType: .chat
      )),
      .image(count: 1, id: "5"),
      .text(ChatMessage(
        id: "6",
        role: .assistant,
        content: "Thanks for the information and the photo. Can you provide any additional details like time or physical description?",
        timestamp: Date().addingTimeInterval(-60),
        messageType: .chat
      ))
    ]
    
    return vm
  }
  
  // Emergency conversation
  static var emergencyViewModel: ChatViewModel {
    let vm = ChatViewModel()
    vm.isEmergencyFlow = true
    
    // Add sample messages for an emergency
    vm.items = [
      .text(ChatMessage(
        id: "1",
        role: .assistant,
        content: "What type of incident would you like to report?",
        timestamp: Date().addingTimeInterval(-300),
        messageType: .chat
      )),
      .emergency(level: "Security", id: "2"),
      .text(ChatMessage(
        id: "3",
        role: .assistant,
        content: "SECURITY assistance has been requested.",
        timestamp: Date().addingTimeInterval(-240),
        messageType: .emergency
      )),
      .text(ChatMessage(
        id: "4",
        role: .assistant,
        content: "Please provide any details about your emergency.",
        timestamp: Date().addingTimeInterval(-230),
        messageType: .emergency
      )),
      .text(ChatMessage(
        id: "5",
        role: .assistant,
        content: "Help is on the way: ETA 5 mins.",
        timestamp: Date().addingTimeInterval(-220),
        messageType: .emergency
      )),
      .text(ChatMessage(
        id: "6",
        role: .user,
        content: "Intruder trying to access server room on 4th floor. Tall male wearing dark clothing.",
        timestamp: Date().addingTimeInterval(-180),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "7",
        role: .assistant,
        content: "This information has been forwarded to emergency responders. They'll be prepared when they arrive.",
        timestamp: Date().addingTimeInterval(-160),
        messageType: .emergency
      )),
      .image(count: 2, id: "8"),
      .text(ChatMessage(
        id: "9",
        role: .assistant,
        content: "The images have been forwarded to emergency responders to assist with their response.",
        timestamp: Date().addingTimeInterval(-60),
        messageType: .emergency
      ))
    ]
    
    return vm
  }
  
  // Emergency conversation with cancel button
  static var emergencyCancelViewModel: ChatViewModel {
    let vm = ChatViewModel()
    vm.isEmergencyFlow = true
    
    // Add sample messages for an emergency
    vm.items = [
      .text(ChatMessage(
        id: "1",
        role: .assistant,
        content: "What type of incident would you like to report?",
        timestamp: Date().addingTimeInterval(-300),
        messageType: .chat
      )),
      .emergency(level: "Security", id: "2"),
      .text(ChatMessage(
        id: "3",
        role: .assistant,
        content: "SECURITY assistance has been requested.",
        timestamp: Date().addingTimeInterval(-240),
        messageType: .emergency
      )),
      .text(ChatMessage(
        id: "4",
        role: .assistant,
        content: "Please provide any details about your emergency.",
        timestamp: Date().addingTimeInterval(-230),
        messageType: .emergency
      )),
      .text(ChatMessage(
        id: "5",
        role: .assistant,
        content: "Help is on the way: ETA 5 mins.",
        timestamp: Date().addingTimeInterval(-220),
        messageType: .emergency
      ))
    ]
    
    return vm
  }
  
  // New conversation with choice chips
  static var newChatViewModel: ChatViewModel {
    let vm = ChatViewModel()
    // A new chat only has the initial message
    return vm
  }
  
  // Conversation with report ready for submission
  static var readyForSubmissionViewModel: ChatViewModel {
    let vm = ChatViewModel()
    
    // Set report as ready for submission
    vm.isReportReadyForSubmission = true
    
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
    
    return vm
  }
  
  static var previews: some View {
    Group {
      // Standard chat - Light mode
      ChatMessageList()
        .environmentObject(standardViewModel)
        .background(Color("Background"))
        .previewDisplayName("Standard - Light")
      
      // Standard chat - Dark mode
      ChatMessageList()
        .environmentObject(standardViewModel)
        .background(Color("Background"))
        .preferredColorScheme(.dark)
        .previewDisplayName("Standard - Dark")
      
      // Emergency chat - Light mode
      ChatMessageList()
        .environmentObject(emergencyViewModel)
        .background(Color("Background"))
        .previewDisplayName("Emergency - Light")
      
      // Emergency chat - Dark mode
      ChatMessageList()
        .environmentObject(emergencyViewModel)
        .background(Color("Background"))
        .preferredColorScheme(.dark)
        .previewDisplayName("Emergency - Dark")
        
      // Emergency with cancel option - Light mode
      ChatMessageList()
        .environmentObject(emergencyCancelViewModel)
        .background(Color("Background"))
        .previewDisplayName("Emergency Cancel - Light")
        
      // Emergency with cancel option - Dark mode
      ChatMessageList()
        .environmentObject(emergencyCancelViewModel)
        .background(Color("Background"))
        .preferredColorScheme(.dark)
        .previewDisplayName("Emergency Cancel - Dark")
        
      // Report ready for submission - Light mode
      ChatMessageList()
        .environmentObject(readyForSubmissionViewModel)
        .background(Color("Background"))
        .previewDisplayName("Submit Ready - Light")
        
      // Report ready for submission - Dark mode
      ChatMessageList()
        .environmentObject(readyForSubmissionViewModel)
        .background(Color("Background"))
        .preferredColorScheme(.dark)
        .previewDisplayName("Submit Ready - Dark")
        
      // New chat with suggestion chips - Light mode
      ChatMessageList()
        .environmentObject(newChatViewModel)
        .background(Color("Background"))
        .previewDisplayName("New Chat - Light")
        
      // New chat with suggestion chips - Dark mode
      ChatMessageList()
        .environmentObject(newChatViewModel)
        .background(Color("Background"))
        .preferredColorScheme(.dark)
        .previewDisplayName("New Chat - Dark")
    }
  }
}
