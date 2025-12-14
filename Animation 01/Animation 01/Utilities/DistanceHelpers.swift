import SwiftUI

struct DistanceData: Equatable {
    let id: UUID
    let distance: CGFloat
    let color: Color
}

struct MinDistanceKey: PreferenceKey {
    static var defaultValue: [DistanceData] = []
    static func reduce(value: inout [DistanceData], nextValue: () -> [DistanceData]) {
        value.append(contentsOf: nextValue())
    }
}
