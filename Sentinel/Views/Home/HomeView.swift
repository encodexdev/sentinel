import MapKit
import SwiftUI

struct HomeView: View {
  @StateObject private var vm = HomeViewModel()
  @State private var region = MKCoordinateRegion(
    center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
  )

  // Extract first name from TestData.user
  private var firstName: String {
    let parts = TestData.user.fullName.split(separator: " ")
    return parts.first.map(String.init) ?? TestData.user.fullName
  }

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
            // TODO: navigate to ChatView
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
          .padding(.top, 8)

          // MARK: Map Overview
          SectionCard(title: "Map Overview") {
            ZStack {
              Map(coordinateRegion: $region, showsUserLocation: true)
                .frame(height: 180)
                .cornerRadius(12)

              Button {
                // TODO: Navigate to full map
              } label: {
                Text("Open Map")
                  .padding(.horizontal, 16)
                  .padding(.vertical, 8)
                  .background(.ultraThinMaterial)
                  .cornerRadius(8)
                  .shadow(radius: 5)
              }
              .buttonStyle(.borderedProminent)
            }
          }
          .padding(.horizontal, 16)

          // MARK: My Incidents Section
          SectionCard(
            title: "My Incidents",
            actionTitle: "View all",
            action: {
              // TODO: handle "View all"
            }
          ) {
            ForEach(vm.myIncidents) { incident in
              IncidentCard(incident: incident)
            }
          }
          .padding(.horizontal, 16)

          // MARK: Team Incidents Section
          SectionCard(title: "Team Incidents") {
            ForEach(vm.teamIncidents) { incident in
              IncidentCard(incident: incident)
            }
          }
          .padding(.horizontal, 16)

          Spacer(minLength: 20)
        }
        .padding(.vertical, 24)
      }
      // Global background handled by SentinelApp
      .navigationTitle("Home")
    }
  }
}
