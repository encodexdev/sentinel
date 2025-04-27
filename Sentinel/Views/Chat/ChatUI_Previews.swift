import SwiftUI
import UIKit

/// Special preview for showing the Chat UI in different states
struct ChatUI_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Initial Chat UI with suggestion chips
            ChatUIPreview()
                .previewDisplayName("Chat UI with Suggestions")
            
            // Conversation preview with toolbar items
            NavigationStack {
                VStack(spacing: 0) {
                    ChatMessageList()
                    ChatInputBar()
                }
                .navigationTitle("Report Incident")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Restart") { }
                        .foregroundColor(.blue)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Submit") { }
                        .fontWeight(.bold)
                    }
                }
            }
            .environmentObject(ChatUIPreview.conversationViewModel)
            .previewDisplayName("Conversation")
            
            // Input Bar Only Preview
            ChatInputBarPreview()
                .previewDisplayName("Input Bar")
                .previewLayout(.sizeThatFits)
        }
    }
}

/// Complete chat UI preview
struct ChatUIPreview: View {
    static var viewModel: ChatViewModel {
        let vm = ChatViewModel()
        
        // Add just the initial message to show chips
        vm.items = [
            .text(ChatMessage(
                id: "1",
                role: .assistant,
                content: "What type of incident would you like to report?",
                timestamp: Date(),
                messageType: .chat
            ))
        ]
        
        return vm
    }
    
    static var conversationViewModel: ChatViewModel {
        let vm = ChatViewModel()
        
        // Add a full conversation
        vm.items = [
            .text(ChatMessage(
                id: "1",
                role: .assistant,
                content: "What type of incident would you like to report?",
                timestamp: Date().addingTimeInterval(-120),
                messageType: .chat
            )),
            .text(ChatMessage(
                id: "2",
                role: .user,
                content: "I saw someone suspicious entering through the back door",
                timestamp: Date().addingTimeInterval(-60),
                messageType: .chat
            )),
            .text(ChatMessage(
                id: "3",
                role: .assistant,
                content: "Can you describe what makes this person suspicious?",
                timestamp: Date(),
                messageType: .chat
            ))
        ]
        
        return vm
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ChatMessageList()
                ChatInputBar()
            }
            .navigationTitle("Report Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") { }
                        .fontWeight(.bold)
                }
            }
        }
        .environmentObject(ChatUIPreview.viewModel)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

/// Preview focused on the input bar
struct ChatInputBarPreview: View {
    static var viewModel: ChatViewModel {
        let vm = ChatViewModel()
        vm.inputText = "Type your message..."
        return vm
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Tab Bar-inspired footer
                VStack(spacing: 0) {
                    // Chat Input Bar
                    ChatInputBar()
                    
                    // Custom Tab Bar underneath
                    HStack(spacing: 0) {
                        TabButton(icon: "house", label: "Home", isSelected: false)
                        TabButton(icon: "text.badge.plus", label: "Report", isSelected: true)
                        TabButton(icon: "map", label: "Map", isSelected: false)
                        TabButton(icon: "list.clipboard", label: "Incidents", isSelected: false)
                    }
                    .padding(.top, 1) // Add a tiny bit of padding to separate from input
                    .background(Color("CardBackground"))
                }
                // Shadow for the whole bottom section
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
            }
        }
        .frame(height: 180)
        .environmentObject(ChatInputBarPreview.viewModel)
    }
}

/// Helper component for tab buttons in preview
struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? Color("AccentBlue") : Color("SecondaryText"))
            
            Text(label)
                .font(.caption)
                .foregroundColor(isSelected ? Color("AccentBlue") : Color("SecondaryText"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}