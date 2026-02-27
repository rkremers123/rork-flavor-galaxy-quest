import Foundation

struct FoodDatabase {
    static let allFoods: [FoodItem] = [
        FoodItem(name: "Chicken Nugget", emoji: "🍗", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "DAA520", allergens: [.gluten, .soy], commonBrands: ["Tyson", "Perdue", "Applegate"]),
        FoodItem(name: "Turkey Slices", emoji: "🦃", texture: .soft, flavor: .salty, temperature: .cold, aroma: .mild, category: .protein, planetColorHex: "CD853F", allergens: []),
        FoodItem(name: "PB&J Sandwich", emoji: "🥪", texture: .soft, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .protein, planetColorHex: "D2691E", allergens: [.peanut, .gluten]),
        FoodItem(name: "Cheese Quesadilla", emoji: "🫔", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "FFD700", allergens: [.dairy, .gluten]),
        FoodItem(name: "Hot Dog", emoji: "🌭", texture: .soft, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "B8860B", allergens: [.gluten]),
        FoodItem(name: "Scrambled Eggs", emoji: "🥚", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "FFFACD", allergens: [.egg]),
        FoodItem(name: "Fish Stick", emoji: "🐟", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "4682B4", allergens: [.fish, .gluten]),
        FoodItem(name: "Ground Beef", emoji: "🥩", texture: .soft, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "8B4513"),
        FoodItem(name: "Salmon", emoji: "🍣", texture: .soft, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "FA8072", allergens: [.fish]),
        FoodItem(name: "Shrimp", emoji: "🦐", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "FF7F50", allergens: [.shellfish]),
        FoodItem(name: "Deli Meat", emoji: "🥓", texture: .soft, flavor: .salty, temperature: .cold, aroma: .mild, category: .protein, planetColorHex: "DC143C"),

        FoodItem(name: "White Bread", emoji: "🍞", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "DEB887", allergens: [.gluten]),
        FoodItem(name: "Whole Wheat Bread", emoji: "🍞", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "A0522D", allergens: [.gluten]),
        FoodItem(name: "Pasta", emoji: "🍝", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FFDAB9", allergens: [.gluten, .egg]),
        FoodItem(name: "Mac & Cheese", emoji: "🧀", texture: .soft, flavor: .salty, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FFA500", allergens: [.gluten, .dairy]),
        FoodItem(name: "White Rice", emoji: "🍚", texture: .soft, flavor: .bland, temperature: .hot, aroma: .noOdor, category: .grain, planetColorHex: "FFFAF0"),
        FoodItem(name: "Brown Rice", emoji: "🍚", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "C4A882"),
        FoodItem(name: "French Fries", emoji: "🍟", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FFD700"),
        FoodItem(name: "Sweet Potato Fries", emoji: "🍠", texture: .crunchy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FF6347"),
        FoodItem(name: "Goldfish Crackers", emoji: "🐠", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .noOdor, category: .grain, planetColorHex: "FF8C00", allergens: [.gluten, .dairy]),
        FoodItem(name: "Pretzels", emoji: "🥨", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .noOdor, category: .grain, planetColorHex: "D2B48C", allergens: [.gluten]),
        FoodItem(name: "Bagel", emoji: "🥯", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "DEB887", allergens: [.gluten]),
        FoodItem(name: "English Muffin", emoji: "🧁", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "F5DEB3", allergens: [.gluten]),

        FoodItem(name: "Banana", emoji: "🍌", texture: .soft, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .fruit, planetColorHex: "FFD700"),
        FoodItem(name: "Apple", emoji: "🍎", texture: .crunchy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "DC143C"),
        FoodItem(name: "Strawberry", emoji: "🍓", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FF1493"),
        FoodItem(name: "Watermelon", emoji: "🍉", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FF4500"),
        FoodItem(name: "Cantaloupe", emoji: "🍈", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "F4A460"),
        FoodItem(name: "Orange", emoji: "🍊", texture: .soft, flavor: .sour, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "FF8C00"),
        FoodItem(name: "Grape", emoji: "🍇", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "8B008B"),
        FoodItem(name: "Blueberry", emoji: "🫐", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "4169E1"),
        FoodItem(name: "Mango", emoji: "🥭", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "FFA500"),
        FoodItem(name: "Pineapple", emoji: "🍍", texture: .soft, flavor: .sour, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "FFD700"),

        FoodItem(name: "Corn", emoji: "🌽", texture: .crunchy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "FFD700"),
        FoodItem(name: "Peas", emoji: "🫛", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "32CD32"),
        FoodItem(name: "Carrot", emoji: "🥕", texture: .crunchy, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .vegetable, planetColorHex: "FF8C00"),
        FoodItem(name: "Broccoli", emoji: "🥦", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "228B22"),
        FoodItem(name: "Green Beans", emoji: "🫘", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "2E8B57"),
        FoodItem(name: "Sweet Potato", emoji: "🍠", texture: .mushy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "FF6347"),
        FoodItem(name: "Butternut Squash", emoji: "🎃", texture: .mushy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "E8A317"),
        FoodItem(name: "Zucchini", emoji: "🥒", texture: .soft, flavor: .bland, temperature: .hot, aroma: .noOdor, category: .vegetable, planetColorHex: "3CB371"),
        FoodItem(name: "Bell Pepper", emoji: "🫑", texture: .crunchy, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .vegetable, planetColorHex: "FF4500"),
        FoodItem(name: "Cucumber", emoji: "🥒", texture: .crunchy, flavor: .bland, temperature: .cold, aroma: .noOdor, category: .vegetable, planetColorHex: "2E8B57"),
        FoodItem(name: "Celery", emoji: "🥬", texture: .crunchy, flavor: .bland, temperature: .cold, aroma: .mild, category: .vegetable, planetColorHex: "7CFC00"),
        FoodItem(name: "Avocado", emoji: "🥑", texture: .mushy, flavor: .bland, temperature: .roomTemp, aroma: .noOdor, category: .vegetable, planetColorHex: "556B2F"),

        FoodItem(name: "Cheddar Cheese", emoji: "🧀", texture: .soft, flavor: .salty, temperature: .roomTemp, aroma: .mild, category: .dairy, planetColorHex: "FFD700", allergens: [.dairy]),
        FoodItem(name: "Mozzarella", emoji: "🧀", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .noOdor, category: .dairy, planetColorHex: "FFFAF0", allergens: [.dairy]),
        FoodItem(name: "Yogurt", emoji: "🥛", texture: .mushy, flavor: .sweet, temperature: .cold, aroma: .noOdor, category: .dairy, planetColorHex: "FFF0F5", allergens: [.dairy]),
        FoodItem(name: "Fruit Yogurt", emoji: "🥛", texture: .mushy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .dairy, planetColorHex: "FFB6C1", allergens: [.dairy]),
        FoodItem(name: "Milk", emoji: "🥛", texture: .liquid, flavor: .bland, temperature: .cold, aroma: .noOdor, category: .dairy, planetColorHex: "F5F5F5", allergens: [.dairy]),
        FoodItem(name: "Cottage Cheese", emoji: "🧀", texture: .mushy, flavor: .bland, temperature: .cold, aroma: .mild, category: .dairy, planetColorHex: "FFFACD", allergens: [.dairy]),
    ]

    static func food(byId id: UUID) -> FoodItem? {
        allFoods.first { $0.id == id }
    }

    static func food(byName name: String) -> FoodItem? {
        allFoods.first { $0.name.lowercased() == name.lowercased() }
    }

    static func foods(for category: FoodCategory) -> [FoodItem] {
        allFoods.filter { $0.category == category }
    }

    static func foods(excluding allergens: Set<Allergen>) -> [FoodItem] {
        guard !allergens.isEmpty else { return allFoods }
        return allFoods.filter { $0.allergens.isDisjoint(with: allergens) }
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
