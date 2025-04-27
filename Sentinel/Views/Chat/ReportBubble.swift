import SwiftUI

// MARK: - ReportBubble

/// A chat bubble that displays an incident report with details and optional images
struct ReportBubble: View, Identifiable {
  // MARK: - Properties

  var id: String
  let report: ReportData

  init(report: ReportData, id: String = UUID().uuidString) {
    self.report = report
    self.id = id
  }

  // Colors for status badges
  private var statusColor: Color {
    switch report.status {
    case .open:
      return Color("StatusOpen")
    case .inProgress:
      return Color("StatusInProgress")
    case .resolved:
      return Color("StatusResolved")
    }
  }

  // MARK: - Body

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Report header
      HStack {
        Image(systemName: "doc.text.fill")
          .foregroundColor(Color("AccentBlue"))

        Text("Incident Report")
          .font(.headline)
          .foregroundColor(Color("PrimaryText"))

        Spacer()

        // Status badge
        Text(report.status.rawValue)
          .font(.caption)
          .fontWeight(.medium)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(statusColor.opacity(0.2))
          .foregroundColor(statusColor)
          .cornerRadius(12)
      }

      Divider()
        .background(Color("DividerLine"))

      // Report content
      VStack(alignment: .leading, spacing: 8) {
        // Title
        Text(report.title)
          .font(.headline)
          .foregroundColor(Color("PrimaryText"))

        // Description
        if !report.description.isEmpty {
          Text(report.description)
            .font(.body)
            .foregroundColor(Color("PrimaryText"))
        }

        // Location & Time
        HStack(spacing: 16) {
          // Location
          if !report.location.isEmpty {
            Label {
              Text(report.location)
                .font(.caption)
                .foregroundColor(Color("SecondaryText"))
            } icon: {
              Image(systemName: "mappin.circle.fill")
                .foregroundColor(Color("AccentOrange"))
            }
          }

          // Time
          Label {
            Text(report.timestamp, style: .time)
              .font(.caption)
              .foregroundColor(Color("SecondaryText"))
          } icon: {
            Image(systemName: "clock.fill")
              .foregroundColor(Color("AccentBlue"))
          }
        }
      }

      // Images if available
      if !report.images.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(0..<report.images.count, id: \.self) { index in
              Image(uiImage: report.images[index])
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                  RoundedRectangle(cornerRadius: 8)
                    .stroke(Color("DividerLine"), lineWidth: 1)
                )
            }
          }
          .padding(.vertical, 4)
        }
      }

      // User comments if available
      if !report.userComments.isEmpty {
        Divider()
          .background(Color("DividerLine"))

        VStack(alignment: .leading, spacing: 4) {
          Text("User Notes")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(Color("SecondaryText"))

          ForEach(report.userComments, id: \.self) { comment in
            Text(comment)
              .font(.caption)
              .foregroundColor(Color("SecondaryText"))
              .padding(.vertical, 2)
          }
        }
      }
    }
    .padding(12)
    .background(Color("CardBackground"))
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
  }
}

// MARK: - Previews

struct ReportBubble_Previews: PreviewProvider {
  static var sampleReport: ReportData {
    ReportData(
      title: "Suspicious Person in Parking Garage",
      description: "Individual attempting to open car doors on Level 2",
      location: "West Parking Garage",
      timestamp: Date(),
      status: .inProgress,
      userComments: [
        "I noticed someone checking car door handles",
        "Wearing a dark hoodie and jeans",
      ],
      images: [
        UIImage(systemName: "photo.fill")!,
        UIImage(systemName: "photo.fill")!,
      ]
    )
  }

  static var emptyReport: ReportData {
    ReportData(
      title: "Maintenance Required",
      description: "Broken light fixture in hallway",
      location: "East Wing, 3rd Floor",
      status: .open,
      userComments: [],
      images: []
    )
  }

  static var resolvedReport: ReportData {
    ReportData(
      title: "Unauthorized Access Attempt",
      description: "Someone tried to enter the server room without proper credentials",
      location: "IT Department",
      timestamp: Date().addingTimeInterval(-3600),
      status: .resolved,
      userComments: [
        "Security has been notified",
        "Badge access logs have been archived",
      ],
      images: [UIImage(systemName: "photo.fill")!]
    )
  }

  static var previews: some View {
    Group {
      // Standard report with images and comments - Light mode
      ReportBubble(report: sampleReport)
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Standard Report - Light")

      // Standard report with images and comments - Dark mode
      ReportBubble(report: sampleReport)
        .previewLayout(.sizeThatFits)
        .padding()
        .preferredColorScheme(.dark)
        .previewDisplayName("Standard Report - Dark")

      // Report without images or comments - Light mode
      ReportBubble(report: emptyReport)
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Minimal Report - Light")

      // Report with resolved status - Light mode
      ReportBubble(report: resolvedReport)
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Resolved Report - Light")

      // Report with resolved status - Dark mode
      ReportBubble(report: resolvedReport)
        .previewLayout(.sizeThatFits)
        .padding()
        .preferredColorScheme(.dark)
        .previewDisplayName("Resolved Report - Dark")
    }
  }
}
