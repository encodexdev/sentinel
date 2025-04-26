import SwiftUI

struct ProfileIcon: View {
    let user: User
    @State private var showingProfileView = false
    
    var body: some View {
        Button {
            showingProfileView = true
        } label: {
            if let avatarImage = user.getAvatarImage() {
                avatarImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color("AccentBlue").opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(initials)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )
            }
        }
        .navigationDestination(isPresented: $showingProfileView) {
            ProfileView()
                .environmentObject(SettingsManager())
        }
    }
    
    private var initials: String {
        let parts = user.fullName.split(separator: " ")
        return parts.compactMap { $0.first }.prefix(2).map(String.init).joined()
    }
}

#Preview {
    NavigationStack {
        ProfileIcon(user: TestData.user)
    }
}