import MapKit
import SwiftUI

struct HomeView: View {
  @StateObject private var vm = HomeViewModel()
  @State private var position = MapCameraPosition.region(
    MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
  )

  // Extract first name from TestData.user
  private var firstName: String {
    let parts = TestData.user.fullName.split(separator: " ")
    return parts.first.map(String.init) ?? TestData.user.fullName
  }

  @State private var showingChatView = false
  @State private var showingMapView = false
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {

          // MARK: Greeting
          VStack(alignment: .leading, spacing: 4) {
            Text("Welcome, \(firstName)")
              .font(.largeTitle).bold()
            Text("Shift started at 8:00 AM")
              .font(.subheadline)
              .foregroundColor(Color("SecondaryText"))
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)

          // MARK: Report Button
          Button {
            showingChatView = true
          } label: {
            Label("Report New Incident", systemImage: "exclamationmark.bubble")
              .font(.headline)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color("AccentBlue"))
              .foregroundColor(.white)
              .cornerRadius(12)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 8)

          // MARK: Map Overview
          SectionCard(title: "Map Overview") {
            ZStack {
              Map(position: $position) {
                UserAnnotation()
              }
                .frame(height: 180)
                .cornerRadius(12)

              Button {
                showingMapView = true
              } label: {
                Text("Open Map")
                  .padding(.all, 8)
                  .background(.ultraThinMaterial)
                  .cornerRadius(8)
                  .shadow(radius: 5)
              }
              .buttonStyle(.borderedProminent)
            }
          }
          .padding(.horizontal, 16)  // Added vertical padding
          
          // MARK: My Incidents Section
          SectionCard(
            title: "My Incidents",
            actionTitle: "View all",
            action: {
              // TODO: handle "View all"
            }
          ) {
            VStack(spacing: 8) {
              ForEach(vm.myIncidents) { incident in
                IncidentCard(incident: incident)
              }
            }
          }
          .padding(.horizontal, 16)

          // MARK: Team Incidents Section
          SectionCard(title: "Team Incidents") {
            VStack(spacing: 8) {
              ForEach(vm.teamIncidents) { incident in
                IncidentCard(incident: incident)
              }
            }
          }
          .padding(.horizontal, 16)

          Spacer(minLength: 20)
        }
        .padding(.vertical, 24)
      }
      // Global background handled by SentinelApp
      .navigationTitle("Home")
      .sheet(isPresented: $showingMapView) {
        MapView()
      }
      .fullScreenCover(isPresented: $showingChatView) {
        ChatView()
      }
    }
  }
}
