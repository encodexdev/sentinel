import SwiftUI

/// A horizontal list of tappable suggestion chips.
struct SuggestionChips: View {
  let suggestions: [String]
  let onSelect: (String) -> Void

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(suggestions, id: \.self) { suggestion in
          Button(suggestion) {
            onSelect(suggestion)
          }
          .buttonStyle(.borderedProminent)
          .tint(Color("AccentBlue"))
        }
      }
      .padding(.horizontal, 12)
    }
  }
}
