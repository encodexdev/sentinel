import MapKit
import SwiftUI

class MapViewModel: ObservableObject {
  @Published var position = MapCameraPosition.region(
    MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
  )

  @Published var incidents: [IncidentAnnotation] = []

  init() {
    // Center coordinate
    let centerCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    // Build a shuffled list of statuses: 3 resolved (grey), 16 in-progress (green)
    var statuses = Array(repeating: IncidentStatus.resolved, count: 3)
    statuses += Array(repeating: IncidentStatus.inProgress, count: 16)
    statuses.shuffle()

    // Generate 19 random incidents around center
    incidents = statuses.map { status in
      let randLat = centerCoord.latitude + Double.random(in: -0.02...0.02)
      let randLon = centerCoord.longitude + Double.random(in: -0.02...0.02)
      return IncidentAnnotation(
        id: UUID().uuidString,
        title: "",
        coordinate: CLLocationCoordinate2D(latitude: randLat, longitude: randLon),
        status: status
      )
    }

    // mark the incident closest to the user as open
    let userLoc = CLLocation(latitude: centerCoord.latitude, longitude: centerCoord.longitude)
    var closestIndex = 0
    var smallestDist = userLoc.distance(from: CLLocation(
      latitude: incidents[0].coordinate.latitude,
      longitude: incidents[0].coordinate.longitude
    ))
    for i in 1..<incidents.count {
      let dist = userLoc.distance(from: CLLocation(
        latitude: incidents[i].coordinate.latitude,
        longitude: incidents[i].coordinate.longitude
      ))
      if dist < smallestDist {
        smallestDist = dist
        closestIndex = i
      }
    }
    incidents[closestIndex].status = .open

    // compute a span that fits all incidents around the user
    let coords = incidents.map(\.coordinate)
    let lats = coords.map(\.latitude)
    let lons = coords.map(\.longitude)
    let maxLat = lats.max()!, minLat = lats.min()!
    let maxLon = lons.max()!, minLon = lons.min()!
    let latDelta = max(maxLat - centerCoord.latitude, centerCoord.latitude - minLat) * 2 * 1.2
    let lonDelta = max(maxLon - centerCoord.longitude, centerCoord.longitude - minLon) * 2 * 1.2
    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    self.position = .region(MKCoordinateRegion(center: centerCoord, span: span))
  }

  func centerOnUser() {
    // In a real app, this would get the user's location
    withAnimation {
      self.position = MapCameraPosition.region(
        MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
          span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
      )
    }
  }
}

struct IncidentAnnotation: Identifiable {
  let id: String
  let title: String
  let coordinate: CLLocationCoordinate2D
  var status: IncidentStatus
}

struct IncidentPin: View {
  let status: IncidentStatus
  let dropped: Bool
  @State private var pulsing = false

  func color(for status: IncidentStatus) -> Color {
    switch status {
    case .open: return Color("StatusOpen")
    case .inProgress: return Color("StatusInProgress")
    case .resolved: return Color("StatusResolved")
    }
  }

  var body: some View {
    ZStack {
      // glowing halo
      Circle()
        .fill(color(for: status))
        .frame(width: 50, height: 50)
        .blur(radius: 12)
        .opacity(0.4)
        .scaleEffect(pulsing ? 1.1 : 0.8)

      // white inner circle
      Circle()
        .fill(Color.white)
        .frame(width: 36, height: 36)

      // human icon
      Image(systemName: "person.fill")
        .font(.title2)
        .foregroundColor(color(for: status))
    }
    .onAppear {
      withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
        pulsing.toggle()
      }
    }
    .scaleEffect(dropped ? 1 : 0, anchor: .center)
    .opacity(dropped ? 1 : 0)
  }
}

struct MapView: View {
  @StateObject private var vm = MapViewModel()
  @Environment(\.dismiss) private var dismiss
  @State private var droppedIncidents = Set<String>()

  private var mapStyleConfig: MapStyle {
    .standard(
      elevation: .automatic,
      emphasis: .muted,
      pointsOfInterest: .excludingAll,
      showsTraffic: false
    )
  }

  func color(for status: IncidentStatus) -> Color {
    switch status {
    case .open: return Color("StatusOpen")
    case .inProgress: return Color("StatusInProgress")
    case .resolved: return Color("StatusResolved")
    }
  }

  var body: some View {
    NavigationStack {
      Map(position: $vm.position) {
        ForEach(vm.incidents) { incident in
          Annotation("", coordinate: incident.coordinate) {
            IncidentPin(
              status: incident.status,
              dropped: droppedIncidents.contains(incident.id)
            )
          }
        }
      }
      .mapStyle(mapStyleConfig)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          animateDrop()
        }
      }
      .navigationTitle("Map")
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            vm.centerOnUser()
          } label: {
            Image(systemName: "location.fill")
          }
        }

        ToolbarItem(placement: .navigationBarLeading) {
          Button("Done") {
            dismiss()
          }
        }
      }
      // Global background handled by SentinelApp
    }
  }

  private func animateDrop() {
    for (index, incident) in vm.incidents.enumerated() {
      let delay = Double(index) * 0.1
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
          _ = droppedIncidents.insert(incident.id)
        }
      }
    }
  }
}
