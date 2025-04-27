import SwiftUI

/// A view modifier that creates a pulsing glow effect
struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .fill(Color.accentColor.opacity(0.3))
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0.0 : 0.5)
            )
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}

extension View {
    func pulsatingGlow() -> some View {
        self.modifier(PulseEffect())
    }
}
