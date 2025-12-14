import SwiftUI

struct PINEntryView: View {
    @Binding var paymentState: PaymentState
    let enteredAmount: String
    let upiID: String
    
    @State private var pin: [String] = ["", "", "", ""]
    @State private var currentIndex: Int = 0
    @State private var isShaking: Bool = false
    @State private var showError: Bool = false
    @FocusState private var isPINFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)
            
            // Header
            VStack(spacing: 8) {
                Text("Enter UPI PIN")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "1F2937"), Color(hex: "374151")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Authenticate to complete payment")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            
            Spacer()
                .frame(height: 20)
            
            // Payment details card
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Paying to")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "9CA3AF"))
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(upiID)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "1F2937"))
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Amount")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "9CA3AF"))
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text("₹\(enteredAmount)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(hex: "F9FAFB"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color(hex: "E5E7EB"), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
            
            Spacer()
                .frame(height: 24)
            
            // PIN input dots
            HStack(spacing: 24) {
                ForEach(0..<4, id: \.self) { index in
                    ZStack {
                        // Outer ring
                        if pin[index].isEmpty {
                            Circle()
                                .strokeBorder(Color(hex: "E5E7EB"), lineWidth: 2.5)
                                .frame(width: 56, height: 56)
                        } else {
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color(hex: "3B82F6"), Color(hex: "60A5FA")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.5
                                )
                                .frame(width: 56, height: 56)
                        }
                        
                        // Filled dot
                        if !pin[index].isEmpty {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 14, height: 14)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Current index indicator
                        if index == currentIndex && pin[index].isEmpty {
                            Circle()
                                .strokeBorder(Color(hex: "3B82F6"), lineWidth: 2, antialiased: true)
                                .frame(width: 56, height: 56)
                                .scaleEffect(1.1)
                                .opacity(0.4)
                        }
                    }
                }
            }
            .offset(x: isShaking ? -8 : 0)
            
            Spacer()
                .frame(height: 20)
            
            // Error message or spacer
            if showError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "EF4444"))
                    
                    Text("Incorrect PIN. Please try again.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "EF4444"))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            } else {
                Color.clear
                    .frame(height: 20)
            }
            
            Spacer()
                .frame(height: 16)
            
            // Custom number pad
            VStack(spacing: 18) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 18) {
                        ForEach(1...3, id: \.self) { col in
                            let number = row * 3 + col
                            NumberButton(number: "\(number)") {
                                addDigit("\(number)")
                            }
                        }
                    }
                }
                
                // Bottom row with 0 and delete
                HStack(spacing: 18) {
                    // Empty space
                    Color.clear
                        .frame(width: 72, height: 72)
                    
                    // Zero button
                    NumberButton(number: "0") {
                        addDigit("0")
                    }
                    
                    // Delete button
                    Button(action: deleteDigit) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "F3F4F6"))
                            
                            Image(systemName: "delete.left.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(hex: "6B7280"))
                        }
                        .frame(width: 72, height: 72)
                    }
                }
            }
            
            Spacer()
                .frame(height: 10)
        }
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .scale.combined(with: .opacity)))
    }
    
    private func addDigit(_ digit: String) {
        guard currentIndex < 4 else { return }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            pin[currentIndex] = digit
            currentIndex += 1
            showError = false
        }
        
        // Check if PIN is complete
        if currentIndex == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                validatePIN()
            }
        }
    }
    
    private func deleteDigit() {
        guard currentIndex > 0 else { return }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentIndex -= 1
            pin[currentIndex] = ""
            showError = false
        }
    }
    
    private func validatePIN() {
        // For demo purposes, any 4-digit PIN is accepted
        // In production, this would validate against actual UPI PIN
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        
        // Proceed to processing
        withAnimation(.easeInOut(duration: 0.4)) {
            paymentState = .processing
        }
    }
    
    private func showInvalidPIN() {
        // Shake animation
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
            isShaking = true
        }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.3).delay(0.1)) {
            isShaking = false
        }
        
        // Show error
        withAnimation {
            showError = true
        }
        
        // Haptic feedback
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.error)
        
        // Clear PIN
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                pin = ["", "", "", ""]
                currentIndex = 0
            }
        }
    }
}

// MARK: - Number Button Component

struct NumberButton: View {
    let number: String
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isPressed ? 
                            LinearGradient(
                                colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Color(hex: "F9FAFB"), Color(hex: "F3F4F6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isPressed ? Color.clear : Color(hex: "E5E7EB"),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: isPressed ? Color(hex: "3B82F6").opacity(0.3) : Color.black.opacity(0.05),
                        radius: isPressed ? 8 : 4,
                        x: 0,
                        y: isPressed ? 4 : 2
                    )
                
                Text(number)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(isPressed ? .white : Color(hex: "1F2937"))
            }
            .frame(width: 72, height: 72)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
