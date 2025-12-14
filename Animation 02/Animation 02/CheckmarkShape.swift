import SwiftUI

struct CheckmarkShape: Shape {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Refined checkmark path
        let startPoint = CGPoint(x: width * 0.25, y: height * 0.5)
        let middlePoint = CGPoint(x: width * 0.42, y: height * 0.68)
        let endPoint = CGPoint(x: width * 0.75, y: height * 0.32)
        
        path.move(to: startPoint)
        
        if progress > 0 {
            let firstProgress = min(progress * 2, 1.0)
            let firstX = startPoint.x + (middlePoint.x - startPoint.x) * firstProgress
            let firstY = startPoint.y + (middlePoint.y - startPoint.y) * firstProgress
            path.addLine(to: CGPoint(x: firstX, y: firstY))
            
            if progress > 0.5 {
                let secondProgress = (progress - 0.5) * 2
                let secondX = middlePoint.x + (endPoint.x - middlePoint.x) * secondProgress
                let secondY = middlePoint.y + (endPoint.y - middlePoint.y) * secondProgress
                path.addLine(to: CGPoint(x: secondX, y: secondY))
            }
        }
        
        return path
    }
}
