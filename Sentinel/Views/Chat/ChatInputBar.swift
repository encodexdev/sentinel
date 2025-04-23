import SwiftUI

struct ChatInputBar: View {
    @EnvironmentObject var vm: ChatViewModel
    @FocusState private var inputFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            Button { /* voice */ } label: {
                Image(systemName: "mic.fill")
                    .font(.title2)
                    .foregroundColor(Color("SecondaryText"))
            }
            TextField("Type your message…", text: $vm.inputText)
                .focused($inputFocused)
                .padding(8)
                .background(Color("Background"))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("DividerLine"), lineWidth: 1)
                )
            Button { vm.sendMessage() } label: {
                Image(systemName: "paperplane.fill")
                    .rotationEffect(.degrees(45))
                    .font(.title2)
                    .foregroundColor(Color("AccentBlue"))
            }
            .disabled(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        // Background handled globally
        .padding(.horizontal)
    }
}
