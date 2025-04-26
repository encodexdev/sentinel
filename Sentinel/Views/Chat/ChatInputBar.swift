import SwiftUI
import PhotosUI

struct ChatInputBar: View {
    @EnvironmentObject var vm: ChatViewModel
    @FocusState private var inputFocused: Bool
    @State private var showingEmergencyOptions = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Image attachment preview
            if !vm.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<vm.selectedImages.count, id: \.self) { index in
                            Image(uiImage: vm.selectedImages[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("DividerLine"), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 70)
            }
            
            // Input controls
            HStack(spacing: 12) {
                // Emergency button
                Button {
                    showingEmergencyOptions = true
                } label: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(Color.red)
                }
                .confirmationDialog(
                    "Request Emergency Assistance",
                    isPresented: $showingEmergencyOptions,
                    titleVisibility: .visible
                ) {
                    Button("Police", role: .destructive) {
                        vm.sendEmergencyMessage(level: "Police")
                    }
                    Button("Security", role: .destructive) {
                        vm.sendEmergencyMessage(level: "Security")
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Emergency services will be contacted immediately")
                }
                
                // Photo picker button
                PhotosPicker(selection: $vm.selectedItems, matching: .images) {
                    Image(systemName: "photo.fill")
                        .font(.title2)
                        .foregroundColor(Color("SecondaryText"))
                }
                .onChange(of: vm.selectedItems) {
                    vm.processImageSelection(items: vm.selectedItems)
                }
                
                // Text input field
                TextField("Type your message…", text: $vm.inputText)
                    .focused($inputFocused)
                    .padding(8)
                    .background(Color("Background"))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("DividerLine"), lineWidth: 1)
                    )
                
                // Send button
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
            .background(Color("CardBackground"))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color("DividerLine"))
                    .offset(y: -4),
                alignment: .top
            )
        }
    }
}
