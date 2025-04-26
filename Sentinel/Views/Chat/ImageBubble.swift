import SwiftUI

/// A styled bubble for image upload messages.
struct ImageBubble: View, Identifiable {
    let id = UUID().uuidString
    let count: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.title2)
                .foregroundColor(.white)

            Text("Uploaded \(count) image\(count == 1 ? "" : "s")")
                .font(.body)
                .foregroundColor(.white)

            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.8))
        .cornerRadius(12)
        .padding(.horizontal, 12)
    }
}

struct ImageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ImageBubble(count: 1)
            ImageBubble(count: 3)
        }
        .background(Color.black.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
