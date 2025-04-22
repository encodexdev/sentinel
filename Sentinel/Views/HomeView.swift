//
//  HomeView.swift
//  Sentinel
//
//  Created by Cameron Faith on 2025-04-21.
//

import SwiftUI

struct HomeView: View {
  @StateObject private var vm = HomeViewModel()

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {
          // Greeting Header
          VStack(alignment: .leading, spacing: 4) {
            Text("Welcome, \(TestData.user.fullName.split(separator: " ").first ?? "")")
              .font(.largeTitle)
              .fontWeight(.bold)
            Text("Shift started at 8:00 AM")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal)

          // Report Button
          Button {
            // TODO: navigate to ChatView
          } label: {
            Label("Report New Incident", systemImage: "exclamationmark.bubble")
              .font(.headline)
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color.accentColor)
              .foregroundColor(.white)
              .cornerRadius(8)
              .padding(.horizontal)
          }

          // My Incidents
          VStack(alignment: .leading, spacing: 8) {
            Text("My Incidents")
              .font(.title2)
              .fontWeight(.semibold)
              .padding(.horizontal)
            ForEach(vm.myIncidents) { incident in
              IncidentRow(incident: incident)
            }
          }

          // Team Incidents
          VStack(alignment: .leading, spacing: 8) {
            Text("Team Incidents")
              .font(.title2)
              .fontWeight(.semibold)
              .padding(.horizontal)
            ForEach(vm.teamIncidents) { incident in
              IncidentRow(incident: incident)
            }
          }
        }
        .padding(.vertical)
      }
      .navigationTitle("Home")
    }
  }
}

struct IncidentRow: View {
  let incident: Incident

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(incident.title)
          .font(.headline)
        Text(incident.location)
          .font(.caption)
          .foregroundColor(.secondary)
      }
      Spacer()
      Text(incident.status.rawValue)
        .font(.caption2)
        .padding(6)
        .background(statusColor)
        .foregroundColor(statusColor)
        .clipShape(Capsule())
    }
    .padding(.horizontal)
    .padding(.vertical, 8)
  }

  private var statusColor: Color {
    switch incident.status {
    case .open: return .red
    case .inProgress: return .orange
    case .resolved: return .green
    }
  }
}

#Preview {
  HomeView()
}
