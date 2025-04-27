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
    guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

    // Add user message
    let userMsg = ChatMessage(
      id: UUID().uuidString, role: .user, content: inputText, timestamp: Date(), messageType: .chat)
    items.append(.text(userMsg))
    let messageText = inputText  // Store the message text before clearing it
    inputText = ""

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

        // Create image message if images were loaded
        if !loadedImages.isEmpty {
          let _ = ChatMessage(imageUploadCount: loadedImages.count)
          self.items.append(.image(count: loadedImages.count))

          // Log image upload event
          self.logAnalyticsEvent(
            "image_uploaded",
            details: [
              "count": "\(loadedImages.count)",
              "emergency_mode": "\(self.isEmergencyFlow)",
            ])

          // If in emergency mode, send emergency-specific response for images
          if self.isEmergencyFlow {
            self.sendEmergencyResponseToImageUpload(imageCount: loadedImages.count)
          }
        }
      }
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

  func submitReport() -> Bool {
    // Package chat transcript and images into Report model
    // For now, just simulate and return success

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

    // Log submission event
    logAnalyticsEvent(
      "report_submitted",
      details: [
        "message_count": "\(items.count)",
        "image_count": "\(selectedImages.count)",
        "emergency": "\(isEmergencyFlow)",
      ])

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

  // Analytics logging
  private func logAnalyticsEvent(_ event: String, details: [String: String] = [:]) {
    print("[ChatViewModel]: \(event) - \(details)")
  }
}
