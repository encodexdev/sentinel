import SwiftUI

struct ChatMessageList: View {
  @EnvironmentObject var vm: ChatViewModel

  // your sample incident types
  private let incidentTypes = ["Suspicious Person", "Theft", "Vandalism", "Other"]

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
              .padding(.top, 8)
            }
          }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
      }
      .onChange(of: vm.messages.count) { count in
        vm.scrollToBottom(proxy)
      }
    }
    // Global background handled by SentinelApp
  }
}
