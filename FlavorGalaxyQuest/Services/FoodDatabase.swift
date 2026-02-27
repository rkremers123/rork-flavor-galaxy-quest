import Foundation

struct FoodDatabase {
    static let allFoods: [FoodItem] = [
        FoodItem(name: "Carrot", emoji: "🥕", texture: .crunchy, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .vegetable, planetColorHex: "FF8C00"),
        FoodItem(name: "Apple", emoji: "🍎", texture: .crunchy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "DC143C"),
        FoodItem(name: "Banana", emoji: "🍌", texture: .soft, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .fruit, planetColorHex: "FFD700"),
        FoodItem(name: "Broccoli", emoji: "🥦", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "228B22"),
        FoodItem(name: "Chicken Nugget", emoji: "🍗", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "DAA520"),
        FoodItem(name: "Cheese", emoji: "🧀", texture: .soft, flavor: .salty, temperature: .roomTemp, aroma: .mild, category: .dairy, planetColorHex: "FFD700"),
        FoodItem(name: "Strawberry", emoji: "🍓", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FF1493"),
        FoodItem(name: "Bread", emoji: "🍞", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "DEB887"),
        FoodItem(name: "Yogurt", emoji: "🥛", texture: .mushy, flavor: .sweet, temperature: .cold, aroma: .noOdor, category: .dairy, planetColorHex: "FFF0F5"),
        FoodItem(name: "Rice", emoji: "🍚", texture: .soft, flavor: .bland, temperature: .hot, aroma: .noOdor, category: .grain, planetColorHex: "FFFAF0"),
        FoodItem(name: "Peas", emoji: "🫛", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "32CD32"),
        FoodItem(name: "Grape", emoji: "🍇", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "8B008B"),
        FoodItem(name: "Cracker", emoji: "🍘", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .noOdor, category: .grain, planetColorHex: "F5DEB3"),
        FoodItem(name: "Cucumber", emoji: "🥒", texture: .crunchy, flavor: .bland, temperature: .cold, aroma: .noOdor, category: .vegetable, planetColorHex: "2E8B57"),
        FoodItem(name: "Pasta", emoji: "🍝", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FFDAB9"),
        FoodItem(name: "Blueberry", emoji: "🫐", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "4169E1"),
        FoodItem(name: "Egg", emoji: "🥚", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "FFFACD"),
        FoodItem(name: "Fish Stick", emoji: "🐟", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "4682B4"),
        FoodItem(name: "Sweet Potato", emoji: "🍠", texture: .mushy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "FF6347"),
        FoodItem(name: "Watermelon", emoji: "🍉", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FF4500"),
        FoodItem(name: "Celery", emoji: "🥬", texture: .crunchy, flavor: .bland, temperature: .cold, aroma: .mild, category: .vegetable, planetColorHex: "7CFC00"),
        FoodItem(name: "Orange", emoji: "🍊", texture: .soft, flavor: .sour, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "FF8C00"),
        FoodItem(name: "Avocado", emoji: "🥑", texture: .mushy, flavor: .bland, temperature: .roomTemp, aroma: .noOdor, category: .vegetable, planetColorHex: "556B2F"),
        FoodItem(name: "Mango", emoji: "🥭", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "FFA500"),
    ]

    static func food(byId id: UUID) -> FoodItem? {
        allFoods.first { $0.id == id }
    }

    static func foods(for category: FoodCategory) -> [FoodItem] {
        allFoods.filter { $0.category == category }
    }

    static func bridgeFoods(from safeFood: FoodItem) -> [FoodItem] {
        allFoods.filter { candidate in
            guard candidate.id != safeFood.id else { return false }
            var sharedTraits = 0
            if candidate.texture == safeFood.texture { sharedTraits += 1 }
            if candidate.flavor == safeFood.flavor { sharedTraits += 1 }
            if candidate.temperature == safeFood.temperature { sharedTraits += 1 }
            if candidate.aroma == safeFood.aroma { sharedTraits += 1 }
            return sharedTraits >= 2
        }
        .sorted { a, b in
            sensoryDistance(from: safeFood, to: a) < sensoryDistance(from: safeFood, to: b)
        }
    }

    static func sensoryDistance(from a: FoodItem, to b: FoodItem) -> Int {
        var distance = 0
        if a.texture != b.texture { distance += 1 }
        if a.flavor != b.flavor { distance += 1 }
        if a.temperature != b.temperature { distance += 1 }
        if a.aroma != b.aroma { distance += 1 }
        return distance
    }
}
