import SwiftUI

struct MainTabView: View {
  var body: some View {
    TabView {
      HomeView()
        .tabItem { Label("Home", systemImage: "shield") }

      ChatView()
        .tabItem { Label("Chat", systemImage: "message") }

      MapView()
        .tabItem { Label("Map", systemImage: "map") }

      ProfileView()
        .tabItem { Label("Profile", systemImage: "person.crop.circle") }
    }
  }
}
