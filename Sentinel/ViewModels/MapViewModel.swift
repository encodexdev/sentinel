import Combine
import MapKit
import SwiftUI

class MapViewModel: ObservableObject {
  // MARK: - Published Properties

  /// Camera position for SwiftUI Map
  @Published var position: MapCameraPosition

  /// Guard incidents to display
  @Published var incidents: [IncidentAnnotation] = []

  /// Animation delays by incident ID
  @Published var animationDelays: [String: Double] = [:]

  /// Selected incident for toast/navigation
  @Published var selectedIncident: IncidentAnnotation?

  /// Show the incident acceptance toast
  @Published var showAcceptToast = false

  /// Current camera heading (rotation)
  @Published var cameraHeading: Double = 0

  // MARK: - Private Properties

  /// Reference to the navigation manager
  private let navigationManager: NavigationManager

  /// Cancellables for subscriptions
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Initialization

  init(navigationManager: NavigationManager = NavigationManager()) {
    // Initialize position first to avoid using self before initialization
    let defaultRegion = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    position = .region(defaultRegion)

    // Store navigation manager
    self.navigationManager = navigationManager

    // Then proceed with generating incidents
    generateIncidents()

    // Set up subscriptions for navigation updates
    setupNavigationSubscriptions()
  }

  // MARK: - Setup Methods

  private func setupNavigationSubscriptions() {
    // Update camera position when navigation starts
    navigationManager.$activeNavigation
      .compactMap { $0 }
      .sink { [weak self] navigation in
        // Center the map on the route when navigation starts
        self?.centerOnRoute()
      }
      .store(in: &cancellables)
  }

  // MARK: - Incident Generation

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

  /// Updates the map region to show all incidents with the user at center
  func updateMapRegion(userCoord: CLLocationCoordinate2D) {
    let coords = incidents.map(\.coordinate)
    let lats = coords.map(\.latitude)
    let lons = coords.map(\.longitude)

    guard let maxLat = lats.max(),
      let minLat = lats.min(),
      let maxLon = lons.max(),
      let minLon = lons.min()
    else { return }

    // Calculate padding to ensure all incidents are visible
    // Use 20% padding (1.2 multiplier) to avoid incidents at the edge
    let latDelta = max(maxLat - userCoord.latitude, userCoord.latitude - minLat) * 2 * 1.2
    let lonDelta = max(maxLon - userCoord.longitude, userCoord.longitude - minLon) * 2 * 1.2

    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    let region = MKCoordinateRegion(center: userCoord, span: span)

    // Update camera position
    position = .region(region)
  }

  private func applyCollisionAvoidance(to tempIncidents: inout [IncidentAnnotation]) {
    let minDist: CLLocationDistance = 0.0005  // ~50m

    // Run a few passes of collision avoidance
    for _ in 0..<3 {
      var collisionsFixed = 0

      for i in 0..<tempIncidents.count {
        for j in (i + 1)..<tempIncidents.count {
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
    var incidentDistances: [(incident: IncidentAnnotation, distance: CLLocationDistance)] =
      incidents.map { incident in
        let incidentLocation = CLLocation(
          latitude: incident.coordinate.latitude,
          longitude: incident.coordinate.longitude
        )
        return (incident, centerLocation.distance(from: incidentLocation))
      }

    // Sort by distance (closest first)
    incidentDistances.sort { $0.distance < $1.distance }

    // Compute normalized delays
    let maxDelay: Double = 3.0  // 3 seconds total animation time
    let totalIncidents = Double(incidentDistances.count)

    var delays: [String: Double] = [:]
    for (i, incidentDistance) in incidentDistances.enumerated() {
      let normalizedDelay = Double(i) / max(1, totalIncidents - 1) * maxDelay
      delays[incidentDistance.incident.id] = normalizedDelay
    }

    // Update the published property
    animationDelays = delays
  }

  // MARK: - Public Methods

  /// Recenters the map on the user's location with a tight span
  func centerOnUser() {
    let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    let region = MKCoordinateRegion(center: userCoord, span: span)

    // Reset the camera heading when returning to default view
    self.cameraHeading = 0

    withAnimation {
      position = .region(region)
    }
  }

  /// Centers the map on the active navigation route
  func centerOnRoute() {
    let route = navigationManager.routePoints
    guard !route.isEmpty else { return }

    // Calculate a region that encompasses the route
    let lats = route.map(\.latitude)
    let lons = route.map(\.longitude)

    guard let maxLat = lats.max(),
      let minLat = lats.min(),
      let maxLon = lons.max(),
      let minLon = lons.min()
    else { return }

    // Add padding
    let latDelta = (maxLat - minLat) * 1.3
    let lonDelta = (maxLon - minLon) * 1.3

    let center = CLLocationCoordinate2D(
      latitude: (maxLat + minLat) / 2,
      longitude: (maxLon + minLon) / 2
    )

    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
    let region = MKCoordinateRegion(center: center, span: span)

    withAnimation {
      position = .region(region)
    }
  }

  /// Accepts an incident and starts navigation
  func acceptIncident(_ incident: IncidentAnnotation) {
    navigationManager.startNavigation(to: incident)
    showAcceptToast = false

    // Calculate heading between user and incident
    let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    let heading = calculateHeading(from: userCoord, to: incident.coordinate)

    // Point map toward incident with rotation and custom region
    pointMapTowardsIncident(incident: incident, heading: heading)
  }

  /// Cancels the active navigation and resets the map view
  func cancelNavigation() {
    navigationManager.cancelNavigation()
    
    // First reset the camera heading
    self.cameraHeading = 0
    
    // Then zoom out to show all incidents with animation
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      withAnimation(.easeInOut(duration: 1.2)) {
        self.resetToOverviewMap()
      }
    }
  }
  
  /// Resets the map to show an overview of all incidents
  func resetToOverviewMap() {
    // Get user coordinate as the center reference
    let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    
    // Calculate a region that encompasses all incidents
    updateMapRegion(userCoord: userCoord)
  }

  /// Checks if there's an active navigation
  var isNavigating: Bool {
    navigationManager.isNavigating
  }

  /// Gets the active navigation info
  var activeNavigation: NavigationInfo? {
    navigationManager.activeNavigation
  }

  /// Gets the navigation progress
  var navigationProgress: Double {
    navigationManager.navigationProgress
  }

  /// Gets the route points for the polyline
  var routePoints: [CLLocationCoordinate2D] {
    navigationManager.routePoints
  }

  // MARK: - Animation Helpers

  /// A set of dropped incident IDs to keep track of animation state
  @Published var droppedIncidents = Set<String>()

  /// Handles initial view appearance setup
  func handleAppearance() {
    // Make sure we see all incidents when the view first appears
    resetToOverviewMap()
    
    // Animate dropping pins onto the map
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.animateDropIncidents()
    }

    // Find the open incident to trigger toast
    if let openIncident = incidents.first(where: { $0.status == .open }) {
      selectedIncident = openIncident

      // Delay showing the toast until after animations begin
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        withAnimation {
          self.showAcceptToast = true
        }
      }
    }
  }

  /// Animates the dropping of pins onto the map with distance-based delays
  func animateDropIncidents() {
    // Use distance-based delays for animation
    for incident in incidents {
      // Use safe optional access with default value
      let delay = animationDelays[incident.id, default: 0.0]

      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        withAnimation(.easeOut(duration: 0.6)) {
          _ = self.droppedIncidents.insert(incident.id)
        }
      }

      // If it's the open incident, schedule showing the toast
      if incident.status == .open {
        let toastDelay = delay + 2
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDelay) {
          withAnimation {
            self.selectedIncident = incident
            self.showAcceptToast = true
          }
        }
      }
    }
  }

  // MARK: - Private Helper Methods

  /// Calculate heading angle between two coordinates (in degrees)
  private func calculateHeading(
    from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D
  ) -> Double {
    let lat1 = source.latitude * .pi / 180
    let lon1 = source.longitude * .pi / 180
    let lat2 = destination.latitude * .pi / 180
    let lon2 = destination.longitude * .pi / 180

    let dLon = lon2 - lon1
    let y = sin(dLon) * cos(lat2)
    let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
    let radiansBearing = atan2(y, x)

    // Convert to degrees
    var degreesBearing = radiansBearing * 180 / .pi
    if degreesBearing < 0 {
      degreesBearing += 360
    }

    return degreesBearing
  }

  /// Point the map towards an incident with rotation
  private func pointMapTowardsIncident(incident: IncidentAnnotation, heading: Double) {
    let userCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    // Create a camera with:
    // 1. Centered on the user's location
    // 2. Looking in the direction of the incident
    // 3. Zoom level that shows both user and part of the route

    // Create a MapCamera with heading (rotation)
    let camera = MapCamera(
      centerCoordinate: userCoord,
      distance: 1000,  // meters from the ground
      heading: heading,  // degrees clockwise from north
      pitch: 45  // degrees up from the horizon (3D effect)
    )

    // Update our published heading value
    self.cameraHeading = heading

    // Animate to the new camera position
    withAnimation(.easeInOut(duration: 1.5)) {
      position = .camera(camera)
    }

    // After 2 seconds, transition to the route view
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      self.centerOnRoute()
    }
  }
}
