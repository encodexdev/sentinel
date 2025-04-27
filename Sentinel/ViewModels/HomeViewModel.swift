import Foundation
import SwiftUI

final class HomeViewModel: ObservableObject {
  @Published var myIncidents: [Incident] = []
  @Published var teamIncidents: [Incident] = []

  init() {
    // For now, use TestData for both
    myIncidents = TestData.incidents
    teamIncidents = TestData.incidents.shuffled()
  }
  
  // Tab navigation functionality
  func openMapView() {
    TabViewManager.shared.switchToTab(.map)
  }
  
  func openReportView() {
    TabViewManager.shared.switchToTab(.report)
  }
  
  func openIncidentsView() {
    TabViewManager.shared.switchToTab(.incidents)
  }
}
