import SwiftUI

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
