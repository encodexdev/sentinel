import Foundation
import SwiftUI
import Combine

final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(id: UUID().uuidString, sender: .assistant, content: "Hi, I'm here to help. What kind of incident would you like to report?",  timestamp: Date())
    ]
    @Published var inputText: String = ""
    
    func selectIncidentType(_ type: String) {
        // Add user selection
        let userMsg = Message(id: UUID().uuidString, sender: .user, content: type, timestamp: Date())
        messages.append(userMsg)
        
        // Add assistant response
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            let response = Message(id: UUID().uuidString, sender: .assistant, content: "Thanks for reporting a \(type) incident. Can you describe what happened?", timestamp: Date())
            self.messages.append(response)
        }
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Add user message
        let userMsg = Message(id: UUID().uuidString, sender: .user, content: inputText, timestamp: Date())
        messages.append(userMsg)
        inputText = ""
        
        // Simulate assistant response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            let response = Message(id: UUID().uuidString, sender: .assistant, content: "I've recorded your report. Is there anything else you'd like to add?", timestamp: Date())
            self.messages.append(response)
        }
    }
    
    func shouldShowChips(after msg: Message) -> Bool {
        // Show chips after first assistant message only
        guard msg.sender == .assistant else { return false }
        return messages.count == 1 && messages.first?.id == msg.id
    }
    
    func scrollToBottom(_ proxy: ScrollViewProxy) {
        if let lastMessage = messages.last {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
        }
    }
}