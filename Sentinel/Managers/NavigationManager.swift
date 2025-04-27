import Foundation
import MapKit
import Combine

/// Manages navigation-related functionality
class NavigationManager: ObservableObject {
  // Current navigation info if we're navigating
  @Published private(set) var activeNavigation: NavigationInfo?
  
  // Whether the navigation is currently active
  @Published private(set) var isNavigating: Bool = false
  
  // Progress of the current navigation (0.0 to 1.0)
  @Published private(set) var navigationProgress: Double = 0.0
  
  // Route points for the navigation line
  @Published private(set) var routePoints: [CLLocationCoordinate2D] = []
  
  private var simulationTimer: Timer?
  private var userLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
  
  // Start navigation to an incident
  func startNavigation(to incident: IncidentAnnotation) {
    // Cancel any existing navigation
    cancelNavigation()
    
    // Create navigation info
    let navigation = NavigationInfo(incident: incident)
    self.activeNavigation = navigation
    
    // Generate route points
    generateRoutePoints(from: userLocation, to: incident.coordinate)
    
    // Set navigation state
    isNavigating = true
    navigationProgress = 0.0
    
    // Start the simulation timer to update progress
    startSimulation()
  }
  
  // Cancel current navigation
  func cancelNavigation() {
    simulationTimer?.invalidate()
    simulationTimer = nil
    isNavigating = false
    activeNavigation = nil
    navigationProgress = 0.0
    routePoints = []
  }
  
  // Sets the user's current location
  func updateUserLocation(_ location: CLLocationCoordinate2D) {
    self.userLocation = location
    
    // If we're navigating, update the route from the new location
    if isNavigating, let destination = activeNavigation?.incident.coordinate {
      generateRoutePoints(from: location, to: destination)
    }
  }
  
  // Generate a simulated route between two points
  private func generateRoutePoints(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
    // For simplicity, create a direct line with some slight randomness
    var points: [CLLocationCoordinate2D] = []
    
    // Add starting point
    points.append(start)
    
    // Generate some intermediate points
    let pointCount = 10
    for i in 1...pointCount-1 {
      let fraction = Double(i) / Double(pointCount)
      
      // Linear interpolation between start and end
      let lat = start.latitude + (end.latitude - start.latitude) * fraction
      let lon = start.longitude + (end.longitude - start.longitude) * fraction
      
      // Add some randomness to make it look like a real route
      let jitterAmount = 0.0003 * sin(Double(i) * 0.8)
      let point = CLLocationCoordinate2D(
        latitude: lat + jitterAmount,
        longitude: lon + jitterAmount
      )
      points.append(point)
    }
    
    // Add destination
    points.append(end)
    
    // Update route points
    routePoints = points
  }
  
  // Simulate navigation progress
  private func startSimulation() {
    // Reset timer if it exists
    simulationTimer?.invalidate()
    
    // Start new timer that updates every half second
    simulationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
      guard let self = self, self.isNavigating else { return }
      
      // Increment progress
      let newProgress = min(1.0, (self.navigationProgress + 0.01))
      self.navigationProgress = newProgress
      
      // If we've reached the destination
      if newProgress >= 1.0 {
        self.arriveAtDestination()
      }
    }
  }
  
  // Handle arrival at destination
  private func arriveAtDestination() {
    simulationTimer?.invalidate()
    simulationTimer = nil
    
    // Keep the navigation info active but stop the active navigation
    isNavigating = false
    
    // After 3 seconds, fully complete the navigation
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
      self?.cancelNavigation()
    }
  }
  
  // For preview and testing
  static func previewManager() -> NavigationManager {
    let manager = NavigationManager()
    
    // Create a sample incident
    let sampleIncident = IncidentAnnotation(
      id: "preview-123",
      title: "Medical Emergency",
      coordinate: CLLocationCoordinate2D(latitude: 37.785, longitude: -122.405),
      status: .open
    )
    
    // Start navigation to it
    manager.startNavigation(to: sampleIncident)
    
    return manager
  }
}