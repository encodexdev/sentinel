import SwiftUI

/// Tappable suggestion chips that automatically wrap to multiple lines if needed.
struct SuggestionChips: View {
  let suggestions: [String]
  let onSelect: (String) -> Void
  
  // Spacing between chips
  private let horizontalSpacing: CGFloat = 8
  private let verticalSpacing: CGFloat = 8

  var body: some View {
    FlowLayout(
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing
    ) {
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

/// A custom flow layout that automatically wraps content to multiple rows
struct FlowLayout: Layout {
  let horizontalSpacing: CGFloat
  let verticalSpacing: CGFloat
  
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let containerWidth = proposal.width ?? .infinity
    
    let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
    var position = CGPoint.zero
    var maxHeight: CGFloat = 0
    
    // Calculate positions and find total height
    for (_, size) in sizes.enumerated() {
      // If this subview doesn't fit on current line, move to next line
      if position.x + size.width > containerWidth && position.x > 0 {
        position.x = 0
        position.y += maxHeight + verticalSpacing
        maxHeight = 0
      }
      
      // Update position for next item
      position.x += size.width + horizontalSpacing
      maxHeight = max(maxHeight, size.height)
    }
    
    // Total height is the last row's position plus its height
    let totalHeight = position.y + maxHeight
    
    return CGSize(width: containerWidth, height: totalHeight)
  }
  
  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
    
    var position = CGPoint(x: bounds.minX, y: bounds.minY)
    var maxHeight: CGFloat = 0
    
    // Place each subview
    for (index, subview) in subviews.enumerated() {
      let size = sizes[index]
      
      // Move to next line if this subview doesn't fit
      if position.x + size.width > bounds.maxX && position.x > bounds.minX {
        position.x = bounds.minX
        position.y += maxHeight + verticalSpacing
        maxHeight = 0
      }
      
      // Place the subview
      subview.place(
        at: CGPoint(x: position.x, y: position.y),
        proposal: ProposedViewSize(size)
      )
      
      // Move position and track max height
      position.x += size.width + horizontalSpacing
      maxHeight = max(maxHeight, size.height)
    }
  }
}
