import SwiftUI
import PhotosUI

struct ChatInputBar: View {
    @EnvironmentObject var vm: ChatViewModel
    @FocusState private var inputFocused: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Image attachment preview
            if !vm.selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(0..<vm.selectedImages.count, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                // Image preview
                                Image(uiImage: vm.selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("DividerLine"), lineWidth: 1)
                                    )
                                
                                // Delete button
                                Button {
                                    vm.removeImage(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                        .background(
                                            Circle()
                                                .fill(Color.black.opacity(0.6))
                                                .frame(width: 18, height: 18)
                                        )
                                        .padding(2)
                                }
                                .offset(x: 3, y: -3)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 70)
            }
            
            // Input controls
            HStack(spacing: 12) {
                // Emergency button - only show in normal mode
                if !vm.isEmergencyFlow {
                    Button {
                        // Defer to the next run loop to avoid publishing during view updates
                        DispatchQueue.main.async {
                            vm.showEmergencyOptions = true
                        }
                    } label: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundColor(Color.red)
                    }
                    .disabled(vm.isProcessingAIResponse)
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
                Button {
                    // Defer to the next run loop to avoid publishing during view updates
                    DispatchQueue.main.async {
                        vm.sendMessage()
                    }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(.degrees(45))
                        .font(.title2)
                        .foregroundColor(
                            (!vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty || !vm.selectedImages.isEmpty) 
                            ? Color("AccentBlue") 
                            : Color("AccentBlue").opacity(0.5)
                        )
                }
                .disabled(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty && vm.selectedImages.isEmpty || vm.isProcessingAIResponse)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color("CardBackground"))
            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: -2)
                }
    }
}

// MARK: - Previews

struct ChatInputBar_Previews: PreviewProvider {
    static var normalViewModel: ChatViewModel {
        let vm = ChatViewModel()
        vm.inputText = "Type your message..."
        return vm
    }
    
    static var emergencyViewModel: ChatViewModel {
        let vm = ChatViewModel()
        vm.inputText = "The suspect is leaving through the east exit"
        vm.isEmergencyFlow = true
        return vm
    }
    
    static var imageViewModel: ChatViewModel {
        let vm = ChatViewModel()
        // Note: We can't add real images in preview, but we can simulate the UI
        let image = UIImage(systemName: "photo.fill")!
        vm.selectedImages = [image, image]
        return vm
    }
    
    static var previews: some View {
        Group {
            // Standard light mode
            VStack {
                Spacer()
                ChatInputBar()
            }
            .environmentObject(normalViewModel)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .previewDisplayName("Standard - Light")
            
            // Standard dark mode
            VStack {
                Spacer()
                ChatInputBar()
            }
            .environmentObject(normalViewModel)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .previewDisplayName("Standard - Dark")
            
            // Emergency mode
            VStack {
                Spacer()
                ChatInputBar()
            }
            .environmentObject(emergencyViewModel)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.light)
            .previewDisplayName("Emergency - Light")
            
            // Emergency dark mode
            VStack {
                Spacer()
                ChatInputBar()
            }
            .environmentObject(emergencyViewModel)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .previewDisplayName("Emergency - Dark")
            
            // With images attached
            VStack {
                Spacer()
                ChatInputBar()
            }
            .environmentObject(imageViewModel)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("With Images")
        }
    }
}
