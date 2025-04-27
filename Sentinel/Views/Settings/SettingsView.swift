import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject var settingsManager: SettingsManager
  private var viewModel: SettingsViewModel
  
  init() {
    // Create a temporary view model that will be replaced in onAppear
    self.viewModel = SettingsViewModel(settingsManager: SettingsManager())
  }
  
  init(viewModel: SettingsViewModel) {
    self.viewModel = viewModel
  }

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
            selection: viewModel.appearanceStyle
          ) {
            ForEach(AppearanceStyle.allCases) { style in
              Text(style.rawValue).tag(style)
                .accessibilityIdentifier(style.rawValue)
            }
          }
          .pickerStyle(.menu)
          .accessibilityIdentifier("themePicker")
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
            isOn: viewModel.notificationsEnabled)
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
            isOn: viewModel.locationEnabled)
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
    }
  }
}
