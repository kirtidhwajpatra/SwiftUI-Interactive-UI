import SwiftUI

struct ThemeToggle: View {
    @Binding var isDarkMode: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isDarkMode.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .fill(isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isDarkMode ? .yellow : .orange)
                    .rotationEffect(.degrees(isDarkMode ? 0 : 180))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ThemeToggle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ThemeToggle(isDarkMode: .constant(false))
            ThemeToggle(isDarkMode: .constant(true))
            ThemeToggle(isDarkMode: .constant(true))
                .preferredColorScheme(.dark)
        }
        .padding()
    }
}
