import SwiftUI

struct IncidentsView: View {
  @StateObject private var viewModel = HomeViewModel()
  @State private var selectedFilter: IncidentFilter = .all

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        filterPicker
        incidentList
      }
      .navigationTitle("Incidents")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            // TODO: implement refresh or additional actions
          } label: {
            Image(systemName: "arrow.clockwise")
          }
        }
      }
    }
  }
  
  // MARK: - Component Views
  
  /// Filter picker at the top of the view
  private var filterPicker: some View {
    Picker("Filter", selection: $selectedFilter) {
      ForEach(IncidentFilter.allCases, id: \.self) { filter in
        Text(filter.rawValue)
      }
    }
    .pickerStyle(.segmented)
    .padding(.horizontal)
    .padding(.top, 8)
  }
  
  /// Main scrollable content area showing filtered incidents
  private var incidentList: some View {
    ScrollView {
      VStack(spacing: 16) {
        // My Incidents Section
        myIncidentsSection
        
        // Location Incidents Section
        locationIncidentsSection
        
        // Status-based filtering
        statusFilteredIncidentsSection
        
        Spacer(minLength: 20)
      }
      .padding(.vertical, 16)
    }
  }
  
  /// Shows the user's assigned incidents
  @ViewBuilder
  private var myIncidentsSection: some View {
    if selectedFilter == .mine || selectedFilter == .all {
      SectionCard(title: "My Incidents") {
        incidentsList(incidents: viewModel.myIncidents, emptyMessage: "No incidents assigned to you")
      }
      .padding(.horizontal, 16)
    }
  }
  
  /// Shows incidents in the user's location
  @ViewBuilder
  private var locationIncidentsSection: some View {
    if selectedFilter == .location || selectedFilter == .all {
      SectionCard(title: "Location Incidents") {
        incidentsList(incidents: viewModel.locationIncidents, emptyMessage: "No location incidents reported")
      }
      .padding(.horizontal, 16)
    }
  }
  
  /// Shows incidents filtered by status (open, in progress, etc.)
  @ViewBuilder
  private var statusFilteredIncidentsSection: some View {
    if selectedFilter == .open || selectedFilter == .inProgress {
      let filteredIncidents = getFilteredIncidentsByStatus()
      
      SectionCard(title: "\(selectedFilter.rawValue) Incidents") {
        incidentsList(
          incidents: filteredIncidents,
          emptyMessage: "No \(selectedFilter.rawValue.lowercased()) incidents"
        )
      }
      .padding(.horizontal, 16)
    }
  }
  
  /// Reusable list of incidents with empty state handling
  private func incidentsList(incidents: [Incident], emptyMessage: String) -> some View {
    VStack(spacing: 8) {
      if incidents.isEmpty {
        Text(emptyMessage)
          .font(.subheadline)
          .foregroundColor(Color("SecondaryText"))
          .padding()
      } else {
        ForEach(incidents) { incident in
          IncidentCard(incident: incident)
        }
      }
    }
  }
  
  /// Helper method to filter incidents by status
  private func getFilteredIncidentsByStatus() -> [Incident] {
    return (viewModel.myIncidents + viewModel.locationIncidents).filter {
      switch selectedFilter {
      case .open: return $0.status == .open
      case .inProgress: return $0.status == .inProgress
      default: return true
      }
    }
  }
}

enum IncidentFilter: String, CaseIterable {
  case all = "All"
  case mine = "Mine"
  case location = "Location"
  case open = "Open"
  case inProgress = "Pending"
}

// MARK: - Previews

#Preview("Incidents View") {
  IncidentsView()
}

// Specialized previews for each filter type
struct IncidentsFilters_Previews: PreviewProvider {
  static var previews: some View {
    ForEach(IncidentFilter.allCases, id: \.self) { filter in
      NavigationStack {
        IncidentsFilterPreview(filter: filter)
      }
      .previewDisplayName("\(filter.rawValue) Filter")
    }
  }
}

// Helper view for previewing different filter states
struct IncidentsFilterPreview: View {
  let filter: IncidentFilter
  @StateObject private var viewModel = HomeViewModel()
  
  var body: some View {
    VStack(spacing: 0) {
      // Filter picker (locked to specific filter for preview)
      Picker("Filter", selection: .constant(filter)) {
        ForEach(IncidentFilter.allCases, id: \.self) { filter in
          Text(filter.rawValue)
        }
      }
      .pickerStyle(.segmented)
      .padding(.horizontal)
      .padding(.top, 8)
      
      // Main content
      ScrollView {
        VStack(spacing: 16) {
          filterSpecificContent
          Spacer(minLength: 20)
        }
        .padding(.vertical, 16)
      }
    }
    .navigationTitle("Incidents")
  }
  
  // Show only the content relevant to the selected filter
  @ViewBuilder
  private var filterSpecificContent: some View {
    switch filter {
    case .all:
      allContent
    case .mine:
      myIncidentsContent
    case .location:
      locationIncidentsContent
    case .open, .inProgress:
      statusFilteredContent
    }
  }
  
  private var allContent: some View {
    VStack(spacing: 16) {
      myIncidentsContent
      locationIncidentsContent
    }
  }
  
  private var myIncidentsContent: some View {
    SectionCard(title: "My Incidents") {
      incidentsList(incidents: viewModel.myIncidents, emptyMessage: "No incidents assigned to you")
    }
    .padding(.horizontal, 16)
  }
  
  private var locationIncidentsContent: some View {
    SectionCard(title: "Location Incidents") {
      incidentsList(incidents: viewModel.locationIncidents, emptyMessage: "No location incidents reported")
    }
    .padding(.horizontal, 16)
  }
  
  private var statusFilteredContent: some View {
    let filteredIncidents = (viewModel.myIncidents + viewModel.locationIncidents).filter {
      switch filter {
      case .open: return $0.status == .open
      case .inProgress: return $0.status == .inProgress
      default: return false
      }
    }
    
    return SectionCard(title: "\(filter.rawValue) Incidents") {
      incidentsList(
        incidents: filteredIncidents,
        emptyMessage: "No \(filter.rawValue.lowercased()) incidents"
      )
    }
    .padding(.horizontal, 16)
  }
  
  /// Reusable list of incidents with empty state handling
  private func incidentsList(incidents: [Incident], emptyMessage: String) -> some View {
    VStack(spacing: 8) {
      if incidents.isEmpty {
        Text(emptyMessage)
          .font(.subheadline)
          .foregroundColor(Color("SecondaryText"))
          .padding()
      } else {
        ForEach(incidents) { incident in
          IncidentCard(incident: incident)
        }
      }
    }
  }
}
