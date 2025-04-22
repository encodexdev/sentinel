import SwiftUI

struct ChatMessageList: View {
    @EnvironmentObject var vm: ChatViewModel
    
    // your sample incident types
    private let incidentTypes = ["Suspicious Person","Theft","Vandalism","Other"]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(vm.messages) { msg in
                        ChatBubble(message: msg)
                            .id(msg.id)
                        if vm.shouldShowChips(after: msg) {
                            SuggestionChips(suggestions: incidentTypes) {
                                vm.selectIncidentType($0)
                            }
                            .padding(.bottom, 8)
                        }
                    }
                }
                .padding(.vertical)
            }
            .onChange(of: vm.messages.count) { count in
                vm.scrollToBottom(proxy)
            }
        }
        .background(Color("Background"))
    }
}
