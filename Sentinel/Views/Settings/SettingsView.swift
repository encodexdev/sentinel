import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var settingsManager: SettingsManager
  @StateObject private var viewModel = SettingsViewModel(settingsManager: SettingsManager())

  var body: some View {
    NavigationStack {
      List {
        Section("Account") {
          NavigationLink {
            Text("Change email form would go here")
          } label: {
            Text("Change Email")
          }
          NavigationLink {
            Text("Password update form would go here")
          } label: {
            Text("Update Password")
          }
        }

        Section("Payments") {
          NavigationLink {
            Text("Payment methods would go here")
          } label: {
            Text("Payment Methods")
          }
          NavigationLink {
            Text("Billing history would go here")
          } label: {
            Text("Billing History")
          }
        }

        Section("Appearance") {
          Picker(
            "Theme",
            selection: Binding(
              get: { viewModel.appearanceStyle },
              set: { viewModel.updateTheme(to: $0) }
            )
          ) {
            ForEach(AppearanceStyle.allCases) { style in
              Text(style.rawValue).tag(style)
            }
          }
          .pickerStyle(.menu)
          NavigationLink {
            Text("Language settings would go here")
          } label: {
            HStack {
              Text("Language")
              Spacer()
              Text("English")
                .foregroundColor(.gray)
            }
          }
        }

        Section("Notifications") {
          Toggle(
            "Push Notifications",
            isOn: Binding(
              get: { viewModel.notificationsEnabled },
              set: { viewModel.toggleNotifications($0) }
            ))
          NavigationLink {
            Text("Notification preferences would go here")
          } label: {
            Text("Notification Preferences")
          }
        }

        Section("Privacy & Security") {
          NavigationLink {
            Text("Privacy settings would go here")
          } label: {
            Text("Privacy Settings")
          }
          NavigationLink {
            Text("Security settings would go here")
          } label: {
            Text("Security")
          }
          Toggle(
            "Location Services",
            isOn: Binding(
              get: { viewModel.locationEnabled },
              set: { viewModel.toggleLocation($0) }
            ))
        }
        Section {
          Button(role: .destructive) {
            // TODO: Handle account deactivation
          } label: {
            Text("Deactivate Account")
          }
        }
      }
      .navigationTitle("Settings")
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Done") { dismiss() }
        }
      }
      .onAppear {
        viewModel.updateSettingsManager(settingsManager)
      }
    }
  }
}
