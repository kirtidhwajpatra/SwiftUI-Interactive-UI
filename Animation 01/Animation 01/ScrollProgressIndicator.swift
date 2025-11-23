import SwiftUI

struct ScrollProgressIndicator: View {
    let progress: CGFloat // 0.0 to 1.0
    let currentColor: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(
                    colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1),
                    lineWidth: 3
                )
                .frame(width: 50, height: 50)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    currentColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.2), value: progress)
            
            // Center dot
            Circle()
                .fill(currentColor)
                .frame(width: 8, height: 8)
                .shadow(color: currentColor.opacity(0.5), radius: 4)
        }
    }
}

struct ScrollProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ScrollProgressIndicator(progress: 0.3, currentColor: .blue)
            ScrollProgressIndicator(progress: 0.7, currentColor: .pink)
        }
        .padding()
    }
}
