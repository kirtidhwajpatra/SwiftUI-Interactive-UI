import SwiftUI

struct ProductCardView: View {
    let product: Product
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Base card with gradient
            RoundedRectangle(cornerRadius: 30)
                .fill(
                    LinearGradient(
                        colors: colorScheme == .dark ? 
                            [Color(red: 0.15, green: 0.15, blue: 0.17), Color(red: 0.12, green: 0.12, blue: 0.14)] :
                            [Color.white, Color(red: 0.98, green: 0.98, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [product.color, product.color.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                )
                .shadow(color: product.color.opacity(0.3), radius: 20, x: 0, y: 10)
                .shadow(color: product.color.opacity(0.2), radius: 5, x: 0, y: 2)
            
            VStack(spacing: 12) {
                Text(product.emoji)
                    .font(.system(size: 100))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                
                Text(String(format: "$%.2f", product.price))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: colorScheme == .dark ? 
                                [.white, Color(red: 0.9, green: 0.9, blue: 0.95)] :
                                [.black, Color(red: 0.2, green: 0.2, blue: 0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .padding()
        }
    }
}

struct ProductCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProductCardView(product: sampleProducts[0])
                .frame(width: 180, height: 240)
                .padding()
                .preferredColorScheme(.light)
            
            ProductCardView(product: sampleProducts[0])
                .frame(width: 180, height: 240)
                .padding()
                .preferredColorScheme(.dark)
        }
    }
}

