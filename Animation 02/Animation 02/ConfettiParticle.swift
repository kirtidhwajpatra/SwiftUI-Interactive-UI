import SwiftUI

struct ConfettiParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var opacity: Double
    var scale: CGFloat
}
