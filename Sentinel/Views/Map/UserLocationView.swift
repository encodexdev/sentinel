import SwiftUI

// MARK: - UserLocationView

struct UserLocationView: View {
    // MARK: - Properties
    
    /// Map camera heading from the view model
    var cameraHeading: Double
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // MARK: Pulsing Circle
            Circle()
                .fill(Color.accentColor.opacity(0.3))
                .frame(width: 36, height: 36)
                .modifier(PulseEffect())
            
            // MARK: Direction Indicator 
            Image(systemName: "location.north.fill")
                .font(.title3)
                .foregroundColor(.accentColor)
                .background(
                    Circle()
                        .fill(.white)
                        .frame(width: 32, height: 32)
                )
                .rotationEffect(.degrees(-cameraHeading))
        }
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 20) {
        UserLocationView(cameraHeading: 0)
            .previewDisplayName("North Heading")
        
        UserLocationView(cameraHeading: 45)
            .previewDisplayName("Northeast Heading")
            
        UserLocationView(cameraHeading: 90)
            .previewDisplayName("East Heading")
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
