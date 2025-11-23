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
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var offsetValue: ScrollOffsetValue = ScrollOffsetValue()
    @State private var backgroundColor: Color = .clear
    @State private var lastCenteredProductId: UUID? = nil
    @State private var scrollProgress: CGFloat = 0.0
    @State private var selectedProduct: Product? = nil
    @State private var isNavigating: Bool = false
    
    public init() {}
    public var body: some View {
        ZStack {
            // Enhanced gradient background
            ZStack {
                if isDarkMode {
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
                                    let curveX = getCurveValue(y, proxyP.size.height) * rowSize.height - rowSize.height
                                    
                                    // Calculate distance from center for background color
                                    let midY = proxyP.size.height / 2
                                    let distance = abs(midY - y)
                                    
                                    // Stacking animation calculations
                                    let normalizedDistance = min(1.0, distance / (proxyP.size.height / 2))
                                    let scale = max(0.7, 1.2 - (normalizedDistance * 0.5))
                                    // Fade out cards at the edges
                                    let opacity = max(0, 1.0 - (normalizedDistance * 1.2))
                                    let zIndex = 100.0 - distance
                                    
#if os(iOS)
                                    ZStack {
                                        NavigationLink(
                                            destination: DetailView(product: selectedProduct ?? product).edgesIgnoringSafeArea(.all),
                                            isActive: Binding(
                                                get: { isNavigating && selectedProduct?.id == product.id },
                                                set: { if !$0 { isNavigating = false; selectedProduct = nil } }
                                            )
                                        ) {
                                            EmptyView()
                                        }
                                        
                                        Button(action: {
                                            selectedProduct = product
                                            isNavigating = true
                                        }) {
                                            ProductCardView(product: product)
                                                .scaleEffect(scale)
                                                .rotationEffect(.degrees(getRotateValue(y, proxyP.size.height) * 5), anchor: .center)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
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
#else
                                    Button {
                                        
                                    } label: {
                                        ProductCardView(product: product)
                                            .scaleEffect(max(0.7, 1.2 - ((min(1.0, abs(midY - y) / (proxyP.size.height / 2))) * 0.5)))
                                            .rotationEffect(.degrees(getRotateValue(y, proxyP.size.height) * 5), anchor: .center)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
#endif
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(width: rowSize.width, height: rowSize.height)
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
            
            // Theme Toggle
//            VStack {
//                HStack {
//                    Spacer()
//                    ThemeToggle(isDarkMode: $isDarkMode)
//                        .padding(.top, 50)
//                        .padding(.trailing, 30)
//                }
//                Spacer()
//            }
//            .zIndex(1000)
//            
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
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    private func getAlphaValue(_ current: Double, _ total: Double) -> CGFloat {
        let x = Double(current) / Double(total)
        let y = (sin(-1.1 * (.pi * x) - .pi / 1))
        return 1.0
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
    
    private func getContrastingColor(_ color: Color) -> Color {
        switch color {
        case .pink:
            return Color.cyan
        case .green:
            return Color.purple.opacity(0.8)
        case .orange:
            return Color.blue
        case .blue:
            return Color.orange.opacity(0.8)
        case .red:
            return Color.green.opacity(0.7)
        case .purple:
            return Color.yellow.opacity(0.7)
        case .yellow:
            return Color.purple.opacity(0.8)
        case .brown:
            return Color.cyan.opacity(0.6)
        default:
            return Color.gray.opacity(0.3)
        }
    }
}

fileprivate
struct ScrollOffsetValue: Equatable {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var contentSize: CGSize = .zero
}

fileprivate
struct ScrollOffsetKey: PreferenceKey {
    typealias Value = ScrollOffsetValue
    static var defaultValue = ScrollOffsetValue()
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let newValue = nextValue()
        value.x += newValue.x
        value.y += newValue.y
        value.contentSize = newValue.contentSize
    }
}

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

fileprivate
struct OffsetInScrollView: View {
    let named: String
    var body: some View {
        GeometryReader { proxy in
            let offsetValue = ScrollOffsetValue(x: proxy.frame(in: .named(named)).minX,
                                                y: proxy.frame(in: .named(named)).minY,
                                                contentSize: proxy.size)
            Color.clear.preference(key: ScrollOffsetKey.self, value: offsetValue)
        }
    }
}

fileprivate
struct OffsetOutScrollModifier: ViewModifier {
    
    @Binding var offsetValue: ScrollOffsetValue
    let named: String
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .coordinateSpace(name: named)
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    offsetValue = value
                    offsetValue.contentSize = CGSize(width: offsetValue.contentSize.width - proxy.size.width, height: offsetValue.contentSize.height - proxy.size.height)
                }
        }
    }
}

fileprivate
struct DetailView: View {
    
    let product: Product
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Premium gradient background
            LinearGradient(
                colors: colorScheme == .dark ?
                    [Color.black, Color(red: 0.05, green: 0.05, blue: 0.08)] :
                    [Color.white, product.color.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    // Large emoji with glow effect
                    ZStack {
                        Circle()
                            .fill(product.color.opacity(0.2))
                            .frame(width: 220, height: 220)
                            .blur(radius: 30)
                        
                        Text(product.emoji)
                            .font(.system(size: 140))
                    }
                    .padding(.top, 60)
                    
                    // Product info card
                    VStack(spacing: 16) {
                        Text(product.name)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Text(String(format: "$%.2f", product.price))
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [product.color, product.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text(product.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.17) : Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    
                    // Features section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why You'll Love It")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        FeatureRow(icon: "leaf.fill", text: "100% Organic & Fresh", color: .green)
                        FeatureRow(icon: "heart.fill", text: "Rich in Nutrients", color: .red)
                        FeatureRow(icon: "star.fill", text: "Premium Quality", color: .orange)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.17) : Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    
                    // Reviews section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Customer Reviews")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 16))
                            }
                            Text("4.9 (127 reviews)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.leading, 8)
                        }
                        
                        Text("\"Absolutely delicious! Fresh and perfectly ripe.\"")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                            .padding(.top, 4)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(colorScheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.17) : Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 5)
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Add to Cart button with high contrast
            VStack {
                Spacer()
                Button(action: {
                    // Add to cart action
                }) {
                    HStack {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Add to Cart")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [product.color, product.color.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
                    .shadow(color: product.color.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper view for feature rows
struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
                .frame(width: 30)
            
            Text(text)
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
}

struct Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
