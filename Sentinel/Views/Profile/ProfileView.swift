import SwiftUI

struct ProfileView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var showingSettings = false
  @StateObject private var vm = ProfileViewModel(settingsManager: SettingsManager())
  @EnvironmentObject var settingsManager: SettingsManager

  // Sample stats data
  private let incidentsCount = 32
  private let patrolsCount = 57
  private let feedbackScore = 4.8

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        // Profile header
        VStack(spacing: 16) {
          // Avatar with rating badge
          ZStack(alignment: .bottomTrailing) {
            if let avatarImage = vm.user.getAvatarImage() {
              avatarImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            } else if let avatarURL = vm.user.avatarURL {
              AsyncImage(url: avatarURL) { image in
                image
                  .resizable()
                  .aspectRatio(contentMode: .fill)
              } placeholder: {
                Color.gray.opacity(0.3)
              }
              .frame(width: 120, height: 120)
              .clipShape(Circle())
            } else {
              Circle()
                .fill(Color("AccentBlue").opacity(0.3))
                .frame(width: 120, height: 120)
                .overlay(
                  Text(initials)
                    .font(.title)
                    .foregroundColor(.white)
                )
            }

            // Rating badge
            HStack(spacing: 2) {
              Image(systemName: "star.fill")
                .foregroundColor(.white)
                .font(.caption)

              Text(String(format: "%.1f", feedbackScore))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .offset(x: 8, y: 8)
          }

          // User info
          VStack(spacing: 4) {
            Text(vm.user.fullName)
              .font(.title2)
              .fontWeight(.bold)

            Text(vm.user.role)
              .font(.subheadline)
              .foregroundColor(Color("SecondaryText"))
          }
        }
        .padding(.top, 20)

        Divider()

        // Activity Summary
        VStack(alignment: .leading, spacing: 20) {
          Text("Activity Summary")
            .font(.headline)
            .padding(.horizontal, 16)

          HStack(spacing: 16) {
            // Incidents
            statCard(title: "Incidents", value: "\(incidentsCount)")

            // Patrols
            statCard(title: "Patrols", value: "\(patrolsCount)")
          }
          .padding(.horizontal, 16)
        }

        Divider()

        // Account Information
        VStack(alignment: .leading, spacing: 20) {
          Text("Account Information")
            .font(.headline)
            .padding(.horizontal, 16)

          infoRow(label: "Email", value: vm.user.email)

          Divider()

          infoRow(label: "Phone\nNumber", value: vm.user.phoneNumber)

          Divider()

          infoRow(label: "Start Date", value: vm.user.startDate)
        }

        Divider()

        // Payment History
        VStack(alignment: .leading, spacing: 16) {
          Text("Payments")
            .font(.headline)
            .padding(.horizontal, 16)

          // Payment History button with chevron
          Button {
            // TODO: Show payment history
          } label: {
            HStack {
              Text("Payment History")
                .font(.subheadline)
                .foregroundColor(Color("PrimaryText"))

              Spacer()

              Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color("SecondaryText"))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal, 16)
          }
        }

        // Logout Button
        Button {
          // TODO: Implement logout functionality
        } label: {
          Text("Logout")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 32)
      }
    }
    .navigationTitle("Profile")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          showingSettings = true
        } label: {
          Image(systemName: "gearshape")
            .foregroundColor(Color("PrimaryText"))
        }
      }
    }
    .sheet(isPresented: $showingSettings) {
      SettingsView()
    }
    .onAppear {
      // Update the view model with the environment's settings manager
      vm.updateSettingsManager(settingsManager)
    }
  }

  private var initials: String {
    let parts = vm.user.fullName.split(separator: " ")
    return parts.compactMap { $0.first }.prefix(2).map(String.init).joined()
  }

  private func infoRow(label: String, value: String) -> some View {
    HStack(alignment: .top) {
      Text(label)
        .font(.subheadline)
        .foregroundColor(Color("SecondaryText"))
        .frame(width: 80, alignment: .leading)

      Spacer()

      Text(value)
        .font(.subheadline)
        .multilineTextAlignment(.trailing)
    }
    .padding(.horizontal, 16)
  }

  private func statCard(title: String, value: String) -> some View {
    VStack(spacing: 8) {
      Text(title)
        .font(.headline)
        .foregroundColor(Color("SecondaryText"))

      Text(value)
        .font(.title)
        .fontWeight(.bold)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.gray.opacity(0.1))
    .cornerRadius(12)
  }
}

#Preview {

  NavigationStack {
    ProfileView()
      .environmentObject(SettingsManager())
  }
}
