import SwiftUI

// MARK: - ImageBubble

/// A styled bubble for image upload messages that shows the actual images.
struct ImageBubble: View, Identifiable {
    // MARK: - Properties
    
    var id: String
    var images: [UIImage]
    var caption: String
    
    init(images: [UIImage], caption: String = "", id: String = UUID().uuidString) {
        self.images = images
        self.caption = caption
        self.id = id
    }
    
    // Support legacy constructor for preview purposes
    init(count: Int) {
        self.id = UUID().uuidString
        self.caption = ""
        
        var placeholders: [UIImage] = []
        if let placeholderImage = UIImage(systemName: "photo.fill") {
            for _ in 0..<count {
                placeholders.append(placeholderImage)
            }
        }
        self.images = placeholders
    }

    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Add caption if present
            if !caption.isEmpty {
                Text(caption)
                    .font(.body)
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
            }
            
            // Image grid layout
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 4),
                    GridItem(.flexible(), spacing: 4)
                ],
                spacing: 4
            ) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(uiImage: images[index])
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            
            // Add image count indicator
            HStack {
                Spacer()
                Text("\(images.count) image\(images.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(Color.blue.opacity(0.8))
        .cornerRadius(12)
        .padding(.horizontal, 12)
    }
}

// MARK: - Previews

struct ImageBubble_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // MARK: Light Mode Previews
            
            // Single image upload
            VStack(spacing: 16) {
                Text("Single Image Upload").font(.headline)
                ImageBubble(count: 1)
            }
            .padding()
            .background(Color("Background"))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Single Image - Light")
            
            // Multiple images
            VStack(spacing: 16) {
                Text("Multiple Images Upload").font(.headline)
                ImageBubble(count: 3)
                ImageBubble(count: 5)
            }
            .padding()
            .background(Color("Background"))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Multiple Images - Light")
            
            // MARK: Dark Mode Previews
            
            // Single image (dark)
            VStack(spacing: 16) {
                Text("Single Image Upload").font(.headline)
                ImageBubble(count: 1)
            }
            .padding()
            .background(Color("Background"))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Single Image - Dark")
            
            // Multiple images (dark)
            VStack(spacing: 16) {
                Text("Multiple Images Upload").font(.headline)
                ImageBubble(count: 3)
            }
            .padding()
            .background(Color("Background"))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Multiple Images - Dark")
            
            // MARK: Chat Context Previews
            
            // Light mode chat context
            VStack(spacing: 12) {
                ChatBubble(message: ChatMessage(
                    id: "msg1",
                    role: .user,
                    content: "Here are photos of the suspicious vehicle",
                    timestamp: Date(),
                    messageType: .chat
                ))
                ImageBubble(count: 2)
                ChatBubble(message: ChatMessage(
                    id: "response1",
                    role: .assistant,
                    content: "Thanks for the images. I can see it's a blue sedan. Can you confirm the license plate?",
                    timestamp: Date(),
                    messageType: .chat
                ))
            }
            .padding()
            .background(Color("Background"))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Chat Context - Light")
            
            // Dark mode chat context
            VStack(spacing: 12) {
                ChatBubble(message: ChatMessage(
                    id: "msg1",
                    role: .user,
                    content: "Here are photos of the suspicious vehicle",
                    timestamp: Date(),
                    messageType: .chat
                ))
                ImageBubble(count: 2)
                ChatBubble(message: ChatMessage(
                    id: "response1",
                    role: .assistant,
                    content: "Thanks for the images. I can see it's a blue sedan. Can you confirm the license plate?",
                    timestamp: Date(),
                    messageType: .chat
                ))
            }
            .padding()
            .background(Color("Background"))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Chat Context - Dark")
            
            // MARK: Emergency Context
            
            // Emergency context with image upload - light mode
            VStack(spacing: 12) {
                EmergencyBubble(level: "Security")
                ChatBubble(message: ChatMessage(
                    id: "msg1",
                    role: .user,
                    content: "Intruder on camera at east entrance",
                    timestamp: Date(),
                    messageType: .emergency
                ))
                ImageBubble(count: 1)
                ChatBubble(message: ChatMessage(
                    id: "response1",
                    role: .assistant,
                    content: "The image has been forwarded to emergency responders. ETA 3 minutes.",
                    timestamp: Date(),
                    messageType: .emergency
                ))
            }
            .padding()
            .background(Color("Background"))
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Emergency Context - Light")
            
            // Emergency context with image upload - dark mode
            VStack(spacing: 12) {
                EmergencyBubble(level: "Security")
                ChatBubble(message: ChatMessage(
                    id: "msg1",
                    role: .user,
                    content: "Intruder on camera at east entrance",
                    timestamp: Date(),
                    messageType: .emergency
                ))
                ImageBubble(count: 1)
                ChatBubble(message: ChatMessage(
                    id: "response1",
                    role: .assistant,
                    content: "The image has been forwarded to emergency responders. ETA 3 minutes.",
                    timestamp: Date(),
                    messageType: .emergency
                ))
            }
            .padding()
            .background(Color("Background"))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Emergency Context - Dark")
        }
    }
}
