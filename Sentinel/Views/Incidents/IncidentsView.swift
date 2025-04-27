import SwiftUI

struct IncidentsView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedFilter: IncidentFilter = .all
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter picker
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(IncidentFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // My Incidents Section
                        if selectedFilter == .mine || selectedFilter == .all {
                            SectionCard(title: "My Incidents") {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.myIncidents) { incident in
                                        IncidentCard(incident: incident)
                                    }
                                    
                                    if viewModel.myIncidents.isEmpty {
                                        Text("No incidents assigned to you")
                                            .font(.subheadline)
                                            .foregroundColor(Color("SecondaryText"))
                                            .padding()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Team Incidents Section
                        if selectedFilter == .team || selectedFilter == .all {
                            SectionCard(title: "Team Incidents") {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.teamIncidents) { incident in
                                        IncidentCard(incident: incident)
                                    }
                                    
                                    if viewModel.teamIncidents.isEmpty {
                                        Text("No team incidents reported")
                                            .font(.subheadline)
                                            .foregroundColor(Color("SecondaryText"))
                                            .padding()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Status-based filtering
                        if selectedFilter == .open || selectedFilter == .inProgress || selectedFilter == .resolved {
                            let filteredIncidents = (viewModel.myIncidents + viewModel.teamIncidents).filter { 
                                switch selectedFilter {
                                case .open: return $0.status == .open
                                case .inProgress: return $0.status == .inProgress
                                case .resolved: return $0.status == .resolved
                                default: return true
                                }
                            }
                            
                            SectionCard(title: "\(selectedFilter.rawValue) Incidents") {
                                VStack(spacing: 8) {
                                    ForEach(filteredIncidents) { incident in
                                        IncidentCard(incident: incident)
                                    }
                                    
                                    if filteredIncidents.isEmpty {
                                        Text("No \(selectedFilter.rawValue.lowercased()) incidents")
                                            .font(.subheadline)
                                            .foregroundColor(Color("SecondaryText"))
                                            .padding()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("Incidents")
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
}

enum IncidentFilter: String, CaseIterable {
    case all = "All"
    case mine = "Mine"
    case team = "Team"
    case open = "Open"
    case inProgress = "In Progress"
    case resolved = "Resolved"
}

#Preview {
    IncidentsView()
}