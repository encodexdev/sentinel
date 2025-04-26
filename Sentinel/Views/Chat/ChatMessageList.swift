import SwiftUI

struct ChatMessageList: View {
  @EnvironmentObject var vm: ChatViewModel

  // your sample incident types
  private let incidentTypes = ["Suspicious Person", "Theft", "Vandalism", "Other"]

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(vm.items) { item in
            switch item {
            case .text(let msg):
              ChatBubble(message: msg)
                .id(item.id)
              if vm.shouldShowChips(after: item) {
                SuggestionChips(suggestions: incidentTypes) {
                  vm.selectIncidentType($0)
                }
                .padding(.top, 8)
              }
            case .emergency(let level, _):
              // Replace with your emergency bubble view
              EmergencyBubble(level: level)
                .id(item.id)
            case .image(let count, _):
              // Replace with your image bubble view
              ImageBubble(count: count)
                .id(item.id)
            }
          }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
      }
      .onChange(of: vm.items.count) {
        vm.scrollToBottom(proxy)
      }
    }
    // Global background handled by SentinelApp
  }
}
