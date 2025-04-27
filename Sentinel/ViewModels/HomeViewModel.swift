import Foundation
import SwiftUI

// MARK: - HomeViewModel

final class HomeViewModel: ObservableObject, TabNavigating {
  // MARK: - Published Properties

  /// Incidents assigned to the current user
  @Published var myIncidents: [Incident] = []

  /// Incidents assigned to the location/organization
  @Published var locationIncidents: [Incident] = []

  // MARK: - Initialization

  init() {
    // For now, use TestData for both
    myIncidents = TestData.incidents
    locationIncidents = TestData.incidents.shuffled()
  }

  // MARK: - Navigation Methods

  /// Opens the map view tab
  func openMapView() {
    openMapTab()
  }

  /// Opens the report incident view/tab
  func openReportView() {
    openReportTab()
  }

  /// Opens the incidents list view/tab
  func openIncidentsView() {
    openIncidentsTab()
  }
}
