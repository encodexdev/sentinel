import SwiftUI

struct SectionCard<Content: View>: View {
  let title: String
  let actionTitle: String?
  let action: (() -> Void)?
  let content: Content

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

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Text(title)
          .font(.headline)
        Spacer()
        if let actionTitle = actionTitle, let action = action {
          Button(action: action) {
            Text(actionTitle)
              .font(.subheadline)
          }
        }
      }
      .padding(.horizontal)

      VStack(spacing: 8) {
        content
      }
      .padding(.vertical, 8)
    }
    .background(Color("CardBackground"))
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 4)
  }
}
