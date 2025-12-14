import SwiftUI

struct Product: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let price: Double
    let description: String
    let color: Color
}

let sampleProducts: [Product] = [
    Product(name: "Dragon Fruit", emoji: "🍄", price: 5.99, description: "A tropical fruit with a unique look and sweet taste.", color: .pink),
    Product(name: "Avocado", emoji: "🥑", price: 2.49, description: "Creamy and rich, perfect for toast or salads.", color: .green),
    Product(name: "Mango", emoji: "🥭", price: 1.99, description: "Juicy and sweet, the king of fruits.", color: .orange),
    Product(name: "Blueberry", emoji: "🫐", price: 3.99, description: "Small, sweet, and packed with antioxidants.", color: .blue),
    Product(name: "Kiwi", emoji: "🥝", price: 0.99, description: "Tangy and sweet with a fuzzy skin.", color: .green),
    Product(name: "Watermelon", emoji: "🍉", price: 4.99, description: "Refreshing and hydrating, perfect for summer.", color: .red),
    Product(name: "Grapes", emoji: "🍇", price: 2.99, description: "Sweet and crunchy, great for snacking.", color: .purple),
    Product(name: "Peach", emoji: "🍑", price: 1.49, description: "Soft and fuzzy with a sweet floral taste.", color: .orange),
    Product(name: "Pineapple", emoji: "🍍", price: 3.49, description: "Tropical and tart, great in smoothies.", color: .yellow),
    Product(name: "Strawberry", emoji: "🍓", price: 2.99, description: "Sweet and juicy, a classic favorite.", color: .red),
    Product(name: "Banana", emoji: "🍌", price: 0.69, description: "Rich in potassium and great for energy.", color: .yellow),
    Product(name: "Cherry", emoji: "🍒", price: 4.49, description: "Sweet and tart, perfect for desserts.", color: .red),
    Product(name: "Lemon", emoji: "🍋", price: 0.79, description: "Sour and zesty, adds flavor to any dish.", color: .yellow),
    Product(name: "Apple", emoji: "🍎", price: 1.29, description: "Crisp and sweet, keeps the doctor away.", color: .red),
    Product(name: "Coconut", emoji: "🥥", price: 2.99, description: "Tropical and creamy, great for hydration.", color: .brown)
]
