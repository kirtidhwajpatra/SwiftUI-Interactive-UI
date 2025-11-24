//
//  ContentView.swift
//  Animation 02
//
//  Premium Payment Success Animation - Clean Minimal Design
//  Created by Uday on 24/11/25.
//

import SwiftUI

// MARK: - Payment State
enum PaymentState {
    case idle
    case processing
    case success
}

// MARK: - Main Content View
public struct ContentView: View {
    
    @State private var paymentState: PaymentState = .idle
    @State private var loadingRotation: Double = 0
    @State private var checkmarkProgress: CGFloat = 0
    @State private var successScale: CGFloat = 0
    @State private var successRingScale: CGFloat = 0
    @State private var glowOpacity: Double = 0
    @State private var amountOpacity: Double = 1.0
    @State private var coinRotation: Double = 0
    @State private var coinScale: CGFloat = 1.0
    @State private var gradientOffset: CGFloat = 0
    @State private var confettiParticles: [ConfettiParticle] = []
    @State private var showPaymentDetails: Bool = false
    
    // Payment amount
    private let paymentAmount: String = "₹9,999"
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Clean background
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: paymentState)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Animation container
                ZStack {
                    // Large amount display (idle state only)
                    if paymentState == .idle {
                        amountDisplay
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    if paymentState == .processing {
                        loadingAnimation
                            .transition(.scale.combined(with: .opacity))
                    } else if paymentState == .success {
                        successAnimation
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(width: 200, height: 200)
                .padding(.bottom, 60)
                
                // Status text
                statusText
                    .animation(.easeInOut(duration: 0.3), value: paymentState)
                
                Spacer()
                
                // Payment button
                paymentButton
                    .padding(.horizontal, 32)
                    .padding(.bottom, 60)
            }
        }
    }
    
    // MARK: - Amount Display
    
    private var amountDisplay: some View {
        VStack(spacing: 16) {
            // Rupee icon
            Image(systemName: "indianrupeesign.circle.fill")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "3B82F6").opacity(0.2), radius: 20, x: 0, y: 10)
            
            // Large amount
            Text(paymentAmount)
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "1F2937"), Color(hex: "4B5563")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .opacity(amountOpacity)
    }
    
    // MARK: - Background
    
    @ViewBuilder
    private var backgroundColor: some View {
        switch paymentState {
        case .idle:
            // Soft warm gray
            Color(hex: "FAFAFA")
        case .processing:
            // Subtle cool gray
            Color(hex: "F8F9FA")
        case .success:
            // Dynamic animated gradient
            successGradientBackground
        }
    }
    
    // MARK: - Success Gradient Background
    
    private var successGradientBackground: some View {
        ZStack {
            // Base gradient - multiple blue shades
            LinearGradient(
                colors: [
                    Color(hex: "3B82F6"),  // Blue
                    Color(hex: "2563EB"),  // Deeper blue
                    Color(hex: "1D4ED8")   // Even deeper
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Moving overlay gradient
            LinearGradient(
                colors: [
                    Color(hex: "60A5FA").opacity(0.7),  // Light blue
                    Color(hex: "3B82F6").opacity(0.5),  // Medium blue
                    Color(hex: "1E40AF").opacity(0.7)   // Dark blue
                ],
                startPoint: UnitPoint(x: 0, y: gradientOffset / 100),
                endPoint: UnitPoint(x: 1, y: 1 - gradientOffset / 100)
            )
            .blendMode(.overlay)
        }
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                gradientOffset = 100
            }
        }
    }
    
    // MARK: - Loading Animation
    
    private var loadingAnimation: some View {
        ZStack {
            // Outer rotating ring
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: "3B82F6"),
                            Color(hex: "3B82F6").opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(loadingRotation))
            
            // Inner counter-rotating ring
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(
                    Color(hex: "60A5FA").opacity(0.4),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 90, height: 90)
                .rotationEffect(.degrees(-loadingRotation * 1.3))
            
            // Orbiting coins (3 coins at different positions)
            ForEach(Array(0..<3), id: \.self) { index in
                let angle = .pi * 2 / 3 * Double(index) + loadingRotation * .pi / 180
                let xOffset = cos(angle) * 45
                let yOffset = sin(angle) * 45
                
                coinView
                    .offset(x: xOffset, y: yOffset)
                    .rotationEffect(.degrees(coinRotation + Double(index) * 120))
                    .scaleEffect(coinScale)
            }
            
            // Center pulsing dot
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "3B82F6"), Color(hex: "60A5FA")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 16, height: 16)
                .scaleEffect(1 + sin(loadingRotation * .pi / 180) * 0.2)
                .shadow(color: Color(hex: "3B82F6").opacity(0.3), radius: 8, x: 0, y: 0)
        }
        .onAppear {
            startLoadingAnimations()
        }
        .onChange(of: paymentState) { newState in
            if newState == .processing {
                startLoadingAnimations()
            }
        }
    }
    
    // MARK: - Start Loading Animations
    
    private func startLoadingAnimations() {
        // Reset rotation values first
        loadingRotation = 0
        coinRotation = 0
        coinScale = 1.0
        
        // Start animations
        withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
            loadingRotation = 360
        }
        withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
            coinRotation = 360
        }
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            coinScale = 1.15
        }
    }
    
    // MARK: - Coin View
    
    private var coinView: some View {
        ZStack {
            // Coin circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FCD34D"), Color(hex: "F59E0B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(Color(hex: "F59E0B"), lineWidth: 1.5)
                )
            
            // Rupee symbol on coin
            Image(systemName: "indianrupeesign")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(Color(hex: "92400E"))
        }
        .shadow(color: Color(hex: "F59E0B").opacity(0.4), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Success Animation
    
    private var successAnimation: some View {
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
            
            VStack(spacing: 0) {
                Spacer()
                
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
                                .scaleEffect(successRingScale)
                                .opacity(glowOpacity)
                        }
                        
                        // Main success circle with shadow
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                            .scaleEffect(successScale)
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
                            .scaleEffect(successScale)
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
                            
                            Text(paymentAmount)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
//                            Text("paid successfully")
//                                .font(.system(size: 16, weight: .regular))
//                                .foregroundColor(.white.opacity(0.9))
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Status Text
    
    private var statusText: some View {
        VStack(spacing: 12) {
            Text(statusTitle)
                .font(.system(size: 26, weight: .semibold, design: .default))
                .foregroundColor(titleColor)
            
            Text(statusSubtitle)
                .font(.system(size: 15, weight: .regular, design: .default))
                .foregroundColor(subtitleColor)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 50)
        }
    }
    
    private var titleColor: Color {
        switch paymentState {
        case .idle:
            return Color(hex: "1F2937")
        case .processing:
            return Color(hex: "3B82F6")
        case .success:
            return Color.white
        }
    }
    
    private var subtitleColor: Color {
        switch paymentState {
        case .success:
            return Color.white.opacity(0.9)
        default:
            return Color(hex: "6B7280")
        }
    }
    
    private var statusTitle: String {
        switch paymentState {
        case .idle:
            return "Rajesh Kumar"
        case .processing:
            return "Processing Payment"
        case .success:
            return ""
        }
    }
    
    private var statusSubtitle: String {
        switch paymentState {
        case .idle:
            return "rajesh.kumar@upi\nPayment to merchant"
        case .processing:
            return "Please wait while we confirm\nyour transaction"
        case .success:
            return ""
        }
    }
    
    // MARK: - Payment Button
    
    private var paymentButton: some View {
        Button(action: handlePayment) {
            HStack(spacing: 10) {
                if paymentState == .processing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else if paymentState == .success {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "3B82F6"))
                }
                
                Text(buttonTitle)
                    .font(.system(size: 17, weight: .semibold, design: .default))
                    .foregroundColor(buttonTextColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(buttonBackground)
            .cornerRadius(12)
            .shadow(color: buttonShadowColor, radius: 12, x: 0, y: 4)
        }
        .disabled(paymentState != .idle)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: paymentState)
    }
    
    private var buttonTitle: String {
        switch paymentState {
        case .idle:
            return "Pay \(paymentAmount)"
        case .processing:
            return "Processing..."
        case .success:
            return "Payment Complete"
        }
    }
    
    @ViewBuilder
    private var buttonBackground: some View {
        switch paymentState {
        case .idle:
            LinearGradient(
                colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .processing:
            Color(hex: "3B82F6").opacity(0.7)
        case .success:
            Color.white
        }
    }
    
    private var buttonShadowColor: Color {
        switch paymentState {
        case .idle:
            return Color(hex: "3B82F6").opacity(0.25)
        case .processing:
            return Color(hex: "3B82F6").opacity(0.15)
        case .success:
            return Color.white.opacity(0.3)
        }
    }
    
    private var buttonTextColor: Color {
        switch paymentState {
        case .success:
            return Color(hex: "3B82F6")
        default:
            return .white
        }
    }
    
    // MARK: - Actions
    
    private func handlePayment() {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Fade out amount
        withAnimation(.easeOut(duration: 0.3)) {
            amountOpacity = 0.0
        }
        
        // Start processing
        withAnimation(.easeInOut(duration: 0.35).delay(0.2)) {
            paymentState = .processing
        }
        
        // Simulate payment processing (2 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showSuccess()
        }
    }
    
    private func showSuccess() {
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        // Transition to success
        withAnimation(.easeInOut(duration: 0.4)) {
            paymentState = .success
        }
        
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
        
        // Reset after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            resetPayment()
        }
    }
    
    // MARK: - Create Confetti With Coins
    
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
    
    // MARK: - Create Confetti
    
    private func createConfetti() {
        let colors: [Color] = [
            Color(hex: "10B981").opacity(0.6),
            Color(hex: "34D399").opacity(0.6),
            Color(hex: "6EE7B7").opacity(0.6)
        ]
        
        var particles: [ConfettiParticle] = []
        
        // Create 12 subtle confetti particles
        for i in 0..<12 {
            let angle = Double(i) * (360.0 / 12.0) * .pi / 180
            let velocity = Double.random(in: 80...120)
            let size = CGFloat.random(in: 4...8)
            
            let particle = ConfettiParticle(
                id: UUID(),
                x: cos(angle) * velocity * 0.4,
                y: sin(angle) * velocity * 0.4,
                color: colors.randomElement() ?? Color(hex: "10B981"),
                size: size,
                opacity: 0.8,
                scale: 1.0
            )
            particles.append(particle)
        }
        
        confettiParticles = particles
        
        // Animate confetti
        withAnimation(.easeOut(duration: 1.5)) {
            confettiParticles = confettiParticles.map { particle in
                var updated = particle
                updated.y += 200
                updated.opacity = 0
                updated.scale = 0.3
                return updated
            }
        }
        
        // Clear confetti after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            confettiParticles.removeAll()
        }
    }
    
    private func resetPayment() {
        withAnimation(.easeInOut(duration: 0.4)) {
            paymentState = .idle
            checkmarkProgress = 0
            successScale = 0
            successRingScale = 0
            glowOpacity = 0
            showPaymentDetails = false
            gradientOffset = 0
        }
        
        // Clear confetti
        confettiParticles.removeAll()
        
        // Fade in amount display
        withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
            amountOpacity = 1.0
        }
    }
}

// MARK: - Confetti Particle

struct ConfettiParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var opacity: Double
    var scale: CGFloat
}

// MARK: - Checkmark Shape

struct CheckmarkShape: Shape {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Refined checkmark path
        let startPoint = CGPoint(x: width * 0.25, y: height * 0.5)
        let middlePoint = CGPoint(x: width * 0.42, y: height * 0.68)
        let endPoint = CGPoint(x: width * 0.75, y: height * 0.32)
        
        path.move(to: startPoint)
        
        if progress > 0 {
            let firstProgress = min(progress * 2, 1.0)
            let firstX = startPoint.x + (middlePoint.x - startPoint.x) * firstProgress
            let firstY = startPoint.y + (middlePoint.y - startPoint.y) * firstProgress
            path.addLine(to: CGPoint(x: firstX, y: firstY))
            
            if progress > 0.5 {
                let secondProgress = (progress - 0.5) * 2
                let secondX = middlePoint.x + (endPoint.x - middlePoint.x) * secondProgress
                let secondY = middlePoint.y + (endPoint.y - middlePoint.y) * secondProgress
                path.addLine(to: CGPoint(x: secondX, y: secondY))
            }
        }
        
        return path
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

struct Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
