import SwiftUI

struct ChatView: View {
  @StateObject private var vm = ChatViewModel()

  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView {
          VStack(spacing: 12) {
            ForEach(vm.messages) { msg in
              ChatBubble(message: msg)
                .id(msg.id)
            }
          }
          .padding()
        }
        .onChange(of: vm.messages.count) { _ in
          if let last = vm.messages.last {
            proxy.scrollTo(last.id, anchor: .bottom)
          }
        }
      }

      // Input Bar
      HStack {
        TextField("Type a message…", text: $vm.inputText)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        Button(action: vm.sendMessage) {
          Image(systemName: "paperplane.fill")
            .rotationEffect(.degrees(45))
            .padding(.horizontal)
        }
        .disabled(vm.inputText.isEmpty)
      }
      .padding()
    }
    .navigationTitle("Report Incident")
  }
}
