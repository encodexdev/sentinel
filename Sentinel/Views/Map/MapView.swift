import LucideIcons
import MapKit
import SwiftUI

struct MapView: View {
  // MARK: - Properties
  @StateObject private var vm = MapViewModel()
  @Environment(\.dismiss) private var dismiss

  // MARK: - Map Configuration
  private var mapStyleConfig: MapStyle {
    .standard(
      elevation: .automatic,
      emphasis: .muted,
      pointsOfInterest: .excludingAll,
      showsTraffic: false
    )
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      ZStack(alignment: .bottom) {
        // MARK: Map View
        Map(position: $vm.position) {
          // MARK: Incident Pins
          ForEach(vm.incidents) { incident in
            Annotation("", coordinate: incident.coordinate) {
              IncidentPin(
                status: incident.status,
                dropped: vm.droppedIncidents.contains(incident.id)
              )
            }
          }

          // MARK: User Location
          let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
          Annotation("You", coordinate: userCoord) {
            // Use the dedicated UserLocationView that handles rotation
            UserLocationView(cameraHeading: vm.cameraHeading)
          }

          // MARK: Navigation Route
          if vm.isNavigating, !vm.routePoints.isEmpty {
            MapPolyline(coordinates: vm.routePoints)
              .stroke(.blue, lineWidth: 5)
          }
        }
        .mapStyle(mapStyleConfig)
        .onAppear { vm.handleAppearance() }
        .navigationTitle("Personnel")
        .navigationBarItems(
          trailing: Button {
            vm.centerOnUser()
          } label: {
            Image(systemName: "location.fill")
          }
        )

        // MARK: Accept Toast
        if vm.showAcceptToast, let incident = vm.selectedIncident {
          AcceptToast(
            incident: incident,
            onAccept: {
              withAnimation {
                vm.acceptIncident(incident)
              }
            },
            onTimeout: {
              withAnimation {
                vm.showAcceptToast = false
              }
            }
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .animation(.easeInOut, value: vm.showAcceptToast)
          .padding(.bottom, 20)
        }

        // MARK: Navigation Panel
        if vm.isNavigating, let navigation = vm.activeNavigation {
          NavigationPanel(
            navigationInfo: navigation,
            progress: vm.navigationProgress,
            onCancel: {
              withAnimation {
                vm.cancelNavigation()
              }
            }
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .animation(.easeInOut, value: vm.isNavigating)
          .padding(.bottom, 20)
        }
      }
    }
  }

}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView()
  }
}
