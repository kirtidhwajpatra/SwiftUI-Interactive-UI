import SwiftUI

struct SuccessView: View {
    let enteredAmount: String
    
    @State private var checkmarkProgress: CGFloat = 0
    @State private var successScale: CGFloat = 0
    @State private var successRingScale: CGFloat = 0
    @State private var glowOpacity: Double = 0
    @State private var showPaymentDetails: Bool = false
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var isBreathing: Bool = false
    @State private var isPulsing: Bool = false
    
    var body: some View {
        ZStack {
            // Confetti with coins
            ForEach(confettiParticles) { particle in
                if particle.size > 10 {
                    // Coin
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "FCD34D"), Color(hex: "F59E0B")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: particle.size, height: particle.size)
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "F59E0B"), lineWidth: 1.5)
                            )
                        
                        Image(systemName: "indianrupeesign")
                            .font(.system(size: particle.size * 0.5, weight: .bold))
                            .foregroundColor(Color(hex: "92400E"))
                    }
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
                    .rotationEffect(.degrees(particle.x * 2))
                } else {
                    // Regular confetti
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .offset(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .scaleEffect(particle.scale)
                }
            }
            
            VStack(spacing: 32) {
                // Success icon
                ZStack {
                    // Outer glow rings (pulsing)
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                Color.white.opacity(0.3 - Double(index) * 0.08),
                                lineWidth: 2
                            )
                            .frame(width: 120 + CGFloat(index) * 30, height: 120 + CGFloat(index) * 30)
                            .scaleEffect(successRingScale * (isPulsing ? 1.05 : 1.0))
                            .opacity(glowOpacity * (isPulsing ? 0.8 : 1.0))
                    }
                    
                    // Main success circle with shadow
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .scaleEffect(successScale * (isBreathing ? 1.03 : 1.0))
                        .shadow(color: Color.white.opacity(0.6), radius: 30, x: 0, y: 10)
                    
                    // Checkmark
                    CheckmarkShape(progress: checkmarkProgress)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "3B82F6"), Color(hex: "1E40AF")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                        )
                        .frame(width: 60, height: 60)
                        .scaleEffect(successScale * (isBreathing ? 1.03 : 1.0))
                }
                .offset(y: showPaymentDetails ? 0 : -500)
                .opacity(showPaymentDetails ? 1 : 0)
                
                // Payment success message
                if showPaymentDetails {
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("Payment Successful")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(.white)

                        }
                        
                        Text("₹\(enteredAmount)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .scaleEffect(isBreathing ? 1.05 : 1.0)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .onAppear {
            showSuccess()
        }
    }
    
    private func showSuccess() {
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        // Fancy slide-in from top with bounce
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            showPaymentDetails = true
        }
        
        // Scale in success circle
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.5)) {
            successScale = 1.0
        }
        
        // Glow rings expand
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.5)) {
            successRingScale = 1.0
            glowOpacity = 1.0
        }
        
        // Draw checkmark
        withAnimation(.easeOut(duration: 0.8).delay(0.7)) {
            checkmarkProgress = 1.0
        }
        
        // Confetti explosion with coins
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            createConfettiWithCoins()
        }
        
        // Fade out glow
        withAnimation(.easeOut(duration: 0.6).delay(1.5)) {
            glowOpacity = 0.0
        }
        
        // Start continuous breathing animations
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
    
    private func createConfettiWithCoins() {
        var particles: [ConfettiParticle] = []
        
        // Create 20 particles (mix of confetti and coins)
        for i in 0..<20 {
            let angle = Double(i) * (360.0 / 20.0) * .pi / 180
            let velocity = Double.random(in: 100...180)
            let isCoin = i % 4 == 0  // Every 4th particle is a coin
            let size = isCoin ? CGFloat.random(in: 14...18) : CGFloat.random(in: 5...8)
            
            let particle = ConfettiParticle(
                id: UUID(),
                x: cos(angle) * velocity * 0.4,
                y: sin(angle) * velocity * 0.4,
                color: isCoin ? Color(hex: "FCD34D") : [Color.white, Color(hex: "60A5FA"), Color(hex: "93C5FD")].randomElement()!,
                size: size,
                opacity: 1.0,
                scale: 1.0
            )
            particles.append(particle)
        }
        
        confettiParticles = particles
        
        // Animate confetti
        withAnimation(.easeOut(duration: 1.5)) {
            confettiParticles = confettiParticles.map { particle in
                var updated = particle
                updated.y += 250
                updated.opacity = 0
                updated.scale = 0.4
                return updated
            }
        }
        
        // Clear confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            confettiParticles.removeAll()
        }
    }
}
