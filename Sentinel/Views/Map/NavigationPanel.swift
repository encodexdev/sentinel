import LucideIcons
import MapKit
import SwiftUI

// MARK: - NavigationPanel

struct NavigationPanel: View {
  // MARK: - Properties

  /// Navigation information to display
  let navigationInfo: NavigationInfo

  /// Current navigation progress (0.0 to 1.0)
  let progress: Double

  /// Action to perform when navigation is canceled
  let onCancel: () -> Void

  // MARK: - Body

  var body: some View {
    VStack(spacing: 12) {
      Capsule()
        .frame(width: 40, height: 5)
        .foregroundColor(.gray.opacity(0.5))

      HStack(spacing: 16) {
        // MARK: Navigation Info
          VStack(alignment: .leading, spacing: 16) {
              Text("En route to \(navigationInfo.incident.title)")
                  .font(.headline)
              
              HStack(spacing: 16) {
                  // ETA
                  HStack(spacing: 4) {
                      // ETA icon
                      Image(uiImage: Lucide.clock.withRenderingMode(.alwaysTemplate))
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(width: 18, height: 18)
                          .foregroundColor(.blue)
                      
                      // ETA info
                      VStack(alignment: .leading, spacing: 2) {
                          Text("ETA")
                              .font(.caption2)
                              .foregroundColor(.gray)
                          Text("\(navigationInfo.etaMinutes) min")
                              .font(.system(size: 14, weight: .medium))
                      }
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  
                  // Distance
                  HStack(spacing: 4) {
                      // Distance icon
                      Image(uiImage: Lucide.mapPin.withRenderingMode(.alwaysTemplate))
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(width: 18, height: 18)
                          .foregroundColor(.orange)
                      
                      // Distance
                      VStack(alignment: .leading, spacing: 2) {
                          Text("Distance")
                              .font(.caption2)
                              .foregroundColor(.gray)
                          Text(navigationInfo.formattedDistance)
                              .font(.system(size: 14, weight: .medium))
                      }
                  }
                  .frame(maxWidth: .infinity)
                  
                  // Reward
                  HStack(spacing: 4) {
                      Image(uiImage: Lucide.circleDollarSign.withRenderingMode(.alwaysTemplate))
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(width: 18, height: 18)
                          .foregroundColor(.green)
                      Text("$\(String(format: "%.2f", navigationInfo.fare))")
                          .font(.system(size: 14, weight: .medium))
                  }
                  .frame(maxWidth: .infinity, alignment: .trailing)
              }
              .padding(.horizontal, 8)
          }

        Spacer()
      }
      .padding(.horizontal, 8)
        


      // MARK: Cancel Button
      Button(action: onCancel) {
        HStack {
          Image(uiImage: Lucide.x.withRenderingMode(.alwaysTemplate))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 16, height: 16)

          Text("CANCEL NAVIGATION")
            .fontWeight(.medium)
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.2))
        .foregroundColor(.red)
        .cornerRadius(8)
      }
      .padding(.top, 4)
    }
    .padding()
    .background(.ultraThinMaterial)
    .cornerRadius(16)
    .shadow(radius: 5)
    .padding(.horizontal, 16)
  }
}

// MARK: - Previews

#Preview {
  ZStack {
    // Background for contrast
    Color.gray.opacity(0.2)

    // Preview different progress states in vertical stack
    VStack(spacing: 40) {
      // Just started navigation
      NavigationPanel(
        navigationInfo: createSampleNavInfo(),
        progress: 0.1,
        onCancel: {}
      )

      // Halfway there
      NavigationPanel(
        navigationInfo: createSampleNavInfo(minutes: 8),
        progress: 0.5,
        onCancel: {}
      )

      // Almost arrived
      NavigationPanel(
        navigationInfo: createSampleNavInfo(minutes: 2),
        progress: 0.9,
        onCancel: {}
      )
    }
    .padding(.vertical, 40)
  }
  .ignoresSafeArea()
}

// Helper function to create sample navigation info for previews
private func createSampleNavInfo(minutes: Int = 15) -> NavigationInfo {
  let sampleIncident = IncidentAnnotation(
    id: "preview-123",
    title: "Medical Emergency",
    coordinate: CLLocationCoordinate2D(latitude: 37.785, longitude: -122.405),
    status: .open
  )

  return NavigationInfo(
    incident: sampleIncident,
    etaMinutes: minutes,
    distance: Measurement(value: 2.482, unit: .kilometers),
    fare: 45.75
  )
}
