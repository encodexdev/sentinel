import SwiftUI

struct ProfileSideView: View {
    @Binding var isShowing: Bool
    @State private var showSettings = false
    @EnvironmentObject var settingsManager: SettingsManager
    
    private let sideMenuWidth: CGFloat = 300
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Semi-transparent background
            if isShowing {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }
            }
            
            // Profile Side Panel
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    // Header with close button
                    HStack {
                        Text("Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        // Settings button
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gear")
                                .font(.title3)
                                .foregroundColor(Color("PrimaryText"))
                        }
                        
                        // Close button
                        Button {
                            withAnimation {
                                isShowing = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(Color("PrimaryText"))
                        }
                        .padding(.leading, 8)
                    }
                    .padding()
                    
                    Divider()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // User profile card
                            VStack(spacing: 16) {
                                // Avatar
                                AvatarView(name: TestData.user.fullName)
                                    .frame(width: 80, height: 80)
                                
                                // User info
                                VStack(spacing: 4) {
                                    Text(TestData.user.fullName)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    
                                    Text(TestData.user.role)
                                        .font(.subheadline)
                                        .foregroundColor(Color("SecondaryText"))
                                    
                                    DutyBadgeView(onDuty: TestData.user.isOnDuty)
                                        .padding(.top, 4)
                                }
                            }
                            .padding()
                            .background(Color("CardBackground"))
                            .cornerRadius(12)
                            
                            // Quick actions
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Quick Actions")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                Button {
                                    // Toggle duty status action
                                } label: {
                                    Label(
                                        TestData.user.isOnDuty ? "End Shift" : "Start Shift",
                                        systemImage: "clock"
                                    )
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color("CardBackground"))
                                    .cornerRadius(10)
                                }
                                
                                Button {
                                    // Notification center
                                } label: {
                                    Label("Notification Center", systemImage: "bell")
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color("CardBackground"))
                                        .cornerRadius(10)
                                }
                                
                                Button {
                                    // Help action
                                } label: {
                                    Label("Help & Support", systemImage: "questionmark.circle")
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                        .background(Color("CardBackground"))
                                        .cornerRadius(10)
                                }
                            }
                            
                            Spacer()
                            
                            // Sign out button
                            Button(role: .destructive) {
                                // Sign out action
                            } label: {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(Color("StatusOpen"))
                                    .background(Color("StatusOpen").opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                }
                .frame(width: sideMenuWidth)
                .background(Color("Background"))
                .offset(x: isShowing ? 0 : sideMenuWidth)
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .ignoresSafeArea()
    }
}

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var appearanceStyle: AppearanceStyle = .system
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Appearance Settings
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        AppearancePicker(selection: Binding(
                            get: { appearanceStyle },
                            set: { style in
                                appearanceStyle = style
                                settingsManager.setColorScheme(style.toColorScheme())
                            }
                        ))
                        .padding(.horizontal)
                    }
                    
                    // App Settings
                    VStack(spacing: 16) {
                        settingSection(title: "App Settings") {
                            // Notifications Toggle
                            Toggle(isOn: Binding(
                                get: { settingsManager.settings.notificationsEnabled },
                                set: { newValue in
                                    var updatedSettings = settingsManager.settings
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
                                get: { settingsManager.settings.locationEnabled },
                                set: { newValue in
                                    var updatedSettings = settingsManager.settings
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
                        }
                        
                        // Account Settings
                        settingSection(title: "Account Settings") {
                            navigationButton(
                                title: "Email & Password",
                                subtitle: "Update your login credentials",
                                icon: "envelope"
                            )
                            
                            navigationButton(
                                title: "Security",
                                subtitle: "2FA and security settings",
                                icon: "lock"
                            )
                        }
                        
                        // Payment Settings
                        settingSection(title: "Payment Settings") {
                            navigationButton(
                                title: "Payment Methods",
                                subtitle: "Manage your payment options",
                                icon: "creditcard"
                            )
                            
                            navigationButton(
                                title: "Billing History",
                                subtitle: "View past transactions",
                                icon: "doc.plaintext"
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.top)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initialize with current settings
                appearanceStyle = AppearanceStyle.fromColorScheme(
                    settingsManager.settings.preferredColorScheme
                )
            }
        }
    }
    
    private func settingSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 16) {
                content()
            }
            .padding()
            .background(Color("CardBackground"))
            .cornerRadius(12)
        }
    }
    
    private func navigationButton(title: String, subtitle: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24, height: 24)
                .foregroundColor(Color("SecondaryText"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline).bold()
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color("SecondaryText"))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color("SecondaryText"))
        }
    }
}

#Preview {
    ProfileSideView(isShowing: .constant(true))
        .environmentObject(SettingsManager())
}