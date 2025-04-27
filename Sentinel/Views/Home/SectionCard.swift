import SwiftUI

// MARK: - SectionCard

struct SectionCard<Content: View>: View {
  // MARK: - Properties
  
  /// Title displayed in the header of the card
  let title: String
  
  /// Optional action button title displayed in the header
  let actionTitle: String?
  
  /// Optional action executed when the action button is tapped
  let action: (() -> Void)?
  
  /// Content view to display inside the card
  let content: Content

  // MARK: - Initialization
  
  init(
    title: String,
    actionTitle: String? = nil,
    action: (() -> Void)? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.actionTitle = actionTitle
    self.action = action
    self.content = content()
  }

  // MARK: - Body
  
  var body: some View {
    VStack(spacing: 16) {  // Increased spacing between header and content
      // MARK: Card Header
      HStack {
        Text(title)
          .font(.headline)
        Spacer()
        if let actionTitle = actionTitle, let action = action {
          Button(action: action) {
            Text(actionTitle)
              .font(.subheadline)
              .foregroundColor(Color("AccentBlue"))
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 16)  // Added top padding

      // MARK: Card Content
      VStack(spacing: 12) {  // Increased spacing between content items
        content
      }
      .padding(.horizontal, 16)
      .padding(.bottom, 16)  // Explicit bottom padding
    }
    .background(Color("CardBackground"))
    .cornerRadius(16)
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 4)
  }
}
