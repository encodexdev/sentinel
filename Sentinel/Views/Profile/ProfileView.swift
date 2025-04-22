import SwiftUI

// MARK: - DutyBadgeView

struct DutyBadgeView: View {
  let onDuty: Bool

  var body: some View {
    Text(onDuty ? "On Duty" : "Off Duty")
      .font(.caption)
      .bold()
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(onDuty ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
      .foregroundColor(onDuty ? .green : .red)
      .clipShape(Capsule())
  }
}

// MARK: - CardContainer

struct CardContainer<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding()
      .background(Color("CardBackground"))
      .cornerRadius(12)
      .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 4)
      .padding(.horizontal)
  }
}

// MARK: - ProfileView

struct ProfileView: View {
  @StateObject private var vm = ProfileViewModel()

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 24) {

          // User Header
          CardContainer {
            HStack(spacing: 16) {
              AvatarView(name: vm.user.fullName)

              VStack(alignment: .leading, spacing: 4) {
                Text(vm.user.fullName)
                  .font(.title3).bold()
                Text(vm.user.role)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }

              Spacer()

              DutyBadgeView(onDuty: vm.user.isOnDuty)
            }
          }

          // App Settings
          CardContainer {
            VStack(alignment: .leading, spacing: 16) {
              Text("App Settings")
                .font(.headline)

              // Notifications Toggle
              Toggle(isOn: $vm.settings.notificationsEnabled) {
                VStack(alignment: .leading, spacing: 2) {
                  Text("Notifications")
                    .font(.subheadline).bold()
                  Text("Receive alerts and updates")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
              }

              // Dark Mode Toggle
              Toggle(
                isOn: Binding(
                  get: { vm.settings.preferredColorScheme == .dark },
                  set: { vm.toggleDarkMode($0) })
              ) {
                VStack(alignment: .leading, spacing: 2) {
                  Text("Dark Mode")
                    .font(.subheadline).bold()
                  Text("Easier on the eyes at night")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
              }

              // Sign Out
              Button(role: .destructive) {
                // TODO: sign out
              } label: {
                HStack {
                  Image(systemName: "arrow.backward.circle")
                  Text("Sign Out").bold()
                }
                .foregroundColor(.red)
              }
            }
          }

          Spacer(minLength: 20)
        }
        .padding(.top)
      }
      .background(Color("Background").ignoresSafeArea())
      .navigationTitle("Profile & Settings")
    }
  }
}
