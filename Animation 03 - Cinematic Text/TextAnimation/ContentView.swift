import SwiftUI

// MARK: - 1. Configuration
struct AnimationTheme {
    let words: [String] = ["Create", "momentum", "by", "choosing", "action", "daily."]
    
    let font: Font = .system(size: 60, weight: .heavy, design: .default)
    let lineSpacing: CGFloat = -15
    let gradientColors: [Color] = [.pink, .purple, .blue]
    let backgroundColors: [Color] = [.pink.opacity(0.2), .indigo.opacity(0.1), .clear]
    
    // Animation Physics
    let speedPerWord: Double = 0.5
    let blurStrength: CGFloat = 10
    
    // Scale Logic
    let startZoomScale: CGFloat = 3.5   //Only used for the first word entry
    let standardScale: CGFloat = 1.0    //All other words stay this size
}

// MARK: - 2. Main View
struct ContentView: View {
    
    let theme = AnimationTheme()
    
    @State private var visibleIndex: Int = -1
    @State private var gradientStart = UnitPoint(x: 0, y: 0)
    @State private var gradientEnd = UnitPoint(x: 0, y: 1)
    @State private var animationID = UUID()
    
    // MARK: - Logic
    var rowHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .largeTitle).pointSize * 2 + theme.lineSpacing
    }
    
    // Scroll Logic
    var currentOffset: CGFloat {
        let centerIndex = CGFloat(theme.words.count - 1) / 2.0
        
        // Target 0 initially so the first word slams in place without sliding
        let targetIndex = visibleIndex < 0 ? 0 : CGFloat(visibleIndex)
        
        return (centerIndex - targetIndex) * rowHeight
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.white.ignoresSafeArea()
            RadialGradient(colors: theme.backgroundColors, center: .center, startRadius: 10, endRadius: 500).ignoresSafeArea()
            
            // Text Stack
            VStack(spacing: theme.lineSpacing) {
                ForEach(Array(theme.words.enumerated()), id: \.offset) { index, word in
                    Text(word)
                        .font(theme.font)
                        .multilineTextAlignment(.center)
                        // Apply Effects
                        .blur(radius: calculateBlur(for: index))
                        .opacity(calculateOpacity(for: index))
                        .scaleEffect(calculateScale(for: index)) // <--- Logic fixed below
                }
            }
            .overlay(
                LinearGradient(colors: theme.gradientColors, startPoint: gradientStart, endPoint: gradientEnd)
                    .mask(
                        VStack(spacing: theme.lineSpacing) {
                            ForEach(Array(theme.words.enumerated()), id: \.offset) { index, word in
                                Text(word).font(theme.font)
                                    .opacity(index <= visibleIndex ? 1 : 0)
                                    .scaleEffect(calculateScale(for: index))
                            }
                        }
                    )
            )
            .foregroundColor(.clear)
            .offset(y: currentOffset)
            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: visibleIndex)
            
            // Replay Button
            VStack {
                Spacer()
                Button(action: startSequence) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("Replay")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Capsule().fill(Color.black.opacity(0.6)))
                }
                .padding(.bottom, 40)
                .opacity(visibleIndex == theme.words.count - 1 ? 1 : 0)
                .animation(.easeIn, value: visibleIndex)
            }
        }
        .onAppear {
            startSequence()
            startGradientAnimation()
        }
    }
    
    // MARK: - Calculations
    
    func calculateScale(for index: Int) -> CGFloat {
        // ⭐️ Rule: Only the FIRST word (Index 0) gets the zoom effect.
        if index == 0 {
            // If it hasn't appeared yet (visibleIndex < 0), it is HUGE (3.5).
            // When visibleIndex becomes 0, it animates to standard (1.0).
            return visibleIndex < 0 ? theme.startZoomScale : theme.standardScale
        }
        
        // ⭐️ All other words: Always stay at Standard Size (1.0). No shrinking.
        return theme.standardScale
    }
    
    func calculateBlur(for index: Int) -> CGFloat {
        if index == visibleIndex { return 0 } // Active is sharp
        
        // If it's the first word waiting to slam in, make it super blurry
        if index == 0 && visibleIndex < 0 { return 30 }
        
        // Standard background blur
        return index > visibleIndex ? theme.blurStrength * 2 : theme.blurStrength
    }
    
    func calculateOpacity(for index: Int) -> Double {
        if index == visibleIndex { return 1.0 }
        if index > visibleIndex { return 0 } // Hidden before reveal
        return 0.2 // Faded after passing
    }
    
    // MARK: - Actions
    func startSequence() {
        let currentRunID = UUID()
        animationID = currentRunID
        
        // Reset instantly to prepare for the "Slam"
        withAnimation(.none) { visibleIndex = -1 }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard self.animationID == currentRunID else { return }
            
            for i in 0..<theme.words.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * theme.speedPerWord)) {
                    guard self.animationID == currentRunID else { return }
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                        visibleIndex = i
                    }
                }
            }
        }
    }
    
    func startGradientAnimation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: true)) {
            gradientStart = UnitPoint(x: 1, y: 0)
            gradientEnd = UnitPoint(x: 0, y: 1)
        }
    }
}

#Preview {
    ContentView()
}
