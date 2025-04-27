import Foundation
import MapKit

struct NavigationInfo: Equatable {
  let incident: IncidentAnnotation
  let etaMinutes: Int
  let distance: Measurement<UnitLength>
  let estimatedArrival: Date
  let fare: Double
  
  init(
    incident: IncidentAnnotation,
    etaMinutes: Int = Int.random(in: 5...15),
    distance: Measurement<UnitLength> = Measurement(value: Double.random(in: 1...5), unit: .kilometers),
    fare: Double = Double.random(in: 30...80)
  ) {
    self.incident = incident
    self.etaMinutes = etaMinutes
    self.distance = distance
    self.estimatedArrival = Calendar.current.date(byAdding: .minute, value: etaMinutes, to: Date()) ?? Date()
    self.fare = fare
  }
  
  var formattedDistance: String {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit
    formatter.unitStyle = .medium
    return formatter.string(from: distance)
  }
  
  var formattedETA: String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter.string(from: estimatedArrival)
  }
  
  // Custom Equatable implementation to handle CLLocationCoordinate2D
  static func == (lhs: NavigationInfo, rhs: NavigationInfo) -> Bool {
    return lhs.incident.id == rhs.incident.id &&
           lhs.etaMinutes == rhs.etaMinutes &&
           lhs.distance == rhs.distance &&
           lhs.estimatedArrival == rhs.estimatedArrival &&
           abs(lhs.fare - rhs.fare) < 0.001
  }
}