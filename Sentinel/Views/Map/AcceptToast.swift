import LucideIcons
import MapKit
import SwiftUI

// MARK: - AcceptToast

struct AcceptToast: View {
  // MARK: - Properties

  let incident: IncidentAnnotation
  let onAccept: () -> Void
  let onTimeout: () -> Void

  @State private var sliderValue: Double = 0.0
  @State private var timer: Timer?
  @State private var toastOpacity: Double = 0

  /// Store fare as a state so it remains constant during the toast lifetime
  @State private var fare: Double
  
  init(incident: IncidentAnnotation, onAccept: @escaping () -> Void, onTimeout: @escaping () -> Void) {
    self.incident = incident
    self.onAccept = onAccept
    self.onTimeout = onTimeout
    // Pre-calculate the fare so it's included in the initial animation
    _fare = State(initialValue: Double.random(in: 30...60))
  }

  // MARK: - Body

  var body: some View {
    VStack(spacing: 12) {
      // MARK: Drag Indicator
      Capsule()
        .frame(width: 40, height: 5)
        .foregroundColor(.gray.opacity(0.5))

      // MARK: Incident Details
      Text("Emergency Detected Nearby")
        .font(.headline)
        .foregroundColor(.red)
        
      Text("Type: \(incident.title.isEmpty ? "Unknown" : incident.title)")
        .font(.subheadline)

      Text("Reward: $\(String(format: "%.2f", fare))")
        .font(.title2).bold()

      HStack {
        Text("Time remaining")
          .font(.caption)
        Spacer()
        Text("\(Int(sliderValue * 10))s")
          .font(.caption)
      }

      // MARK: Progress Bar
      ProgressView(value: sliderValue, total: 1.0)
        .padding(.vertical, 4)
        .tint(.accentOrange)

      // MARK: Accept Button
      Button(action: accept) {
        HStack {
          Image(uiImage: Lucide.navigation.withRenderingMode(.alwaysTemplate))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)

          Text("ACCEPT & RESPOND")
            .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.accentOrange)
        .foregroundColor(.white)
        .cornerRadius(10)
      }
    }
    .padding()
    .background(.ultraThinMaterial)
    .cornerRadius(16)
    .shadow(radius: 10)
    .padding(.horizontal, 16)
    .onAppear {
      // Animate the toast in with a smooth fade
      withAnimation(.easeOut(duration: 0.8)) {
        toastOpacity = 1.0
      }
      startTimer()
    }
  }

  // MARK: - Helper Methods

  private func startTimer() {
    timer?.invalidate()
    sliderValue = 1.0
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
      sliderValue -= 0.01
      if sliderValue <= 0 {
        t.invalidate()
        onTimeout()
      }
    }
  }

  private func accept() {
    timer?.invalidate()
    onAccept()
  }
}

// MARK: - Previews

#Preview {
  ZStack {
    // Background to simulate map
    Color.gray.opacity(0.2)
    
    VStack(spacing: 30) {
      // With default timer values
      AcceptToast(
        incident: IncidentAnnotation(
          id: "preview-123",
          title: "Shoplifting",
          coordinate: CLLocationCoordinate2D(latitude: 37.785, longitude: -122.405),
          status: .open
        ),
        onAccept: {},
        onTimeout: {}
      )
    }
    .padding(.vertical, 20)
  }
  .ignoresSafeArea()
}
