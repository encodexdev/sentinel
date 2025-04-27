import Foundation
import SwiftUI

final class HomeViewModel: ObservableObject, TabNavigating {
  @Published var myIncidents: [Incident] = []
  @Published var teamIncidents: [Incident] = []

  init() {
    // For now, use TestData for both
    myIncidents = TestData.incidents
    teamIncidents = TestData.incidents.shuffled()
  }
  
  // Tab navigation functionality with cleaner names
  func openMapView() {
    openMapTab()
  }
  
  func openReportView() {
    openReportTab()
  }
  
  func openIncidentsView() {
    openIncidentsTab()
  }
}
