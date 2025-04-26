import MapKit
import SwiftUI

struct MapView: View {
  @StateObject private var vm = MapViewModel()
  @Environment(\.dismiss) private var dismiss
  @State private var droppedIncidents = Set<String>()
  @State private var showingAcceptToast: IncidentAnnotation?
  @State private var selectedIncident: IncidentAnnotation?
  @State private var showAcceptToast = false

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
          
          // User location marker (appears above guard pins)
          // Custom user annotation with directional arrow
          let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
          Annotation("You", coordinate: userCoord) {
            ZStack {
              // Outer glow
              Circle()
                .fill(Color.accentColor.opacity(0.3))
                .frame(width: 64, height: 64)
              
              // Direction indicator (arrow pointing up)
              Image(systemName: "location.north.fill")
                .font(.title)
                .foregroundColor(.accentColor)
                .background(
                  Circle()
                    .fill(.white)
                    .frame(width: 40, height: 40)
                )
            }
          }
        }
        .mapStyle(mapStyleConfig)
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animateDrop()
          }
          
          // Find the open incident to trigger toast
          if let openIncident = vm.incidents.first(where: { $0.status == .open }) {
            selectedIncident = openIncident
            
            // Delay showing the toast until after animations begin
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
              withAnimation {
                showingAcceptToast = openIncident
              }
            }
          }
        }
        .navigationTitle("Map")
        .navigationBarItems(
          leading: Button("Done") {
            dismiss()
          },
          trailing: Button {
            vm.centerOnUser()
          } label: {
            Image(systemName: "location.fill")
          }
        )

        if let incident = showingAcceptToast {
          AcceptToast(
            incident: incident,
            onAccept: {
              withAnimation {
                showingAcceptToast = nil
              }
              // Handle accept action here if needed
            },
            onTimeout: {
              withAnimation {
                showingAcceptToast = nil
              }
            }
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .animation(.easeInOut, value: showingAcceptToast)
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
        let toastDelay = delay + 0.8 // Show toast after pin appears
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDelay) {
          withAnimation {
            selectedIncident = incident
            showAcceptToast = true
          }
        }
      }
    }
  }
}
