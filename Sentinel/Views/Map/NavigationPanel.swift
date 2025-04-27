import SwiftUI
import MapKit
import LucideIcons

struct NavigationPanel: View {
  let navigationInfo: NavigationInfo
  let progress: Double
  let onCancel: () -> Void
  
  var body: some View {
    VStack(spacing: 12) {
      // Drag indicator
      Capsule()
        .frame(width: 40, height: 5)
        .foregroundColor(.gray.opacity(0.5))
      
      HStack(spacing: 16) {
        // ETA and distance
        VStack(alignment: .leading, spacing: 8) {
          // Case details
          Text("En route to incident")
            .font(.headline)
          
          // ETA section
          HStack(spacing: 12) {
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
            
            // Arrive by time
            VStack(alignment: .leading, spacing: 2) {
              Text("Arrive at")
                .font(.caption2)
                .foregroundColor(.gray)
              Text(navigationInfo.formattedETA)
                .font(.system(size: 14, weight: .medium))
            }
          }
          
          // Distance information
          HStack(spacing: 12) {
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
            
            // Reward
            VStack(alignment: .leading, spacing: 2) {
              Text("Reward")
                .font(.caption2)
                .foregroundColor(.gray)
              Text("$\(String(format: "%.2f", navigationInfo.fare))")
                .font(.system(size: 14, weight: .medium))
            }
          }
        }
        
        Spacer()
      }
      .padding(.horizontal, 8)
      
      // Progress indicator
      VStack(spacing: 4) {
        HStack {
          Text("Progress")
            .font(.caption)
          Spacer()
          Text("\(Int(progress * 100))%")
            .font(.caption)
        }
        
        ProgressView(value: progress, total: 1.0)
          .tint(.blue)
      }
      .padding(.horizontal, 8)
      
      // Cancel button
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