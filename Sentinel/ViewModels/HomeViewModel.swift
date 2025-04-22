import Foundation

final class HomeViewModel: ObservableObject {
  @Published var myIncidents: [Incident] = []
  @Published var teamIncidents: [Incident] = []

  init() {
    // For now, use TestData for both
    myIncidents = TestData.incidents
    teamIncidents = TestData.incidents.shuffled()
  }
}
