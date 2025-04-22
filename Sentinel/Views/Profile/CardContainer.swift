import SwiftUI

struct CardContainer<Content: View>: View {
  let content: Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    content
      .padding()
      .background(Color("CardBackground"))
      .cornerRadius(12)
      .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 4)
      .padding(.horizontal)
  }
}
