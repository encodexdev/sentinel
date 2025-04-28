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
                ) { selection in
                  // Decouple action from view update cycle with asyncAfter
                  let selectedType = selection // Cache the selection to avoid capture issues
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    vm.selectIncidentType(selectedType)
                  }
                }
                .padding(.top, 8)
              }
              
              // MARK: Cancel Emergency Chip
              if vm.shouldShowCancelChip(after: item) {
                SuggestionChips(
                  suggestions: [],
                  cancelEmergency: true
                ) { selection in
                  if selection == "Cancel Emergency" {
                    // Decouple action from view update cycle with asyncAfter
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                      vm.showCancelEmergencyConfirmation = true
                    }
                  }
                }
                .padding(.top, 8)
              }
              
              // MARK: Submit Report Chip
              if vm.shouldShowSubmitChip(after: item) {
                SuggestionChips(
                  suggestions: [],
                  submitReport: true
                ) { selection in
                  if selection == "Submit Report" {
                    // Decouple action from view update cycle with asyncAfter
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                      // Show submit confirmation dialog
                      NotificationCenter.default.post(name: Notification.Name("ShowSubmitConfirmation"), object: nil)
                    }
                  }
                }
                .padding(.top, 8)
              }
              
              // MARK: View Incidents Chip
              if vm.shouldShowViewIncidentsChip(after: item) {
                SuggestionChips(
                  suggestions: ["View Incidents"],
                  viewIncidents: true,
                  isPrimary: true
                ) { selected in
                  if selected == "View Incidents" {
                    // Decouple action from view update cycle with asyncAfter
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                      vm.viewIncidents()
                    }
                  }
                }
                .padding(.top, 8)
              }
              
            case .emergency(let level, _):
              // MARK: Emergency Notification
              EmergencyBubble(level: level)
                .id(item.id)
                
            case .image(let images, _, let caption):
              // MARK: Image Messages with Preview
              ImageBubble(images: images, caption: caption)
                .id(item.id)
                
            case .report(let reportData, _):
              // MARK: Report Summary
              ReportBubble(report: reportData)
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
      .image(images: [UIImage(systemName: "photo.fill")!], id: "5", caption: "Here's a photo of the suspicious person"),
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
      .image(images: [UIImage(systemName: "photo.fill")!, UIImage(systemName: "photo.fill")!], id: "8", caption: "Photos of the intruder"),
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
  
  // Conversation with report displayed
  static var reportViewModel: ChatViewModel {
    let vm = ChatViewModel()
    
    // Add sample messages for a report conversation
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
      .image(images: [UIImage(systemName: "photo.fill")!], id: "5", caption: "Here's a photo of the person"),
      .text(ChatMessage(
        id: "6",
        role: .assistant,
        content: "Where did this happen?",
        timestamp: Date().addingTimeInterval(-140),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "7",
        role: .user,
        content: "West Parking Garage, Level 2",
        timestamp: Date().addingTimeInterval(-120),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "8",
        role: .assistant,
        content: "I've compiled your report:",
        timestamp: Date().addingTimeInterval(-100),
        messageType: .chat
      )),
      .report(
        ReportData(
          title: "Suspicious Person in Parking Garage",
          description: "Individual attempting to open car doors on Level 2",
          location: "West Parking Garage",
          timestamp: Date().addingTimeInterval(-180),
          status: .inProgress,
          userComments: [
            "Someone was trying car door handles in the parking lot",
            "West Parking Garage, Level 2"
          ],
          images: [UIImage(systemName: "photo.fill")!]
        ),
        id: "9"
      ),
      .text(ChatMessage(
        id: "10",
        role: .assistant,
        content: "This report has been filed. Security personnel will investigate. Would you like to add any additional details?",
        timestamp: Date().addingTimeInterval(-80),
        messageType: .chat
      ))
    ]
    
    return vm
  }
  
  // Conversation with View Incidents chip after submission
  static var viewIncidentsViewModel: ChatViewModel {
    let vm = ChatViewModel()
    
    // Set flag to show View Incidents chip
    vm.showViewIncidents = true
    
    // Add sample messages for a submitted report
    vm.items = [
      .text(ChatMessage(
        id: "1",
        role: .assistant,
        content: "What type of incident would you like to report?",
        timestamp: Date().addingTimeInterval(-500),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "2",
        role: .user,
        content: "Vandalism",
        timestamp: Date().addingTimeInterval(-480),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "3",
        role: .assistant,
        content: "Thanks for reporting a Vandalism incident. Can you describe what happened?",
        timestamp: Date().addingTimeInterval(-460),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "4",
        role: .user,
        content: "Someone spray painted graffiti on the wall in the alley",
        timestamp: Date().addingTimeInterval(-440),
        messageType: .chat
      )),
      .image(images: [UIImage(systemName: "photo.fill")!], id: "5", caption: "Here's a photo of the graffiti"),
      .text(ChatMessage(
        id: "6",
        role: .assistant,
        content: "Where did this happen exactly?",
        timestamp: Date().addingTimeInterval(-400),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "7",
        role: .user,
        content: "South side alley near the loading dock",
        timestamp: Date().addingTimeInterval(-380),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "8",
        role: .assistant,
        content: "I've compiled an incident report based on your information:",
        timestamp: Date().addingTimeInterval(-360),
        messageType: .chat
      )),
      .report(
        ReportData(
          title: "Vandalism Incident",
          description: "Graffiti on wall in alley",
          location: "South side alley near loading dock",
          timestamp: Date().addingTimeInterval(-440),
          status: .open,
          userComments: [
            "Someone spray painted graffiti on the wall in the alley",
            "South side alley near the loading dock"
          ],
          images: [UIImage(systemName: "photo.fill")!]
        ),
        id: "9"
      ),
      .text(ChatMessage(
        id: "10",
        role: .assistant,
        content: "Your incident report has been submitted successfully.",
        timestamp: Date().addingTimeInterval(-240),
        messageType: .chat
      )),
      .text(ChatMessage(
        id: "11",
        role: .assistant,
        content: "You can view all incidents in the Incidents tab.",
        timestamp: Date().addingTimeInterval(-220),
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
        
      // Chat with report displayed - Light mode
      ChatMessageList()
        .environmentObject(reportViewModel)
        .background(Color("Background"))
        .previewDisplayName("With Report - Light")
        
      // Chat with report displayed - Dark mode
      ChatMessageList()
        .environmentObject(reportViewModel)
        .background(Color("Background"))
        .preferredColorScheme(.dark)
        .previewDisplayName("With Report - Dark")
        
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
        
      // Chat with View Incidents chip - Light mode
      ChatMessageList()
        .environmentObject(viewIncidentsViewModel)
        .background(Color("Background"))
        .previewDisplayName("View Incidents - Light")
        
      // Chat with View Incidents chip - Dark mode
      ChatMessageList()
        .environmentObject(viewIncidentsViewModel)
        .background(Color("Background"))
        .preferredColorScheme(.dark)
        .previewDisplayName("View Incidents - Dark")
        
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
