import SwiftUI

/// Tappable suggestion chips that automatically wrap to multiple lines if needed.
struct SuggestionChips: View {
  let suggestions: [String]
  let onSelect: (String) -> Void
  let emergencyOption: Bool
  let cancelEmergency: Bool
  let submitReport: Bool
  let viewIncidents: Bool
  let isPrimary: Bool
  
  // Initialize with various options
  init(
    suggestions: [String],
    emergencyOption: Bool = false,
    cancelEmergency: Bool = false,
    submitReport: Bool = false,
    viewIncidents: Bool = false,
    isPrimary: Bool = false,
    onSelect: @escaping (String) -> Void
  ) {
    self.suggestions = suggestions
    self.emergencyOption = emergencyOption
    self.cancelEmergency = cancelEmergency
    self.submitReport = submitReport
    self.viewIncidents = viewIncidents
    self.isPrimary = isPrimary
    self.onSelect = onSelect
  }

  // Spacing between chips
  private let horizontalSpacing: CGFloat = 8
  private let verticalSpacing: CGFloat = 8

  var body: some View {
    FlowLayout(
      horizontalSpacing: horizontalSpacing,
      verticalSpacing: verticalSpacing
    ) {
      // Emergency option if enabled
      if emergencyOption {
        Button {
          onSelect("Emergency")
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
              .font(.caption)
            Text("Emergency")
              .fontWeight(.medium)
          }
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.red)
      }
      
      // Cancel emergency option if enabled
      if cancelEmergency {
        Button {
          onSelect("Cancel Emergency")
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "xmark.circle.fill")
              .font(.caption)
            Text("Cancel Emergency")
              .fontWeight(.medium)
          }
        }
        .buttonStyle(.borderedProminent)
        .tint(Color.gray)
      }
      
      // Submit report option if enabled
      if submitReport {
        Button {
          onSelect("Submit Report")
        } label: {
          HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
              .font(.caption)
            Text("Submit Report")
              .fontWeight(.medium)
          }
        }
        .buttonStyle(.borderedProminent)
        .tint(Color("AccentOrange"))
      }
      
      // Regular suggestion chips
      ForEach(suggestions, id: \.self) { suggestion in
        Button(suggestion) {
          onSelect(suggestion)
        }
        .buttonStyle(.borderedProminent)
        .tint(isPrimary ? Color("AccentOrange") : Color("AccentBlue"))
      }
    }
    .padding(.horizontal, 12)
  }
}

// MARK: - Previews

struct SuggestionChips_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      // MARK: Light Mode Previews
      
      // Standard incident types
      VStack(alignment: .leading, spacing: 8) {
        Text("Incident Type").font(.headline)
        SuggestionChips(
          suggestions: ["Suspicious Person", "Theft", "Vandalism", "Other"]
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Standard - Light")
      
      // With emergency option
      VStack(alignment: .leading, spacing: 8) {
        Text("Incident Type with Emergency").font(.headline)
        SuggestionChips(
          suggestions: ["Suspicious Person", "Theft", "Vandalism", "Other"],
          emergencyOption: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .previewDisplayName("With Emergency - Light")
      
      // Cancel emergency option
      VStack(alignment: .leading, spacing: 8) {
        Text("Cancel Emergency Option").font(.headline)
        SuggestionChips(
          suggestions: [],
          cancelEmergency: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Cancel Emergency - Light")
      
      // Submit report option
      VStack(alignment: .leading, spacing: 8) {
        Text("Submit Report Option").font(.headline)
        SuggestionChips(
          suggestions: [],
          submitReport: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Submit Report - Light")
      
      // View incidents option
      VStack(alignment: .leading, spacing: 8) {
        Text("View Incidents Option").font(.headline)
        SuggestionChips(
          suggestions: ["View Incidents"],
          isPrimary: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .previewDisplayName("View Incidents - Light")
      
      // Longer list that wraps to multiple lines
      VStack(alignment: .leading, spacing: 8) {
        Text("Location").font(.headline)
        SuggestionChips(
          suggestions: [
            "Lobby", "Parking Garage", "East Wing", "West Wing", "Conference Room",
            "Cafeteria", "Break Room", "Executive Suite", "Server Room", "Roof Access"
          ],
          emergencyOption: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Multiple Lines - Light")
      
      // MARK: Dark Mode Previews
      
      // Standard incident types (dark)
      VStack(alignment: .leading, spacing: 8) {
        Text("Incident Type").font(.headline)
        SuggestionChips(
          suggestions: ["Suspicious Person", "Theft", "Vandalism", "Other"]
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .preferredColorScheme(.dark)
      .previewDisplayName("Standard - Dark")
      
      // With emergency option (dark)
      VStack(alignment: .leading, spacing: 8) {
        Text("Incident Type with Emergency").font(.headline)
        SuggestionChips(
          suggestions: ["Suspicious Person", "Theft", "Vandalism", "Other"],
          emergencyOption: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .preferredColorScheme(.dark)
      .previewDisplayName("With Emergency - Dark")
      
      // Cancel emergency option (dark)
      VStack(alignment: .leading, spacing: 8) {
        Text("Cancel Emergency Option").font(.headline)
        SuggestionChips(
          suggestions: [],
          cancelEmergency: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .preferredColorScheme(.dark)
      .previewDisplayName("Cancel Emergency - Dark")
      
      // Submit report option (dark)
      VStack(alignment: .leading, spacing: 8) {
        Text("Submit Report Option").font(.headline)
        SuggestionChips(
          suggestions: [],
          submitReport: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .preferredColorScheme(.dark)
      .previewDisplayName("Submit Report - Dark")
      
      // View incidents option (dark)
      VStack(alignment: .leading, spacing: 8) {
        Text("View Incidents Option").font(.headline)
        SuggestionChips(
          suggestions: ["View Incidents"],
          isPrimary: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("CardBackground"))
      .previewLayout(.sizeThatFits)
      .preferredColorScheme(.dark)
      .previewDisplayName("View Incidents - Dark")
      
      // MARK: Chat Context Previews
      
      // Light mode chat context
      VStack(spacing: 12) {
        ChatBubble(message: ChatMessage(
          id: "assistant1",
          role: .assistant,
          content: "What type of incident would you like to report?",
          timestamp: Date(),
          messageType: .chat
        ))
        
        SuggestionChips(
          suggestions: ["Suspicious Person", "Theft", "Vandalism", "Other"],
          emergencyOption: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("Background"))
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Chat Context - Light")
      
      // Dark mode chat context
      VStack(spacing: 12) {
        ChatBubble(message: ChatMessage(
          id: "assistant1",
          role: .assistant,
          content: "What type of incident would you like to report?",
          timestamp: Date(),
          messageType: .chat
        ))
        
        SuggestionChips(
          suggestions: ["Suspicious Person", "Theft", "Vandalism", "Other"],
          emergencyOption: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("Background"))
      .previewLayout(.sizeThatFits)
      .preferredColorScheme(.dark)
      .previewDisplayName("Chat Context - Dark")
      
      // Emergency mode with cancel option
      VStack(spacing: 12) {
        ChatBubble(message: ChatMessage(
          id: "emergency1",
          role: .assistant,
          content: "Help is on the way: ETA ~5 mins.",
          timestamp: Date(),
          messageType: .emergency
        ))
        
        SuggestionChips(
          suggestions: [],
          cancelEmergency: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("Background"))
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Emergency Cancel - Light")
      
      // Emergency mode with cancel option (dark)
      VStack(spacing: 12) {
        ChatBubble(message: ChatMessage(
          id: "emergency1",
          role: .assistant,
          content: "Help is on the way: ETA ~5 mins.",
          timestamp: Date(),
          messageType: .emergency
        ))
        
        SuggestionChips(
          suggestions: [],
          cancelEmergency: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("Background"))
      .previewLayout(.sizeThatFits)
      .preferredColorScheme(.dark)
      .previewDisplayName("Emergency Cancel - Dark")
      
      // View incidents after report submission
      VStack(spacing: 12) {
        ChatBubble(message: ChatMessage(
          id: "report1",
          role: .assistant,
          content: "Your incident report has been submitted successfully. You can view all incidents in the Incidents tab.",
          timestamp: Date(),
          messageType: .chat
        ))
        
        SuggestionChips(
          suggestions: ["View Incidents"],
          isPrimary: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("Background"))
      .previewLayout(.sizeThatFits)
      .previewDisplayName("Report Submitted - Light")
      
      // View incidents after report submission (dark mode)
      VStack(spacing: 12) {
        ChatBubble(message: ChatMessage(
          id: "report1",
          role: .assistant,
          content: "Your incident report has been submitted successfully. You can view all incidents in the Incidents tab.",
          timestamp: Date(),
          messageType: .chat
        ))
        
        SuggestionChips(
          suggestions: ["View Incidents"],
          isPrimary: true
        ) { selection in
          print("Selected: \(selection)")
        }
      }
      .padding()
      .background(Color("Background"))
      .previewLayout(.sizeThatFits)
      .preferredColorScheme(.dark)
      .previewDisplayName("Report Submitted - Dark")
    }
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

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
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
