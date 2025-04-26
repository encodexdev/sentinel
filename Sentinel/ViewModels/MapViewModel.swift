
import SwiftUI
import MapKit

class MapViewModel: ObservableObject {
    // Camera position for SwiftUI Map
    @Published var position: MapCameraPosition
    // Guard incidents to display
    @Published var incidents: [IncidentAnnotation] = []
    // Animation delays by incident ID
    @Published var animationDelays: [String: Double] = [:]

    init() {
        // Initialize position first to avoid using self before initialization
        let defaultRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        position = .region(defaultRegion)
        
        // Then proceed with generating incidents
        generateIncidents()
    }
    
    private func generateIncidents() {
        // Base user coordinate (San Francisco)
        let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        
        // Build statuses: 3 resolved (grey), 16 in-progress (green)
        var statuses = Array(repeating: IncidentStatus.resolved, count: 3)
        statuses += Array(repeating: IncidentStatus.inProgress, count: 16)
        statuses.shuffle()
        
        // Temporary array to hold incidents
        var tempIncidents: [IncidentAnnotation] = []
        
        // Generate random incidents around user
        tempIncidents = statuses.map { status in
            let randLat = userCoord.latitude + Double.random(in: -0.02...0.02)
            let randLon = userCoord.longitude + Double.random(in: -0.02...0.02)
            return IncidentAnnotation(
                id: UUID().uuidString,
                title: "",
                coordinate: CLLocationCoordinate2D(latitude: randLat, longitude: randLon),
                status: status
            )
        }
        
        // Mark the incident closest to the user as open (red)
        let userLocation = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        var closestIndex = 0
        var smallestDistance = Double.greatestFiniteMagnitude
        
        for (i, incident) in tempIncidents.enumerated() {
            let incidentLocation = CLLocation(
                latitude: incident.coordinate.latitude,
                longitude: incident.coordinate.longitude
            )
            let dist = userLocation.distance(from: incidentLocation)
            
            if dist < smallestDistance {
                smallestDistance = dist
                closestIndex = i
            }
        }
        
        // Mark the closest as open
        tempIncidents[closestIndex].status = .open
        
        // Apply collision avoidance to avoid overlapping pins
        applyCollisionAvoidance(to: &tempIncidents)
        
        // Now assign to the published property
        incidents = tempIncidents
        
        // Compute a region that fits all incidents around the user
        updateMapRegion(userCoord: userCoord)
        
        // Compute animation delays
        computeAnimationDelays()
    }
    
    private func updateMapRegion(userCoord: CLLocationCoordinate2D) {
        let coords = incidents.map(\.coordinate)
        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)
        
        guard let maxLat = lats.max(),
              let minLat = lats.min(),
              let maxLon = lons.max(),
              let minLon = lons.min() else { return }
        
        let latDelta = max(maxLat - userCoord.latitude, userCoord.latitude - minLat) * 2 * 1.2
        let lonDelta = max(maxLon - userCoord.longitude, userCoord.longitude - minLon) * 2 * 1.2
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region = MKCoordinateRegion(center: userCoord, span: span)
        
        // Update camera position
        position = .region(region)
    }
    
    private func applyCollisionAvoidance(to tempIncidents: inout [IncidentAnnotation]) {
        let minDist: CLLocationDistance = 0.0005 // ~50m
        
        // Run a few passes of collision avoidance
        for _ in 0..<3 {
            var collisionsFixed = 0
            
            for i in 0..<tempIncidents.count {
                for j in (i+1)..<tempIncidents.count {
                    let loc1 = CLLocation(
                        latitude: tempIncidents[i].coordinate.latitude,
                        longitude: tempIncidents[i].coordinate.longitude
                    )
                    let loc2 = CLLocation(
                        latitude: tempIncidents[j].coordinate.latitude,
                        longitude: tempIncidents[j].coordinate.longitude
                    )
                    
                    let distance = loc1.distance(from: loc2)
                    
                    if distance < minDist {
                        // Push pins apart slightly
                        let bearing = atan2(
                            tempIncidents[j].coordinate.latitude - tempIncidents[i].coordinate.latitude,
                            tempIncidents[j].coordinate.longitude - tempIncidents[i].coordinate.longitude
                        )
                        
                        // Move the second pin slightly in the direction of the bearing
                        let moveFactor = (minDist - distance) / minDist * 0.00005
                        let newLat = tempIncidents[j].coordinate.latitude + sin(bearing) * moveFactor
                        let newLon = tempIncidents[j].coordinate.longitude + cos(bearing) * moveFactor
                        
                        tempIncidents[j].coordinate = CLLocationCoordinate2D(
                            latitude: newLat,
                            longitude: newLon
                        )
                        collisionsFixed += 1
                    }
                }
            }
            
            // If no collisions were fixed in this pass, we're done
            if collisionsFixed == 0 {
                break
            }
        }
    }
    
    private func computeAnimationDelays() {
        // Get map center
        guard let region = position.region else { return }
        let mapCenter = region.center
        let centerLocation = CLLocation(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
        
        // Create array of (incident, distance)
        var incidentDistances: [(incident: IncidentAnnotation, distance: CLLocationDistance)] = incidents.map { incident in
            let incidentLocation = CLLocation(
                latitude: incident.coordinate.latitude,
                longitude: incident.coordinate.longitude
            )
            return (incident, centerLocation.distance(from: incidentLocation))
        }
        
        // Sort by distance (closest first)
        incidentDistances.sort { $0.distance < $1.distance }
        
        // Compute normalized delays
        let maxDelay: Double = 3.0 // 3 seconds total animation time
        let totalIncidents = Double(incidentDistances.count)
        
        var delays: [String: Double] = [:]
        for (i, incidentDistance) in incidentDistances.enumerated() {
            let normalizedDelay = Double(i) / max(1, totalIncidents - 1) * maxDelay
            delays[incidentDistance.incident.id] = normalizedDelay
        }
        
        // Update the published property
        animationDelays = delays
    }

    /// Recenters the map on the user's location with a tight span
    func centerOnUser() {
        let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: userCoord, span: span)
        withAnimation {
            position = .region(region)
        }
    }
}
