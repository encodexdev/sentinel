import Combine
import Foundation
import PhotosUI
import SwiftUI

final class ChatViewModel: ObservableObject, TabNavigating {
  @Published var items: [ChatItem] = [
    .text(
      ChatMessage(
        id: UUID().uuidString,
        role: .assistant,
        content: "Hi, I'm here to help. What kind of incident would you like to report?",
        timestamp: Date(),
        messageType: .chat
      ))
  ]
  @Published var inputText: String = ""
  @Published var selectedImages: [UIImage] = []
  @Published var selectedItems: [PhotosPickerItem] = []
  @Published var isLoadingImages: Bool = false
  @Published var showEmergencyOptions: Bool = false

  // Track the flow type (emergency or normal)
  @Published var isEmergencyFlow = false
  @Published var showCancelEmergencyConfirmation = false
  
  // Track report completion state
  @Published var isReportReadyForSubmission = false
  
  // Processing state
  @Published var isProcessingAIResponse = false
  
  // MARK: - OpenAI Integration
  
  /// Current streaming response buffer
  private var responseBuffer = ""
  
  /// Current function call data
  private var currentFunctionName = ""
  private var currentFunctionArgs = ""
  
  /// Get the appropriate system prompt based on current context
  private var currentSystemPrompt: String {
      if isEmergencyFlow {
          // For emergency mode, include the level in the prompt
          let level = extractEmergencyLevel()
          return ChatPrompts.emergency(level: level)
      } else {
          return ChatPrompts.standard
      }
  }
  
  /// Get the appropriate function definitions based on current context
  private var currentFunctionDefinitions: [[String: Any]] {
      if isEmergencyFlow {
          return ChatPrompts.emergencyFunctionDefinitions
      } else {
          return ChatPrompts.standardFunctionDefinitions
      }
  }
  
  /// Extract the emergency level from the conversation
  private func extractEmergencyLevel() -> String {
      // Look for emergency item
      for item in items {
          if case .emergency(let level, _) = item {
              return level
          }
      }
      return "Security" // Default level
  }

  func selectIncidentType(_ type: String) {
    // Check if this is an emergency selection
    if type == "Emergency" {
      // Show emergency options dialog
      showEmergencyOptions = true
      return
    }

    // Add user selection
    let userMsg = ChatMessage(
      id: UUID().uuidString, role: .user, content: type, timestamp: Date(), messageType: .chat)
    items.append(.text(userMsg))
    
    // Add assistant response
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      guard let self = self else { return }
      let response = ChatMessage(
        id: UUID().uuidString, role: .assistant,
        content: "Thanks for reporting a \(type) incident. Can you describe what happened?",
        timestamp: Date(), messageType: .chat)
      self.items.append(.text(response))
    }
  }

  /// Send a message using the OpenAI integration
  func sendMessage() {
    // Use the AI-powered version
    sendMessageWithAI()
  }
  
  /// Updated sendMessage to use OpenAI
  func sendMessageWithAI() {
    let trimmedText = inputText.trimmingCharacters(in: .whitespaces)
    let hasText = !trimmedText.isEmpty
    let hasImages = !selectedImages.isEmpty
    
    // Return if nothing to send
    guard hasText || hasImages else { return }
    
    // If there's text, add user message
    if hasText {
        let userMsg = ChatMessage(
            id: UUID().uuidString, 
            role: .user, 
            content: inputText, 
            timestamp: Date(), 
            messageType: .chat
        )
        items.append(.text(userMsg))
        
        // Check if we have enough context for report submission
        // Count user messages to determine if we're past the initial incident type selection
        let userMessageCount = items.filter { 
          if case .text(let message) = $0, message.role == .user { return true }
          return false
        }.count
        
        // Enable report submission once we have at least two user messages
        // (incident type + details message)
        if userMessageCount >= 2 && !isEmergencyFlow {
          isReportReadyForSubmission = true
        }
    }
    
    // If there are images, add them
    if hasImages {
        // Create a copy of the current images
        let imagesToSend = selectedImages
        
        // Add the image message with caption
        items.append(.image(images: imagesToSend, caption: trimmedText))
        
        // Clear the selected images
        selectedImages = []
        selectedItems = []
        
        // If user adds an image, we definitely have enough context to submit report
        if !isEmergencyFlow {
          isReportReadyForSubmission = true
        }
    }
    
    // Clear the input text
    inputText = ""
    
    // Get AI response
    getAIResponse()
  }
  
  /// Legacy message sending implementation (kept for reference/fallback)
  func sendMessageLegacy() {
    let trimmedText = inputText.trimmingCharacters(in: .whitespaces)
    let hasText = !trimmedText.isEmpty
    let hasImages = !selectedImages.isEmpty
    
    // Return if there's nothing to send
    guard hasText || hasImages else { return }

    // If there's text, add user message first
    if hasText {
      let userMsg = ChatMessage(
        id: UUID().uuidString, role: .user, content: inputText, timestamp: Date(), messageType: .chat)
      items.append(.text(userMsg))
    }
    
    // If there are images, add them as image message
    if hasImages {
      // Create a copy of the current images
      let imagesToSend = selectedImages
      
      // Add the image message with the current caption (input text)
      items.append(.image(images: imagesToSend, caption: trimmedText))
      
      // Log image upload event
      logAnalyticsEvent(
        "image_uploaded",
        details: [
          "count": "\(imagesToSend.count)",
          "has_caption": "\(hasText)",
          "emergency_mode": "\(self.isEmergencyFlow)",
        ])
        
      // Clear the selected images after sending
      selectedImages = []
      selectedItems = []
      
      // If in emergency mode, send emergency-specific response for images
      if isEmergencyFlow {
        sendEmergencyResponseToImageUpload(imageCount: imagesToSend.count)
      }
    }
    
    // Clear the input text
    inputText = ""

    // Send appropriate response based on flow type (if not already handled by image response)
    if !hasImages {
      if isEmergencyFlow {
        // Emergency mode message handling
        sendEmergencyResponseToUserMessage()
      } else {
        // Normal mode message handling
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
          guard let self = self else { return }
          let response = ChatMessage(
            id: UUID().uuidString, role: .assistant,
            content: "I've recorded your report. Is there anything else you'd like to add?",
            timestamp: Date(), messageType: .chat)
          self.items.append(.text(response))
        }
      }
    }
  }

  /// Sends a specialized response to user messages during emergency mode
  private func sendEmergencyResponseToUserMessage() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
      guard let self = self else { return }
      let response = ChatMessage(
        id: UUID().uuidString,
        role: .assistant,
        content:
          "This information has been forwarded to emergency responders. They'll be prepared when they arrive.",
        timestamp: Date(),
        messageType: .emergency
      )
      self.items.append(.text(response))
    }
  }

  /// Sends a specialized response to image uploads during emergency mode
  private func sendEmergencyResponseToImageUpload(imageCount: Int) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
      guard let self = self else { return }
      let pluralSuffix = imageCount > 1 ? "s" : ""
      let response = ChatMessage(
        id: UUID().uuidString,
        role: .assistant,
        content:
          "The image\(pluralSuffix) have been forwarded to emergency responders to assist with their response.",
        timestamp: Date(),
        messageType: .emergency
      )
      self.items.append(.text(response))
    }
  }

  /// Initiate emergency mode with AI responses
  func sendEmergencyMessage(level: String) {
    isEmergencyFlow = true

    // Add emergency notification to chat
    items.append(.emergency(level: level))

    // Log emergency event
    logAnalyticsEvent("emergency_requested", details: ["level": level])
    
    // Get AI response for the emergency
    getAIResponse()
  }
  
  /// Legacy emergency message implementation (kept for reference/fallback)
  func sendEmergencyMessageLegacy(level: String) {
    isEmergencyFlow = true

    // Add emergency notification
    items.append(.emergency(level: level))

    // Log emergency event (would connect to analytics in production)
    logAnalyticsEvent("emergency_requested", details: ["level": level])

    // Generate random ETA (3-10 minutes)
    let etaMinutes = Int.random(in: 3...10)

    // First message - Acknowledgment (immediate)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      guard let self = self else { return }
      let firstResponse = ChatMessage(
        id: UUID().uuidString,
        role: .assistant,
        content: "\(level.uppercased()) assistance has been requested.",
        timestamp: Date(),
        messageType: .emergency
      )
      self.items.append(.text(firstResponse))
    }

    // Second message - Request details (short delay)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
      guard let self = self else { return }
      let secondResponse = ChatMessage(
        id: UUID().uuidString,
        role: .assistant,
        content: "Please provide any details about your emergency.",
        timestamp: Date(),
        messageType: .emergency
      )
      self.items.append(.text(secondResponse))
    }

    // Third message - ETA information (longer delay)
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
      guard let self = self else { return }
      let thirdResponse = ChatMessage(
        id: UUID().uuidString,
        role: .assistant,
        content: "Help is on the way: ETA ~\(etaMinutes) mins.",
        timestamp: Date(),
        messageType: .emergency
      )
      self.items.append(.text(thirdResponse))
    }
  }

  func processImageSelection(items: [PhotosPickerItem]) {
    isLoadingImages = true
    selectedItems = items

    Task {
      // Create a local variable to collect images
      let loadedImages = await loadImages(from: items)

      // Move to main actor for UI updates with the final images array
      await MainActor.run {
        self.selectedImages = loadedImages
        self.isLoadingImages = false
        
        // Log image attachment event
        self.logAnalyticsEvent(
          "image_attached",
          details: [
            "count": "\(loadedImages.count)",
            "emergency_mode": "\(self.isEmergencyFlow)",
          ])
        
        // Images will be sent when user hits send button
      }
    }
  }
  
  /// Removes an image at the specified index from the selected images
  func removeImage(at index: Int) {
    if index >= 0 && index < selectedImages.count {
      selectedImages.remove(at: index)
    }
  }

  private func loadImages(from items: [PhotosPickerItem]) async -> [UIImage] {
    var images: [UIImage] = []

    for item in items {
      if let data = try? await item.loadTransferable(type: Data.self),
        let image = UIImage(data: data)
      {
        images.append(image)
      }
    }

    return images
  }

  func shouldShowChips(after item: ChatItem) -> Bool {
    guard case .text(let msg) = item, msg.role == .assistant else { return false }
    return items.count == 1 && items.first?.id == item.id
  }
  
  /// Determines if the cancel emergency chip should be shown after a message
  func shouldShowCancelChip(after item: ChatItem) -> Bool {
    // Only show cancel chip in emergency mode and after the last assistant message with emergency type
    if !isEmergencyFlow { return false }
    
    // Make sure this is a text item from the assistant with emergency message type
    guard case .text(let msg) = item, 
          msg.role == .assistant,
          msg.messageType == .emergency else { return false }
    
    // Find the last emergency message from the assistant
    if let lastEmergencyMsg = items.last(where: { 
      if case .text(let message) = $0, 
         message.role == .assistant, 
         message.messageType == .emergency {
        return true
      }
      return false
    }) {
      // Show the cancel chip after the last emergency message
      return lastEmergencyMsg.id == item.id
    }
    
    return false
  }
  
  /// Determines if the submit report chip should be shown after a message
  func shouldShowSubmitChip(after item: ChatItem) -> Bool {
    // Only show submit chip in normal mode 
    if isEmergencyFlow { return false }
    
    // Make sure this is a text item from the assistant
    guard case .text(let msg) = item, msg.role == .assistant else { return false }
    
    // We need at least 4 messages for a meaningful conversation:
    // 1. Assistant initial question
    // 2. User selects incident type
    // 3. Assistant asks for details
    // 4. User provides details
    let userMessagesCount = items.filter { 
      if case .text(let message) = $0, message.role == .user {
        return true
      }
      return false
    }.count
    
    // Only show submit option if user has provided at least one follow-up message after incident type
    if userMessagesCount < 2 {
      return false
    }
    
    // Set report as ready for submission now that we have sufficient context
    isReportReadyForSubmission = true
    
    // Find the last assistant message
    if let lastAssistantMsg = items.last(where: { 
      if case .text(let message) = $0, message.role == .assistant {
        return true
      }
      return false
    }) {
      // Show the submit chip after the last assistant message
      return lastAssistantMsg.id == item.id
    }
    
    return false
  }
  
  /// Determines if the view incidents chip should be shown after a message
  func shouldShowViewIncidentsChip(after item: ChatItem) -> Bool {
    // Only show when showViewIncidents flag is true
    if !showViewIncidents { return false }
    
    // Make sure this is a text item from the assistant
    guard case .text(let msg) = item, msg.role == .assistant else { return false }
    
    // Find the last assistant message
    if let lastAssistantMsg = items.last(where: { 
      if case .text(let message) = $0, message.role == .assistant {
        return true
      }
      return false
    }) {
      // Show the view incidents chip after the last assistant message
      return lastAssistantMsg.id == item.id
    }
    
    return false
  }

  func scrollToBottom(_ proxy: ScrollViewProxy) {
    if let lastItem = items.last {
      // Use animation to smooth the scrolling experience
      withAnimation {
        // Add a small delay to ensure all elements are rendered before scrolling
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          // Scroll to the last item with a bottom anchor, which provides better visibility
          proxy.scrollTo(lastItem.id, anchor: .bottom)
        }
      }
    }
  }

  /// Creates a report from the chat conversation
  func createReportFromChat() {
    // Extract information from the conversation
    var incidentType = "Incident"
    var userComments = [String]()
    var images = [UIImage]()
    var description = ""
    var location = ""
    var timestamp = Date()
    
    // Find the user's incident type selection - usually the first user message
    for item in items {
      if case .text(let msg) = item, msg.role == .user {
        incidentType = msg.content
        // Use timestamp of the first user message
        timestamp = msg.timestamp
        break
      }
    }
    
    // Collect other information
    for item in items {
      switch item {
      case .text(let msg) where msg.role == .user:
        userComments.append(msg.content)
        
        // Try to extract location from user messages
        if msg.content.lowercased().contains("at ") || 
           msg.content.lowercased().contains("in ") ||
           msg.content.lowercased().contains("location") {
          if location.isEmpty {
            // Simple heuristic - location might be mentioned after "in" or "at"
            if let locationIndex = msg.content.range(of: " in ", options: .caseInsensitive) {
              location = String(msg.content[locationIndex.upperBound...])
            } else if let locationIndex = msg.content.range(of: " at ", options: .caseInsensitive) {
              location = String(msg.content[locationIndex.upperBound...])
            }
          }
        }
        
        // Use second user message as description if not already set
        if description.isEmpty && msg.content != incidentType {
          description = msg.content
        }
        
      case .image(let imgs, _, _):
        images.append(contentsOf: imgs)
      default:
        break
      }
    }
    
    // Create a default title based on the incident type
    let title = "\(incidentType) Incident"
    
    // Create the report data
    let report = ReportData(
      title: title,
      description: description,
      location: location.isEmpty ? "Unknown Location" : location,
      timestamp: timestamp,
      status: .open,
      userComments: userComments,
      images: images
    )
    
    // Add message to introduce the report
    let introMessage = ChatMessage(
      id: UUID().uuidString,
      role: .assistant,
      content: "I've compiled an incident report based on your information:",
      timestamp: Date(),
      messageType: .chat
    )
    
    // Add the message and report to the chat
    items.append(.text(introMessage))
    items.append(.report(report))
    
    // Log report creation
    logAnalyticsEvent(
      "report_created",
      details: [
        "type": "standard",
        "incident_type": incidentType
      ]
    )
  }

  func submitReport() -> Bool {
    // First, create a report if one doesn't already exist
    if !items.contains(where: { if case .report = $0 { return true } else { return false } }) {
      // Use AI to generate the report from conversation
      generateReportFromChat()
      
      // Wait a moment to let report appear before showing success message
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
        self?.finalizeReportSubmission()
      }
    } else {
      // Report already exists, just finalize submission
      finalizeReportSubmission()
    }
    
    // Always return true to indicate successful handling
    return true
  }
  
  // MARK: - OpenAI Message History and Response
  
  /// Build message history for context
  private func buildMessageHistory() -> [ChatMessage] {
      // Convert ChatItems to ChatMessages for API consumption
      var history: [ChatMessage] = []
      
      for item in items {
          switch item {
          case .text(let message):
              history.append(message)
          case .image(_, _, let caption):
              if !caption.isEmpty {
                  // Add caption as a user message
                  let captionMsg = ChatMessage(
                      id: UUID().uuidString,
                      role: .user,
                      content: "Image caption: \(caption)",
                      timestamp: Date(),
                      messageType: .chat
                  )
                  history.append(captionMsg)
              }
          case .emergency(let level, _):
              // Convert emergency notification to a system message
              let emergencyMsg = ChatMessage(
                  id: UUID().uuidString,
                  role: .assistant,
                  content: "EMERGENCY: \(level.uppercased()) assistance requested",
                  timestamp: Date(),
                  messageType: .emergency
              )
              history.append(emergencyMsg)
          case .report:
              // Skip report items in the history
              continue
          }
      }
      
      return history
  }
  
  /// Get AI response using the OpenAI service
  func getAIResponse() {
      // Don't proceed if we're already processing
      guard !isProcessingAIResponse else { return }
      
      // Set processing flag
      isProcessingAIResponse = true
      
      // Show loading indicator right away
      addLoadingIndicator()
      
      // Build message history
      let messageHistory = buildMessageHistory()
      
      // Get images to include (if any)
      let imagesToInclude = selectedImages
      
      // Send request to OpenAI
      do {
          // Create OpenAI service instance
          let openAIService = try OpenAIService()
          
          // Use streaming for better UX
          openAIService.sendStreamingChatCompletion(
              messages: messageHistory,
              systemPrompt: currentSystemPrompt,
              functions: currentFunctionDefinitions,
              images: imagesToInclude,
              temperature: 0.7
          ) { [weak self] result in
              guard let self = self else { return }
              
              // Handle streaming results
              switch result {
              case .token(let text):
                  // Handle streamed tokens
                  self.handleStreamedToken(text)
                  
              case .functionCall(let name, let args):
                  // Handle function calls
                  self.handleFunctionCall(name, arguments: args)
                  
              case .error(let error):
                  // Handle errors
                  print("OpenAI error: \(error)")
                  DispatchQueue.main.async {
                      self.removeLoadingIndicator()
                      self.isProcessingAIResponse = false
                      self.addFallbackResponse()
                  }
                  
              case .done:
                  // Finalize response
                  DispatchQueue.main.async {
                      self.removeLoadingIndicator()
                      self.finalizeAIResponse()
                      self.isProcessingAIResponse = false
                  }
              }
          }
      } catch {
          // Handle service initialization error
          print("OpenAI service error: \(error)")
          removeLoadingIndicator()
          isProcessingAIResponse = false
          addFallbackResponse()
      }
  }
  
  /// Add loading indicator to show AI is typing
  private func addLoadingIndicator() {
      DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          // Check if we already have a loading indicator
          let hasLoadingIndicator = self.items.contains { item in
              if case .text(let msg) = item, msg.messageType == .loading {
                  return true
              }
              return false
          }
          
          // Only add if there isn't one already
          if !hasLoadingIndicator {
              let loadingMessage = ChatMessage(
                  id: "loading_\(UUID().uuidString)",
                  role: .assistant,
                  content: "Thinking...",
                  timestamp: Date(),
                  messageType: .loading
              )
              self.items.append(.text(loadingMessage))
          }
      }
  }
  
  /// Remove any loading indicators
  private func removeLoadingIndicator() {
      DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          // Find and remove loading indicators
          self.items.removeAll { item in
              if case .text(let msg) = item, msg.messageType == .loading {
                  return true
              }
              return false
          }
      }
  }
  
  /// Flag indicating if a report was submitted and view incidents is available
  @Published var showViewIncidents = false
  
  /// Finalize report submission with success messages
  private func finalizeReportSubmission() {
    // Find the latest report in the conversation
    var incidentReport: ReportData? = nil
    for item in items.reversed() {
      if case .report(let report, _) = item {
        incidentReport = report
        break
      }
    }
    
    // Add a success message to the chat
    let successMessage = ChatMessage(
      id: UUID().uuidString,
      role: .assistant,
      content: "Your incident report has been submitted successfully.",
      timestamp: Date(),
      messageType: .chat
    )
    items.append(.text(successMessage))
      
    // Second message - Prompt to view incidents
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      guard let self = self else { return }
      let secondResponse = ChatMessage(
        id: UUID().uuidString,
        role: .assistant,
        content: "You can view all incidents in the Incidents tab.",
        timestamp: Date(),
        messageType: .chat
      )
      self.items.append(.text(secondResponse))
      
      // Set flag to show view incidents chip
      self.showViewIncidents = true
    }

    // Log submission event with report details
    var details: [String: String] = [
      "message_count": "\(items.count)",
      "image_count": "\(selectedImages.count)",
      "emergency": "\(isEmergencyFlow)",
    ]
    
    if let report = incidentReport {
      details["title"] = report.title
      details["status"] = report.status.rawValue
      details["location"] = report.location
    }
    
    logAnalyticsEvent("report_submitted", details: details)
  }
  
  /// Navigate to incidents tab
  func viewIncidents() {
    restartChat()
    openIncidentsTab()
  }

  /// Restarts the chat to its initial state
  func restartChat() {
    // Log restart event
    logAnalyticsEvent(
      "chat_restarted",
      details: [
        "message_count": "\(items.count)",
        "image_count": "\(selectedImages.count)",
      ])

    // Reset to initial state
    items = [
      .text(
        ChatMessage(
          id: UUID().uuidString,
          role: .assistant,
          content: "Hi, I'm here to help. What kind of incident would you like to report?",
          timestamp: Date(),
          messageType: .chat
        ))
    ]
    inputText = ""
    selectedImages = []
    selectedItems = []
    isEmergencyFlow = false
    isReportReadyForSubmission = false
    showViewIncidents = false
  }

  /// Cancel the emergency and return to normal incident reporting
  func cancelEmergency() {
    // Dispatch to main queue to avoid view update conflicts
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      
      // Update model state
      self.isEmergencyFlow = false
      self.showCancelEmergencyConfirmation = false

      // Log the cancellation
      self.logAnalyticsEvent(
        "emergency_cancelled",
        details: [
          "message_count": "\(self.items.count)"
        ])
        
      // Create a report from the emergency with slight delay
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        guard let self = self else { return }
        self.createReportFromEmergency()
        
        // Add message about emergency being recorded
        let response = ChatMessage(
          id: UUID().uuidString,
          role: .assistant,
          content:
            "The emergency incident has been recorded on file. Please add any additional messages or images for context.",
          timestamp: Date(),
          messageType: .chat
        )
        
        // Add with slight delay to avoid view update conflicts
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          self.items.append(.text(response))
        }
      }
    }
  }
  
  /// Creates a report from an emergency incident
  private func createReportFromEmergency() {
    // Make a local copy of items to avoid concurrent modification issues
    let currentItems = self.items
    
    // First, extract emergency level from items
    var level = "Security"
    var userComments = [String]()
    var images = [UIImage]()
    var description = ""
    var location = ""
    var timestamp = Date()
    
    // Extract information from the conversation
    for item in currentItems {
      switch item {
      case .emergency(let emergencyLevel, _):
        level = emergencyLevel
      case .text(let msg) where msg.role == .user:
        userComments.append(msg.content)
        // Try to use first user message as description if not already set
        if description.isEmpty {
          description = msg.content
        }
        // Use timestamp of the first user message
        if timestamp == Date() {
          timestamp = msg.timestamp
        }
      case .image(let imgs, _, _):
        images.append(contentsOf: imgs)
      default:
        break
      }
    }
    
    // Create a default title based on the emergency type
    let title = "\(level) Emergency Incident"
    
    // Create the report data
    let report = ReportData(
      title: title,
      description: description,
      location: location.isEmpty ? "Unknown Location" : location,
      timestamp: timestamp,
      status: .inProgress,
      userComments: userComments,
      images: images
    )
    
    // Add message to introduce the report
    let introMessage = ChatMessage(
      id: UUID().uuidString,
      role: .assistant,
      content: "I've compiled an incident report based on your emergency:",
      timestamp: Date(),
      messageType: .chat
    )
    
    // Add items in a safe manner with delayed execution
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.items.append(.text(introMessage))
      
      // Small delay between updates to prevent view update conflicts
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
        guard let self = self else { return }
        self.items.append(.report(report))
        
        // Set flag to indicate report is ready for further updates
        self.isReportReadyForSubmission = true
      }
    }
    
    // Log report creation
    logAnalyticsEvent(
      "report_created",
      details: [
        "type": "emergency",
        "level": level
      ]
    )
  }

  // Analytics logging
  private func logAnalyticsEvent(_ event: String, details: [String: String] = [:]) {
    print("[ChatViewModel]: \(event) - \(details)")
  }
  
  // MARK: - Response Handling
  
  /// A flag to prevent creating duplicate streaming messages
  private var isCreatingMessage = false
  
  /// Static ID for the streaming message to ensure uniqueness
  private static let streamingMessageId = "stream_message"
  
  /// Handle streamed token from OpenAI
  private func handleStreamedToken(_ token: String) {
      // Add token to buffer
      responseBuffer += token
      
      // Only process on main thread to avoid threading issues
      DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          // If this is the first token, remove loading indicators
          if self.responseBuffer.count == token.count {
              self.removeLoadingIndicator()
          }
          
          // Check if we already have a streaming message
          let streamingMessage = self.findStreamingMessage()
          
          // If we have a streaming message, update it
          if let (index, _) = streamingMessage {
              // Update existing message with new content
              let updatedMsg = ChatMessage(
                  id: ChatViewModel.streamingMessageId,
                  role: .assistant,
                  content: self.responseBuffer,
                  timestamp: Date(),
                  messageType: self.isEmergencyFlow ? .emergency : .chat
              )
              
              // Replace at the same index
              self.items[index] = .text(updatedMsg)
          } else {
              // Only create a new message if we have content and don't already have one
              if !self.responseBuffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                 streamingMessage == nil {
                  // Create a new message with fixed ID
                  let newMessage = ChatMessage(
                      id: ChatViewModel.streamingMessageId,
                      role: .assistant,
                      content: self.responseBuffer,
                      timestamp: Date(),
                      messageType: self.isEmergencyFlow ? .emergency : .chat
                  )
                  
                  // Add new message
                  self.items.append(.text(newMessage))
              }
          }
      }
  }
  
  /// Find the current streaming message in the items array
  private func findStreamingMessage() -> (Int, ChatMessage)? {
      for (index, item) in items.enumerated() {
          if case .text(let msg) = item,
             msg.role == .assistant,
             msg.id == ChatViewModel.streamingMessageId {
              return (index, msg)
          }
      }
      return nil
  }
  
  /// Handle function call from OpenAI
  private func handleFunctionCall(_ name: String, arguments: [String: Any]) {
      // Special handling for argument chunks in streaming
      if name == "__args_chunk__", let chunk = arguments["chunk"] as? String {
          // Accumulate function arguments
          currentFunctionArgs += chunk
          return
      }
      
      // Initialize function name if this is first call
      if currentFunctionName.isEmpty {
          currentFunctionName = name
      }
      
      // Process complete function calls
      if !currentFunctionName.isEmpty && !currentFunctionArgs.isEmpty {
          // Try to parse accumulated arguments as JSON
          if let argsData = currentFunctionArgs.data(using: .utf8),
             let args = try? JSONSerialization.jsonObject(with: argsData) as? [String: Any] {
              // Process with complete arguments
              processFunctionCall(name: currentFunctionName, arguments: args)
          }
      }
  }
  
  /// Process completed function call
  private func processFunctionCall(name: String, arguments: [String: Any]) {
      DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          switch name {
          case "generateReport":
              self.handleGenerateReportFunction(arguments)
              
          case "setReportReadiness":
              if let isReady = arguments["isReady"] as? Bool {
                  self.isReportReadyForSubmission = isReady
              }
              
          case "suggestEmergency":
              if let suggest = arguments["suggest"] as? Bool,
                 let level = arguments["level"] as? String,
                 suggest {
                  self.showEmergencyOptions = true
              }
              
          default:
              print("Unknown function: \(name)")
          }
      }
  }
  
  /// Handle generateReport function call
  private func handleGenerateReportFunction(_ arguments: [String: Any]) {
      // Extract required fields
      guard let title = arguments["title"] as? String,
            let description = arguments["description"] as? String,
            let statusStr = arguments["status"] as? String
      else { return }
      
      // Extract optional fields with defaults
      let location = arguments["location"] as? String ?? "Unknown Location"
      
      // Map status string to enum
      let status: IncidentStatus
      switch statusStr.lowercased() {
      case "open": status = .open
      case "inprogress", "in_progress", "in progress": status = .inProgress
      case "resolved": status = .resolved
      default: status = isEmergencyFlow ? .inProgress : .open
      }
      
      // Collect user comments
      let userComments = items.compactMap { item -> String? in
          if case .text(let msg) = item, msg.role == .user {
              return msg.content
          }
          return nil
      }
      
      // Collect images
      let imageMessages = items.compactMap { item -> [UIImage]? in
          if case .image(let images, _, _) = item {
              return images
          }
          return nil
      }.flatMap { $0 }
      
      // Create report
      let report = ReportData(
          title: title,
          description: description,
          location: location,
          timestamp: Date(),
          status: status,
          userComments: userComments,
          images: imageMessages
      )
      
      // Add intro message
      let introMessage = ChatMessage(
          id: UUID().uuidString,
          role: .assistant,
          content: "I've compiled your report:",
          timestamp: Date(),
          messageType: .chat
      )
      self.items.append(.text(introMessage))
      
      // Add report to chat
      self.items.append(.report(report))
  }
  
  /// Finalize AI response after streaming is complete
  private func finalizeAIResponse() {
      // Process on main thread
      DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          
          // Find the streaming message with our consistent ID
          if let (streamingIndex, streamMsg) = self.findStreamingMessage() {
              // Make sure index is still valid
              guard streamingIndex < self.items.count else {
                  return
              }
              
              // Create a finalized message with a permanent ID
              let finalizedMsg = ChatMessage(
                  id: UUID().uuidString, // Regular ID for finalized message
                  role: streamMsg.role,
                  content: streamMsg.content,
                  timestamp: streamMsg.timestamp,
                  messageType: streamMsg.messageType
              )
              
              // Replace the streaming message with the finalized one
              self.items[streamingIndex] = .text(finalizedMsg)
          } else if !self.responseBuffer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
              // If somehow we have buffer content but no streaming message, create a new one
              let newMessage = ChatMessage(
                  id: UUID().uuidString,
                  role: .assistant,
                  content: self.responseBuffer,
                  timestamp: Date(),
                  messageType: self.isEmergencyFlow ? .emergency : .chat
              )
              self.items.append(.text(newMessage))
          }
          
          // Process any pending function calls
          if !self.currentFunctionName.isEmpty && !self.currentFunctionArgs.isEmpty {
              if let argsData = self.currentFunctionArgs.data(using: .utf8),
                 let args = try? JSONSerialization.jsonObject(with: argsData) as? [String: Any] {
                  // Use a slight delay to avoid conflicts with view updates
                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                      self.processFunctionCall(name: self.currentFunctionName, arguments: args)
                  }
              }
          }
          
          // Reset all streaming buffers
          self.responseBuffer = ""
          self.currentFunctionName = ""
          self.currentFunctionArgs = ""
      }
  }
  
  /// Add fallback response in case of errors
  private func addFallbackResponse() {
      // Reset any partial response buffer first
      responseBuffer = ""
      
      // Check if the last message is an empty assistant message
      if let lastIndex = items.indices.last,
         case .text(let lastMsg) = items[lastIndex],
         lastMsg.role == .assistant,
         lastMsg.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
         
         // Remove the empty message
         items.remove(at: lastIndex)
      }
      
      // Add fallback message
      let fallbackMessage = ChatMessage(
          id: UUID().uuidString,
          role: .assistant,
          content: "I apologize, but I couldn't process your request. Please try again.",
          timestamp: Date(),
          messageType: .chat
      )
      items.append(.text(fallbackMessage))
  }
  
  /// Generate a report from the conversation
  func generateReportFromChat() {
      // Don't proceed if already processing
      guard !isProcessingAIResponse else { return }
      
      // Set processing flag
      isProcessingAIResponse = true
      
      do {
          // Create OpenAI service instance
          let openAIService = try OpenAIService()
          
          // Extract all images from the conversation
          let allImages = items.compactMap { item -> [UIImage]? in
              if case .image(let images, _, _) = item {
                  return images
              }
              return nil
          }.flatMap { $0 }
          
          // Generate report
          openAIService.generateReport(
              from: buildMessageHistory(),
              incidentType: nil,
              isEmergency: isEmergencyFlow,
              images: allImages
          ) { [weak self] result in
              guard let self = self else { return }
              
              DispatchQueue.main.async {
                  self.isProcessingAIResponse = false
                  
                  switch result {
                  case .success(let report):
                      // Add intro message
                      let introMessage = ChatMessage(
                          id: UUID().uuidString,
                          role: .assistant,
                          content: "I've compiled your report based on our conversation:",
                          timestamp: Date(),
                          messageType: .chat
                      )
                      self.items.append(.text(introMessage))
                      
                      // Add the report
                      self.items.append(.report(report))
                      
                  case .failure(let error):
                      print("Report generation error: \(error)")
                      self.addFallbackResponse()
                  }
              }
          }
          
      } catch {
          // Handle service initialization error
          print("OpenAI service error: \(error)")
          isProcessingAIResponse = false
          addFallbackResponse()
      }
  }
}
