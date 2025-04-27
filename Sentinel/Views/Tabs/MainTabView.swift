import LucideIcons
import SwiftUI
import UIKit

/// Extension to resize UIImages properly
extension UIImage {
  func resized(to size: CGSize) -> UIImage {
    return UIGraphicsImageRenderer(size: size).image { _ in
      draw(in: CGRect(origin: .zero, size: size))
    }
  }
}

struct MainTabView: View {
  private let iconSize: CGFloat = 28
  @StateObject private var tabState = TabState.shared

  var body: some View {
    TabView(selection: $tabState.selectedTab) {
      HomeView()
        .tag(TabSelection.home.rawValue)
        .tabItem {
          LucideIcon(icon: Lucide.house, size: iconSize)
          Text("Home")
        }

      ChatView()
        .tag(TabSelection.report.rawValue)
        .tabItem {
          LucideIcon(icon: Lucide.messageSquareWarning, size: iconSize)
          Text("Report")
        }

      MapView()
        .tag(TabSelection.map.rawValue)
        .tabItem {
          LucideIcon(icon: Lucide.mapPin, size: iconSize)
          Text("Map")
        }

      IncidentsView()
        .tag(TabSelection.incidents.rawValue)
        .tabItem {
          LucideIcon(icon: Lucide.clipboard, size: iconSize)
          Text("Incidents")
        }
    }
  }
}
