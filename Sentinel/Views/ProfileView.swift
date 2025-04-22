//
//  ProfileView.swift
//  Sentinel
//
//  Created by Cameron Faith on 2025-04-21.
//

import SwiftUI

struct ProfileView: View {
  @StateObject private var vm = ProfileViewModel()

  var body: some View {
    NavigationStack {
      List {
        // MARK: User Header
        VStack(alignment: .leading, spacing: 8) {
          HStack(spacing: 16) {
            // Placeholder avatar
            Circle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 64, height: 64)
              .overlay(
                Text(vm.user.fullName.prefix(2))
                  .font(.headline)
                  .foregroundColor(.white)
              )

            VStack(alignment: .leading, spacing: 4) {
              Text(vm.user.fullName)
                .font(.title3)
                .fontWeight(.semibold)
              Text(vm.user.role)
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            Spacer()
            // Duty badge
            Text(vm.user.isOnDuty ? "On Duty" : "Off Duty")
              .font(.caption2)
              .padding(6)
              .background(vm.user.isOnDuty ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
              .foregroundColor(vm.user.isOnDuty ? .green : .red)
              .clipShape(Capsule())
          }
          .padding(.vertical, 8)
        }
        .listRowInsets(EdgeInsets())

        // MARK: App Settings Section
        Section("App Settings") {
          Toggle(
            isOn: Binding(
              get: { vm.settings.preferredColorScheme == .dark },
              set: vm.toggleDarkMode(_:))
          ) {
            VStack(alignment: .leading) {
              Text("Dark Mode")
              Text("Easier on the eyes at night")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }

          // MARK: Sign out
          Section {
            Button(role: .destructive) {
              // TODO: hook up sign out
            } label: {
              Label("Sign Out", systemImage: "arrow.backward.circle")
            }
          }
        }
        .navigationTitle("Profile & Settings")
      }
    }
  }
}

#Preview {
  ProfileView()
}
