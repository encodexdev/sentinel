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
                    
                    // Appearance Settings
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        AppearancePicker(selection: Binding(
                            get: { vm.appearanceStyle },
                            set: { vm.updateAppearanceStyle($0) }
                        ))
                        .padding(.horizontal)
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
                            HStack {
                                Spacer()
                                Button(role: .destructive) {
                                    // TODO: sign out
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.backward.circle")
                                        Text("Sign Out").bold()
                                    }
                                    .foregroundColor(Color("StatusOpen"))
                                }
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
                .padding(.top)
            }
            // Global background handled by SentinelApp
            .navigationTitle("Profile & Settings")
            .onAppear {
                // Update the view model with the environment's settings manager
                vm.updateSettingsManager(settingsManager)
            }
        }
    }
}
