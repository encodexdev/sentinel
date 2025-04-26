import SwiftUI
import LucideIcons
import UIKit

// Extension to resize UIImages properly
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

struct MainTabView: View {
    private let iconSize: CGFloat = 28
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(uiImage: Lucide.house.withRenderingMode(.alwaysTemplate)
                        .resized(to: CGSize(width: iconSize, height: iconSize)))
                    Text("Home")
                }

            ChatView()
                .tabItem {
                    Image(uiImage: Lucide.messageSquareWarning.withRenderingMode(.alwaysTemplate)
                        .resized(to: CGSize(width: iconSize, height: iconSize)))
                    Text("Report")
                }

            MapView()
                .tabItem {
                    Image(uiImage: Lucide.mapPin.withRenderingMode(.alwaysTemplate)
                        .resized(to: CGSize(width: iconSize, height: iconSize)))
                    Text("Map")
                }

            ProfileView()
                .tabItem {
                    Image(uiImage: Lucide.user.withRenderingMode(.alwaysTemplate)
                        .resized(to: CGSize(width: iconSize, height: iconSize)))
                    Text("Profile") 
                }
        }
    }
}
