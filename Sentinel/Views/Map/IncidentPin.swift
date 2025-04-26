import SwiftUI

struct IncidentPin: View {
    let status: IncidentStatus
    let dropped: Bool

    @State private var pulsing = false

    // Initial vertical offset before drop
    @State private var yOffset: CGFloat = -20

    var iconColor: Color {
        switch status {
        case .resolved: return .gray
        case .inProgress: return .green
        case .open: return .orange
        }
    }

    var body: some View {
        ZStack {
            // glowing halo
            Circle()
                .fill(iconColor)
                .frame(width: 50, height: 50)
                .blur(radius: 12)
                .opacity(0.4)
                .scaleEffect(pulsing ? 1.1 : 0.8)

            // white inner circle
            Circle()
                .fill(Color.white)
                .frame(width: 36, height: 36)

            // person icon
            Image(systemName: "person.fill")
                .font(.title2)
                .foregroundColor(iconColor)
        }
        .offset(y: yOffset)
        .opacity(dropped ? 1 : 0)
        .scaleEffect(dropped ? 1 : 0, anchor: .center)
        .onAppear {
            // start pulsing glow
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                pulsing.toggle()
            }
            // animate drop
            withAnimation(.easeOut(duration: 0.6)) {
                yOffset = 0
            }
        }
    }
}

struct IncidentPin_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            IncidentPin(status: .inProgress, dropped: true)
            IncidentPin(status: .resolved, dropped: true)
            IncidentPin(status: .open, dropped: true)
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
