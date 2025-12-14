//
//  ContentView.swift
//  Animation 01
//
//  Created by Uday on 23/11/25.
//


import SwiftUI
import AVFoundation
import AudioToolbox

public struct ContentView: View {
    
    let rowSize: CGSize = CGSize(width: 180, height: 240)
    @Environment(\.colorScheme) var colorScheme
    @State private var offsetValue: ScrollOffsetValue = ScrollOffsetValue()
    @State private var backgroundColor: Color = .clear
    @State private var lastCenteredProductId: UUID? = nil
    @State private var scrollProgress: CGFloat = 0.0
    
    public init() {}
    public var body: some View {
        ZStack {
            // Enhanced gradient background
            ZStack {
                if colorScheme == .dark {
                    LinearGradient(
                        colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    LinearGradient(
                        colors: [Color.white, Color(red: 0.98, green: 0.98, blue: 1.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            GeometryReader { proxyP in
                ScrollView {
                    ZStack {
                        LazyVStack {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: proxyP.size.height * 0.5)
                            ForEach(sampleProducts) { product in
                                GeometryReader { proxyC in
                                    let rect = proxyC.frame(in: .named("scroll"))
                                    let y = rect.minY
                                    
                                    // Calculate distance from center for background color
                                    let midY = proxyP.size.height / 2
                                    let distance = abs(midY - y)
                                    
                                    // Stacking animation calculations
                                    let normalizedDistance = min(1.0, distance / (proxyP.size.height / 2))
                                    let scale = max(0.7, 1.2 - (normalizedDistance * 0.5))
                                    // Fade out cards at the edges
                                    let opacity = max(0, 1.0 - (normalizedDistance * 1.2))
                                    let zIndex = 100.0 - distance
                                    
                                    Button(action: {
                                        // Action for card tap if needed
                                    }) {
                                        ProductCardView(product: product)
                                            .scaleEffect(scale)
                                            .rotationEffect(.degrees(getRotateValue(y, proxyP.size.height) * 5), anchor: .center)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .opacity(opacity)
                                    .allowsHitTesting(opacity > 0.3)
                                    .zIndex(zIndex)
                                    .preference(key: MinDistanceKey.self, value: [DistanceData(id: product.id, distance: distance, color: product.color)])
                                    .onChange(of: distance < 50) { isCentered in
                                        if isCentered && lastCenteredProductId != product.id {
                                            lastCenteredProductId = product.id
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                            AudioServicesPlaySystemSound(1104)
                                        }
                                    }
                                }
                                .frame(width: rowSize.width, height: rowSize.height)
                            }
                            
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: max(proxyP.size.height * 0.5, 1))
                        }
                        
                        OffsetInScrollView(named: "scroll")
                    }
                }
                .scrollIndicators(.hidden)
            }
            .modifier(OffsetOutScrollModifier(offsetValue: $offsetValue, named: "scroll"))
            .onPreferenceChange(MinDistanceKey.self) { values in
                if let closest = values.min(by: { $0.distance < $1.distance }) {
                    self.backgroundColor = closest.color
                }
            }
            .onChange(of: offsetValue.y) { newValue in
                let totalScrollHeight = max(offsetValue.contentSize.height, 1)
                scrollProgress = min(max(-newValue / totalScrollHeight, 0), 1)
            }
            
            // Scroll Progress Indicator
            VStack {
                Spacer()
                HStack {
                    ScrollProgressIndicator(progress: scrollProgress, currentColor: backgroundColor)
                        .padding(.leading, 30)
                        .padding(.bottom, 50)
                    Spacer()
                }
            }
            .zIndex(1000)
        }
        .edgesIgnoringSafeArea(.all)

    }
    
    private func getCurveValue(_ current: Double, _ total: Double) -> CGFloat {
        let x = Double(current) / Double(total)
        let y = (sin(-1 * .pi * x - .pi) + 0.5) / 2.0
        return 2 * CGFloat(y)
    }
    
    private func getRotateValue(_ current: Double, _ total: Double) -> CGFloat {
        let x = Double(current) / Double(total)
        let y = (sin(.pi * x - (.pi / 2.0))) / 2.0
        return 2 * CGFloat(y)
    }
}


struct Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
