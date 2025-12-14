import SwiftUI

struct UPIEntryView: View {
    @Binding var upiID: String
    @Binding var paymentState: PaymentState
    @FocusState.Binding var isUPIFocused: Bool
    @FocusState.Binding var isAmountFocused: Bool
    
    @State private var iconScale: CGFloat = 0.8
    @State private var iconRotation: Double = 0
    
    // UPI validation
    private var isValidUPI: Bool {
        // UPI ID format: username@bankname
        // Must contain @ symbol and have text on both sides
        let components = upiID.split(separator: "@")
        guard components.count == 2 else { return false }
        
        let username = components[0]
        let bankName = components[1]
        
        // Username should be at least 3 characters
        guard username.count >= 3 else { return false }
        
        // Bank name should be at least 2 characters
        guard bankName.count >= 2 else { return false }
        
        // Username can only contain alphanumeric, dots, hyphens, underscores
        let usernamePattern = "^[a-zA-Z0-9._-]+$"
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", usernamePattern)
        guard usernameTest.evaluate(with: String(username)) else { return false }
        
        // Bank name can only contain alphanumeric
        let bankPattern = "^[a-zA-Z0-9]+$"
        let bankTest = NSPredicate(format: "SELF MATCHES %@", bankPattern)
        guard bankTest.evaluate(with: String(bankName)) else { return false }
        
        return true
    }
    
    private var showValidation: Bool {
        !upiID.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Animated icon with glow
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: "3B82F6").opacity(0.3),
                                Color(hex: "3B82F6").opacity(0.0)
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(iconScale)
                
                // Icon
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "3B82F6"), Color(hex: "2563EB")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "3B82F6").opacity(0.3), radius: 20, x: 0, y: 10)
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    iconScale = 1.0
                }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    iconRotation = 5
                }
            }
            
            VStack(spacing: 12) {
                Text("Enter UPI ID")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "1F2937"), Color(hex: "374151")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("We'll verify your payment details securely")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "6B7280"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            // Enhanced input field
            VStack(alignment: .leading, spacing: 8) {
                // Input container
                HStack(spacing: 12) {
                    // Text field
                    TextField("", text: $upiID, prompt: Text("example@upi").foregroundColor(Color(hex: "9CA3AF")))
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(hex: "1F2937"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .focused($isUPIFocused)
                        .submitLabel(.next)
                        .onSubmit {
                            if isValidUPI {
                                withAnimation {
                                    paymentState = .inputAmount
                                    isAmountFocused = true
                                }
                            }
                        }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    ZStack {
                        // White background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                        
                        // Border color based on validation
                        if isUPIFocused {
                            if showValidation && !isValidUPI {
                                // Red border for invalid
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color(hex: "EF4444"), Color(hex: "DC2626")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            } else if showValidation && isValidUPI {
                                // Green border for valid
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color(hex: "10B981"), Color(hex: "059669")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            } else {
                                // Blue border when focused but empty
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color(hex: "3B82F6"), Color(hex: "60A5FA")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                            }
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color(hex: "E5E7EB"), lineWidth: 2)
                        }
                    }
                )
                .shadow(
                    color: isUPIFocused ? 
                        (showValidation && !isValidUPI ? Color(hex: "EF4444").opacity(0.15) : 
                         showValidation && isValidUPI ? Color(hex: "10B981").opacity(0.15) : 
                         Color(hex: "3B82F6").opacity(0.15)) : 
                        Color.black.opacity(0.05),
                    radius: isUPIFocused ? 12 : 8,
                    x: 0,
                    y: isUPIFocused ? 6 : 4
                )
                .padding(.horizontal, 32)
                
                // Validation feedback
                if showValidation {
                    if isValidUPI {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "10B981"))
                            
                            Text("Valid UPI ID")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "10B981"))
                        }
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "EF4444"))
                            
                            Text("Invalid UPI ID format (e.g., username@bankname)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "EF4444"))
                        }
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            
            // Popular UPI apps
            VStack(spacing: 12) {
                Text("Popular UPI Apps")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "6B7280"))
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                HStack(spacing: 16) {
                    ForEach(["GPay", "PhonePe", "Paytm", "BHIM"], id: \.self) { app in
                        VStack(spacing: 6) {
                            Circle()
                                .fill(Color(hex: "F3F4F6"))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(app.prefix(1)))
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(Color(hex: "3B82F6"))
                                )
                            
                            Text(app)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color(hex: "6B7280"))
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading).combined(with: .opacity)))
    }
}
