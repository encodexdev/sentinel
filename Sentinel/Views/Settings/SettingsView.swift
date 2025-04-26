import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settingsManager: SettingsManager
    @StateObject private var vm = SettingsViewModel(settingsManager: SettingsManager())
    
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
                    // Appearance Mode Picker - Dropdown Style
                    Picker("Theme", selection: $vm.appearanceMode) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    
                    // Language Picker
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
                    Toggle(isOn: $vm.notificationsEnabled) {
                        Text("Push Notifications")
                    }
                    
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
                    
                    Toggle(isOn: $vm.locationEnabled) {
                        Text("Location Services")
                    }
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .onAppear {
                // Update the view model with the shared environment settings manager
                vm.updateSettingsManager(settingsManager)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager())
}
