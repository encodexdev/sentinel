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
    
    // Set report as ready for submission once an incident type is selected
    isReportReadyForSubmission = true

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

  func sendMessage() {
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

  func sendEmergencyMessage(level: String) {
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
    // Only show submit chip in normal mode when report is ready for submission
    if isEmergencyFlow || !isReportReadyForSubmission { return false }
    
    // Make sure this is a text item from the assistant
    guard case .text(let msg) = item, msg.role == .assistant else { return false }
    
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
      createReportFromChat()
    }
    
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
      
    // Second message - Request details (short delay)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
      guard let self = self else { return }
      let secondResponse = ChatMessage(
        id: UUID().uuidString,
        role: .assistant,
        content: "Redirecting to the incidents page...",
        timestamp: Date(),
        messageType: .chat
      )
      self.items.append(.text(secondResponse))
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

    // Navigate to the incidents tab after a short delay
    // to allow the user to see the success message
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
      self?.restartChat()
      self?.openIncidentsTab()
    }

    // In a real app, we would save this report to a database
    // and create an incident record. For now, we'll simulate success.
    return true
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
  }

  /// Cancel the emergency and return to normal incident reporting
  func cancelEmergency() {
    isEmergencyFlow = false
    showCancelEmergencyConfirmation = false

    // Log the cancellation
    logAnalyticsEvent(
      "emergency_cancelled",
      details: [
        "message_count": "\(items.count)"
      ])
      
    // Create a report from the emergency
    createReportFromEmergency()

    // Add message about emergency being recorded
    let response = ChatMessage(
      id: UUID().uuidString,
      role: .assistant,
      content:
        "The emergency incident has been recorded on file. Please add any additional messages or images for context.",
      timestamp: Date(),
      messageType: .chat
    )
    items.append(.text(response))
  }
  
  /// Creates a report from an emergency incident
  private func createReportFromEmergency() {
    // First, extract emergency level from items
    var level = "Security"
    var userComments = [String]()
    var images = [UIImage]()
    var description = ""
    var location = ""
    var timestamp = Date()
    
    // Extract information from the conversation
    for item in items {
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
    
    // Add the message and report to the chat
    items.append(.text(introMessage))
    items.append(.report(report))
    
    // Set flag to indicate report is ready for further updates
    isReportReadyForSubmission = true
    
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
}
