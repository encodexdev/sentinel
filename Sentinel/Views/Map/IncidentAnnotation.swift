import Foundation
import MapKit

/// A simple representable for guard/incidents on the map
struct IncidentAnnotation: Identifiable, Equatable {
    let id: String
    let title: String
    var coordinate: CLLocationCoordinate2D
    var status: IncidentStatus
    
    // Implement Equatable manually since CLLocationCoordinate2D doesn't conform to Equatable
    static func == (lhs: IncidentAnnotation, rhs: IncidentAnnotation) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude &&
               lhs.status == rhs.status
    }
}
