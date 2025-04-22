import SwiftUI

enum AppearanceStyle: String, CaseIterable, Identifiable {
  case system = "System"
  case light = "Light"
  case dark = "Dark"

  var id: String { self.rawValue }

  var icon: String {
    switch self {
    case .system: return "circle.lefthalf.filled"
    case .light: return "sun.max.fill"
    case .dark: return "moon.stars.fill"
    }
  }

  var description: String {
    switch self {
    case .system: return "Follow device settings"
    case .light: return "Always light appearance"
    case .dark: return "Always dark appearance"
    }
  }

  var iconColor: Color {
    switch self {
    case .system: return Color("AccentBlue")
    case .light: return Color.orange
    case .dark: return Color.indigo
    }
  }

  func toColorScheme() -> ColorScheme? {
    switch self {
    case .system: return nil  // nil = follow system
    case .light: return .light
    case .dark: return .dark
    }
  }

  static func fromColorScheme(_ scheme: ColorScheme?) -> AppearanceStyle {
    switch scheme {
    case .none: return .system
    case .some(.light): return .light
    case .some(.dark): return .dark
    }
  }
}

struct AppearancePicker: View {
  @Binding var selection: AppearanceStyle
  @State private var isExpanded = false

  var body: some View {
    VStack(spacing: 0) {
      // Header/Button
      Button {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          isExpanded.toggle()
        }
      } label: {
        HStack {
          Label("Appearance", systemImage: "paintpalette.fill")
            .font(.subheadline).bold()
            .foregroundColor(Color("PrimaryText"))

          Spacer()

          HStack(spacing: 8) {
            Image(systemName: selection.icon)
              .foregroundColor(selection.iconColor)

            Text(selection.rawValue)
              .font(.callout)

            Image(systemName: "chevron.down")
              .font(.caption)
              .foregroundColor(Color("SecondaryText"))
              .rotationEffect(.degrees(isExpanded ? 180 : 0))
          }
          .foregroundColor(Color("SecondaryText"))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
      .background(Color("CardBackground"))
      .cornerRadius(12)
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color("Separator").opacity(0.3), lineWidth: 1)
      )

      // The dropdown menu
      if isExpanded {
        // Add a tap area that dismisses the menu when tapping outside
        ZStack(alignment: .top) {
          // First a full-screen clear area that dismisses when tapped
          Rectangle()
            .fill(Color.white.opacity(0.001))  // Nearly invisible but catches taps
            .onTapGesture {
              withAnimation {
                isExpanded = false
              }
            }

          // Then the actual dropdown on top
          dropdownContent
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(Color("CardBackground"))
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(Color("Separator").opacity(0.3), lineWidth: 1)
            )
            .offset(y: 5)
        }
        .transition(.opacity)
        .zIndex(1)  // This ensures it's above the header but below other content
      }
    }
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isExpanded)
  }

  private var dropdownContent: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(AppearanceStyle.allCases) { style in
        Button {
          withAnimation {
            selection = style
            isExpanded = false
          }
        } label: {
          HStack(spacing: 12) {
            Image(systemName: style.icon)
              .font(.headline)
              .foregroundColor(style.iconColor)
              .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
              Text(style.rawValue)
                .font(.body)
                .foregroundColor(Color("PrimaryText"))

              Text(style.description)
                .font(.caption)
                .foregroundColor(Color("SecondaryText"))
            }

            Spacer()

            if style == selection {
              Image(systemName: "checkmark")
                .foregroundColor(Color("AccentBlue"))
            }
          }
          .padding(.vertical, 12)
          .padding(.horizontal, 16)
          .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())

        if style != AppearanceStyle.allCases.last {
          Divider()
            .padding(.leading, 52)
            .padding(.trailing, 16)
        }
      }
    }
  }
}
