import SwiftUI

struct ProfileView: View {
    // Get the global settings manager from the environment
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var vm = ProfileViewModel(settingsManager: SettingsManager())
    
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
                                    .foregroundColor(Color("SecondaryText"))
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
                            Toggle(isOn: Binding(
                                get: { vm.settings.notificationsEnabled },
                                set: { newValue in
                                    var updatedSettings = vm.settings
                                    updatedSettings.notificationsEnabled = newValue
                                    settingsManager.settings = updatedSettings
                                }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Notifications")
                                        .font(.subheadline).bold()
                                    Text("Receive alerts and updates")
                                        .font(.caption)
                                        .foregroundColor(Color("SecondaryText"))
                                }
                            }
                            
                            // Follow System Toggle
                            Toggle(isOn: $vm.followSystem) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Use System Appearance")
                                        .font(.subheadline).bold()
                                    Text("Match your device settings")
                                        .font(.caption)
                                        .foregroundColor(Color("SecondaryText"))
                                }
                            }
                            .onChange(of: vm.followSystem) { follow in
                                vm.toggleFollowSystem(follow)
                            }
                            
                            // Dark Mode Toggle (only shown if not following system)
                            if !vm.followSystem {
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
                                            .foregroundColor(Color("SecondaryText"))
                                    }
                                }
                            }
                            
                            // Location Toggle
                            Toggle(isOn: Binding(
                                get: { vm.settings.locationEnabled },
                                set: { newValue in
                                    var updatedSettings = vm.settings
                                    updatedSettings.locationEnabled = newValue
                                    settingsManager.settings = updatedSettings
                                }
                            )) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Location Services")
                                        .font(.subheadline).bold()
                                    Text("Allow location tracking when on duty")
                                        .font(.caption)
                                        .foregroundColor(Color("SecondaryText"))
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                            
                            // Sign Out
                            Button(role: .destructive) {
                                // TODO: sign out
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.backward.circle")
                                    Text("Sign Out").bold()
                                }
                                .foregroundColor(Color("StatusOpen"))
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Profile & Settings")
            .onAppear {
                // Update the view model with the environment's settings manager
                vm.updateSettingsManager(settingsManager)
            }
        }
    }
}