import MapKit
import SwiftUI

// MARK: - HomeView

struct HomeView: View {
  // MARK: - Properties

  @StateObject private var viewModel = HomeViewModel()
  @State private var position = MapCameraPosition.region(
    MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
  )

  // MARK: - Computed Properties

  /// Extract first name from TestData.user
  private var firstName: String {
    let parts = TestData.user.fullName.split(separator: " ")
    return parts.first.map(String.init) ?? TestData.user.fullName
  }

  /// Map style configuration
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
      ScrollView {
        VStack(spacing: 24) {
          // MARK: Greeting Section
          VStack(alignment: .leading, spacing: 4) {
            Text("Welcome, \(firstName)")
              .font(.largeTitle).bold()
            Text("Shift started at 8:00 AM")
              .font(.subheadline)
              .foregroundColor(Color("SecondaryText"))
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)

          // MARK: Report Button Section
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

          // MARK: Map Overview Section
          SectionCard(title: "Personnel Map") {
            ZStack {
              // Map View
              Map(position: $position) {
                UserAnnotation()
              }
              .mapStyle(mapStyleConfig)
              .frame(height: 180)
              .cornerRadius(12)
              .allowsHitTesting(false) // Disable direct interaction with map
              
              // Transparent overlay that handles tap for the entire area
              Color.clear
                .frame(height: 180)
                .contentShape(Rectangle())
                .onTapGesture {
                  viewModel.openMapView()
                }

              // Open Map Button
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
          .padding(.horizontal, 16)

          // MARK: My Incidents Section
          SectionCard(
            title: "My Incidents",
            actionTitle: "View all",
            action: {
              viewModel.openIncidentsView()
            }
          ) {
            VStack(spacing: 8) {
              ForEach(Array(viewModel.myIncidents.prefix(2))) { incident in
                IncidentCard(incident: incident) {
                  viewModel.openIncidentsView()
                }
              }
              
            }
          }
          .padding(.horizontal, 16)

          // MARK: Location Incidents Section
          SectionCard(
            title: "Location Incidents",
            actionTitle: "View all",
            action: {
              viewModel.openIncidentsView()
            }
          ) {
            VStack(spacing: 8) {
              ForEach(Array(viewModel.locationIncidents.prefix(2))) { incident in
                IncidentCard(incident: incident) {
                  viewModel.openIncidentsView()
                }
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
            .padding(.bottom, 8)
        }
      }
    }
  }
}

// MARK: - Previews

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
