import SwiftUI

struct LoadingView: View {
    @Binding var paymentState: PaymentState
    
    @State private var loadingRotation: Double = 0
    @State private var coinRotation: Double = 0
    @State private var coinScale: CGFloat = 1.0
    
    var body: some View {
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
            
            // Simulate payment processing (2 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    paymentState = .success
                }
            }
        }
    }
    
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
}
