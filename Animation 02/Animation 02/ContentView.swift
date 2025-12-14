import SwiftUI

public struct ContentView: View {
    
    @State private var paymentState: PaymentState = .inputUPI
    @State private var amountOpacity: Double = 1.0
    @State private var gradientOffset: CGFloat = 0
    
    // Data Inputs
    @State private var upiID: String = ""
    @State private var enteredAmount: String = ""
    @FocusState private var isAmountFocused: Bool
    @FocusState private var isUPIFocused: Bool
    
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
                    if paymentState == .inputUPI {
                        UPIEntryView(
                            upiID: $upiID,
                            paymentState: $paymentState,
                            isUPIFocused: $isUPIFocused,
                            isAmountFocused: $isAmountFocused
                        )
                    } else if paymentState == .inputAmount {
                        AmountEntryView(
                            enteredAmount: $enteredAmount,
                            amountOpacity: $amountOpacity,
                            isAmountFocused: $isAmountFocused
                        )
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .scale.combined(with: .opacity)))
                    } else if paymentState == .inputPIN {
                        PINEntryView(
                            paymentState: $paymentState,
                            enteredAmount: enteredAmount,
                            upiID: upiID
                        )
                        .padding(.top, 40)
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .scale.combined(with: .opacity)))
                    } else if paymentState == .processing {
                        LoadingView(paymentState: $paymentState)
                            .transition(.scale.combined(with: .opacity))
                    } else if paymentState == .success {
                        SuccessView(enteredAmount: enteredAmount)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
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
    
    // MARK: - Background
    
    @ViewBuilder
    private var backgroundColor: some View {
        switch paymentState {
        case .inputUPI, .inputAmount, .inputPIN:
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
    
    // MARK: - Status Text
    
    private var statusText: some View {
        VStack(spacing: 12) {
            if paymentState != .success && paymentState != .inputPIN {
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
    }
    
    private var titleColor: Color {
        switch paymentState {
        case .inputUPI, .inputAmount, .inputPIN:
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
        case .inputUPI:
            return ""
        case .inputAmount:
            return "Payment to"
        case .inputPIN:
            return ""
        case .processing:
            return "Processing Payment"
        case .success:
            return ""
        }
    }
    
    private var statusSubtitle: String {
        switch paymentState {
        case .inputUPI:
            return ""
        case .inputAmount:
            return upiID.isEmpty ? "merchant" : upiID
        case .inputPIN:
            return ""
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
        .disabled(isButtonDisabled)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: paymentState)
    }
    
    private var isButtonDisabled: Bool {
        switch paymentState {
        case .inputUPI:
            return upiID.isEmpty
        case .inputAmount:
            return enteredAmount.isEmpty
        case .inputPIN:
            return true  // PIN is entered via number pad
        case .processing:
            return true
        case .success:
            return false
        }
    }
    
    private var buttonTitle: String {
        switch paymentState {
        case .inputUPI:
            return "Verify & Proceed"
        case .inputAmount:
            return "Continue to Payment"
        case .inputPIN:
            return "Enter PIN Above"
        case .processing:
            return "Processing..."
        case .success:
            return "Payment Complete"
        }
    }
    
    @ViewBuilder
    private var buttonBackground: some View {
        switch paymentState {
        case .inputUPI, .inputAmount:
            LinearGradient(
                colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .inputPIN:
            Color(hex: "E5E7EB")
        case .processing:
            Color(hex: "3B82F6").opacity(0.7)
        case .success:
            Color.white
        }
    }
    
    private var buttonShadowColor: Color {
        switch paymentState {
        case .inputUPI, .inputAmount:
            return Color(hex: "3B82F6").opacity(0.25)
        case .inputPIN:
            return Color.black.opacity(0.05)
        case .processing:
            return Color(hex: "3B82F6").opacity(0.15)
        case .success:
            return Color.white.opacity(0.3)
        }
    }
    
    private var buttonTextColor: Color {
        switch paymentState {
        case .inputPIN:
            return Color(hex: "9CA3AF")
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
        
        if paymentState == .inputUPI {
            withAnimation {
                paymentState = .inputAmount
                isAmountFocused = true
            }
        } else if paymentState == .inputAmount {
            // Fade out amount and move to PIN entry
            withAnimation(.easeOut(duration: 0.3)) {
                amountOpacity = 0.0
                isAmountFocused = false
            }
            
            // Go to PIN entry
            withAnimation(.easeInOut(duration: 0.35).delay(0.2)) {
                paymentState = .inputPIN
            }
        } else if paymentState == .success {
            resetPayment()
        }
    }
    
    private func resetPayment() {
        withAnimation(.easeInOut(duration: 0.4)) {
            paymentState = .inputUPI
            upiID = ""
            enteredAmount = ""
            gradientOffset = 0
        }
        
        // Fade in amount display
        withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
            amountOpacity = 1.0
        }
    }
}



#Preview {
   ContentView()
}
