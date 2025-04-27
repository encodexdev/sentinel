import LucideIcons
import MapKit
import SwiftUI

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

  var body: some View {
    NavigationStack {
      ZStack(alignment: .bottom) {
        Map(position: $vm.position) {
          // Guard pins
          ForEach(vm.incidents) { incident in
            Annotation("", coordinate: incident.coordinate) {
              IncidentPin(
                status: incident.status,
                dropped: droppedIncidents.contains(incident.id)
              )
            }
          }

          // User location marker
          // Custom user annotation with directional arrow
          let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
          Annotation("You", coordinate: userCoord) {
            ZStack {
              // Single clean pulsing glow
              Circle()
                .fill(Color.accentColor.opacity(0.3))
                .frame(width: 36, height: 36)
                .modifier(PulseEffect())

              // Direction indicator (arrow pointing up)
              Image(systemName: "location.north.fill")
                .font(.title3)
                .foregroundColor(.accentColor)
                .background(
                  Circle()
                    .fill(.white)
                    .frame(width: 32, height: 32)
                )
            }
          }

          // Show route line if navigating
          if vm.isNavigating, !vm.routePoints.isEmpty {
            MapPolyline(coordinates: vm.routePoints)
              .stroke(.blue, lineWidth: 5)
          }
        }
        .mapStyle(mapStyleConfig)
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateDrop()
          }

          // Find the open incident to trigger toast
          if let openIncident = vm.incidents.first(where: { $0.status == .open }) {
            vm.selectedIncident = openIncident

            // Delay showing the toast until after animations begin
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
              withAnimation {
                vm.showAcceptToast = true
              }
            }
          }
        }
        .navigationTitle("Personnel")
        .navigationBarItems(
          trailing: Button {
            vm.centerOnUser()
          } label: {
            Image(systemName: "location.fill")
          }
        )

        // Accept toast
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

        // Navigation panel
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

  private func animateDrop() {
    // Use distance-based delays for animation
    for incident in vm.incidents {
      // Use safe optional access with default value
      let delay = vm.animationDelays[incident.id, default: 0.0]

      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        withAnimation(.easeOut(duration: 0.6)) {
          _ = droppedIncidents.insert(incident.id)
        }
      }

      // If it's the open incident, schedule showing the toast
      if incident.status == .open {
        let toastDelay = delay + 0.8  // Show toast after pin appears
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDelay) {
          withAnimation {
            vm.selectedIncident = incident
            vm.showAcceptToast = true
          }
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
