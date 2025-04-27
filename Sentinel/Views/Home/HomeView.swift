import MapKit
import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = HomeViewModel()
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
            viewModel.openReportView()
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
          SectionCard(title: "Personnel Map") {
            ZStack {
              Map(position: $position) {
                UserAnnotation()
              }
              .mapStyle(mapStyleConfig)
              .frame(height: 180)
              .cornerRadius(12)
              .contentShape(Rectangle())
              .onTapGesture {
                viewModel.openMapView()
              }

              Button {
                viewModel.openMapView()
              } label: {
                Text("Open Map")
                  .font(.subheadline)
                  .fontWeight(.medium)
                  .padding(.vertical, 8)
                  .padding(.horizontal, 16)
                  .background(Color.accentColor)
                  .foregroundColor(.white)
                  .cornerRadius(8)
              }
              .shadow(radius: 2)
            }
          }
          .padding(.horizontal, 16)  // Added vertical padding
          
          // MARK: My Incidents Section
          SectionCard(
            title: "My Incidents",
            actionTitle: "View all",
            action: {
              viewModel.openIncidentsView()
            }
          ) {
            VStack(spacing: 8) {
              ForEach(viewModel.myIncidents) { incident in
                IncidentCard(incident: incident)
              }
            }
          }
          .padding(.horizontal, 16)

          // MARK: Team Incidents Section
          SectionCard(title: "Team Incidents") {
            VStack(spacing: 8) {
              ForEach(viewModel.teamIncidents) { incident in
                IncidentCard(incident: incident)
              }
            }
          }
          .padding(.horizontal, 16)

          Spacer(minLength: 20)
        }
        .padding(.vertical, 24)
      }
      .navigationTitle("Home")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          ProfileIcon(user: TestData.user)
            .padding(.bottom, 8)  // Add padding below the profile icon
        }
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
