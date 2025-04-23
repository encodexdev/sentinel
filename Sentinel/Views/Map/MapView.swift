import SwiftUI
import MapKit

class MapViewModel: ObservableObject {
  @Published var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
  )
  
  @Published var incidents: [IncidentAnnotation] = []
  
  init() {
    // Convert TestData.incidents to IncidentAnnotation
    incidents = TestData.incidents.compactMap { incident in
      // For demo purposes, generate random coordinates around San Francisco
      let randomLat = 37.7749 + Double.random(in: -0.025...0.025)
      let randomLon = -122.4194 + Double.random(in: -0.025...0.025)
      
      return IncidentAnnotation(
        id: incident.id,
        title: incident.title,
        coordinate: CLLocationCoordinate2D(latitude: randomLat, longitude: randomLon),
        status: incident.status
      )
    }
  }
  
  func centerOnUser() {
    // In a real app, this would get the user's location
    withAnimation {
      self.region.center = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
      self.region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    }
  }
}

struct IncidentAnnotation: Identifiable {
  let id: String
  let title: String
  let coordinate: CLLocationCoordinate2D
  let status: IncidentStatus
}

struct MapView: View {
  @StateObject private var vm = MapViewModel()
  
  func color(for status: IncidentStatus) -> Color {
    switch status {
    case .open: return Color("StatusOpen")
    case .inProgress: return Color("StatusInProgress")
    case .resolved: return Color("StatusResolved")
    }
  }

  var body: some View {
    NavigationStack {
      Map(coordinateRegion: $vm.region,
          annotationItems: vm.incidents) { incident in
        MapAnnotation(coordinate: incident.coordinate) {
          VStack {
            Image(systemName: "mappin.circle.fill")
              .font(.title2)
              .foregroundColor(color(for: incident.status))
          }
          .background(Circle().fill(.white).frame(width: 12, height: 12))
        }
      }
      .navigationTitle("Map")
      .overlay(alignment: .topTrailing) {
        Button {
          vm.centerOnUser()
        } label: {
          Image(systemName: "location.fill")
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(radius: 4)
        }
        .padding()
      }
      // Global background handled by SentinelApp
    }
  }
}
