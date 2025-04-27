import LucideIcons
import SwiftUI

struct IncidentPin: View {
    private let iconSize: CGFloat = 24
    let status: IncidentStatus
    let dropped: Bool

    // MARK: — Animation state
    @State private var pulsing = false
    @State private var yOffset: CGFloat = -20
    @State private var pinOpacity: Double = 0

    var iconColor: Color {
        switch status {
        case .resolved:   return .gray
        case .inProgress: return .green
        case .open:       return .orange
        }
    }

    var body: some View {
        ZStack {
            // glowing halo
            Circle()
                .fill(iconColor)
                .frame(width: 36, height: 36)
                .blur(radius: 12)
                .opacity(0.4)
                .scaleEffect(pulsing ? 1.1 : 0.8)

            // white inner circle
            Circle()
                .fill(Color.white)
                .frame(width: 32, height: 32)

            // icon
            LucideIcon.shieldUser(
                size: iconSize,
                color: iconColor
            )
        }
        .offset(y: yOffset)
        .opacity(pinOpacity)
        .onAppear {
            // start the pulsing glow
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                pulsing.toggle()
            }
            // if already dropped, trigger the drop+fade
            if dropped {
                withAnimation(.easeOut(duration: 1.2)) {
                    yOffset = 0
                    pinOpacity = 1
                }
            }
        }
        .onChange(of: dropped) {
            // animate drop & fade-in when `dropped` flips to true
            withAnimation(.easeOut(duration: 1.0)) {
                yOffset = 0
                pinOpacity = 1
            }
        }
    }
}

struct IncidentPin_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            IncidentPin(status: .inProgress, dropped: true)
            IncidentPin(status: .resolved,   dropped: true)
            IncidentPin(status: .open,       dropped: true)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .previewLayout(.sizeThatFits)
    }
}
