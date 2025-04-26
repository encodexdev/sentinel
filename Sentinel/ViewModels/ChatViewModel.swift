import Foundation
import SwiftUI
import Combine
import PhotosUI

final class ChatViewModel: ObservableObject {
    @Published var items: [ChatItem] = [
        .text(ChatMessage(
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
    private var isEmergencyFlow = false
    
    func selectIncidentType(_ type: String) {
        // Add user selection
        let userMsg = ChatMessage(id: UUID().uuidString, role: .user, content: type, timestamp: Date(), messageType: .chat)
        items.append(.text(userMsg))
        
        // Add assistant response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            let response = ChatMessage(id: UUID().uuidString, role: .assistant, content: "Thanks for reporting a \(type) incident. Can you describe what happened?", timestamp: Date(), messageType: .chat)
            self.items.append(.text(response))
        }
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Add user message
        let userMsg = ChatMessage(id: UUID().uuidString, role: .user, content: inputText, timestamp: Date(), messageType: .chat)
        items.append(.text(userMsg))
        inputText = ""
        
        // Simulate assistant response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let response = ChatMessage(id: UUID().uuidString, role: .assistant, content: "I've recorded your report. Is there anything else you'd like to add?", timestamp: Date(), messageType: .chat)
            self.items.append(.text(response))
        }
    }
    
    func sendEmergencyMessage(level: String) {
        isEmergencyFlow = true
        
        // Create emergency-typed message
        let emergencyMsg = ChatMessage(emergencyLevel: level)
        
        items.append(.emergency(level: level))
        
        // Simulate emergency response (faster than normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            let response = ChatMessage(
                id: UUID().uuidString,
                role: .assistant,
                content: "EMERGENCY MODE: \(level.uppercased()) assistance has been requested. Help is on the way. Please provide any additional details about your emergency.",
                timestamp: Date(),
                messageType: .emergency
            )
            self.items.append(.text(response))
            
            // Log emergency event (would connect to analytics in production)
            self.logAnalyticsEvent("emergency_requested", details: ["level": level])
        }
    }
    
    func processImageSelection(items: [PhotosPickerItem]) {
        isLoadingImages = true
        selectedItems = items
        
        Task {
            var newImages: [UIImage] = []
            
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    newImages.append(image)
                }
            }
            
            await MainActor.run {
                selectedImages = newImages
                isLoadingImages = false
                
                // Create image message if images were loaded
                if !newImages.isEmpty {
                    let msg = ChatMessage(imageUploadCount: newImages.count)
                    self.items.append(.image(count: newImages.count))
                    
                    // Log image upload event
                    self.logAnalyticsEvent("image_uploaded", details: ["count": "\(newImages.count)"])
                }
            }
        }
    }
    
    func shouldShowChips(after item: ChatItem) -> Bool {
        guard case .text(let msg) = item, msg.role == .assistant else { return false }
        return items.count == 1 && items.first?.id == item.id
    }
    
    func scrollToBottom(_ proxy: ScrollViewProxy) {
        if let lastItem = items.last {
            proxy.scrollTo(lastItem.id, anchor: .bottom)
        }
    }
    
    func submitReport() -> Bool {
        // Package chat transcript and images into Report model
        // For now, just simulate and return success
        
        // Log submission event
        logAnalyticsEvent("report_submitted", details: [
            "message_count": "\(items.count)",
            "image_count": "\(selectedImages.count)",
            "emergency": "\(isEmergencyFlow)"
        ])
        
        return true
    }
    
    // Analytics logging
    private func logAnalyticsEvent(_ event: String, details: [String: String] = [:]) {
        print("[ChatViewModel]: \(event) - \(details)")
    }
}
