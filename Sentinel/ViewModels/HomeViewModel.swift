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
    // Use separate incident arrays for my incidents and location incidents
    myIncidents = TestData.incidents
    locationIncidents = TestData.locationIncidents
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
