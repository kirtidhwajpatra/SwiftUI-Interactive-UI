import SwiftUI

struct AmountEntryView: View {
    @Binding var enteredAmount: String
    @Binding var amountOpacity: Double
    @FocusState.Binding var isAmountFocused: Bool
    
    var body: some View {
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
            
            // Large amount input
            HStack(spacing: 4) {
                Text("₹")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "1F2937"))
                
                TextField("0", text: $enteredAmount)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "1F2937"), Color(hex: "4B5563")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.leading)
                    .fixedSize()
                    .focused($isAmountFocused)
            }
        }
        .opacity(amountOpacity)
    }
}
