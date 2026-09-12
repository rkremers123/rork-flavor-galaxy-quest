import Foundation

struct FoodDatabase {
    static let allFoods: [FoodItem] = [
        // MARK: - Proteins
        FoodItem(name: "Chicken Nugget", emoji: "🍗", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "DAA520", color: .golden, foodGroup: .protein, allergens: [.gluten, .soy], commonBrands: ["Tyson", "Perdue", "Applegate"]),
        FoodItem(name: "Turkey Slices", emoji: "🦃", texture: .soft, flavor: .salty, temperature: .cold, aroma: .mild, category: .protein, planetColorHex: "CD853F", color: .brown, foodGroup: .protein),
        FoodItem(name: "PB&J Sandwich", emoji: "🥪", texture: .soft, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .protein, planetColorHex: "D2691E", color: .brown, foodGroup: .mixed, allergens: [.peanut, .gluten]),
        FoodItem(name: "Cheese Quesadilla", emoji: "🫔", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "FFD700", color: .golden, foodGroup: .mixed, allergens: [.dairy, .gluten]),
        FoodItem(name: "Hot Dog", emoji: "🌭", texture: .soft, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "B8860B", color: .brown, foodGroup: .protein, allergens: [.gluten]),
        FoodItem(name: "Scrambled Eggs", emoji: "🥚", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "FFFACD", color: .yellow, foodGroup: .protein, allergens: [.egg]),
        FoodItem(name: "Fish Stick", emoji: "🐟", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "4682B4", color: .golden, foodGroup: .protein, allergens: [.fish, .gluten]),
        FoodItem(name: "Ground Beef", emoji: "🥩", texture: .soft, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "8B4513", color: .brown, foodGroup: .protein),
        FoodItem(name: "Salmon", emoji: "🍣", texture: .soft, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "FA8072", color: .orange, foodGroup: .protein, allergens: [.fish]),
        FoodItem(name: "Shrimp", emoji: "🦐", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "FF7F50", color: .orange, foodGroup: .protein, allergens: [.shellfish]),
        FoodItem(name: "Deli Meat", emoji: "🥓", texture: .soft, flavor: .salty, temperature: .cold, aroma: .mild, category: .protein, planetColorHex: "DC143C", color: .red, foodGroup: .protein),
        FoodItem(name: "Bacon", emoji: "🥓", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "8B0000", color: .red, foodGroup: .protein),
        FoodItem(name: "Chicken Breast", emoji: "🍗", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "F5DEB3", color: .white, foodGroup: .protein),
        FoodItem(name: "Taco", emoji: "🌮", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "DAA520", color: .brown, foodGroup: .mixed, allergens: [.gluten, .dairy]),
        FoodItem(name: "Hummus", emoji: "🫘", texture: .mushy, flavor: .bland, temperature: .cold, aroma: .mild, category: .protein, planetColorHex: "C8AD7F", color: .brown, foodGroup: .protein),

        // MARK: - Grains
        FoodItem(name: "White Bread", emoji: "🍞", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "DEB887", color: .white, foodGroup: .grain, allergens: [.gluten]),
        FoodItem(name: "Whole Wheat Bread", emoji: "🍞", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "A0522D", color: .brown, foodGroup: .grain, allergens: [.gluten]),
        FoodItem(name: "Pasta", emoji: "🍝", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FFDAB9", color: .yellow, foodGroup: .grain, allergens: [.gluten, .egg]),
        FoodItem(name: "Mac & Cheese", emoji: "🧀", texture: .soft, flavor: .salty, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FFA500", color: .orange, foodGroup: .mixed, allergens: [.gluten, .dairy]),
        FoodItem(name: "White Rice", emoji: "🍚", texture: .soft, flavor: .bland, temperature: .hot, aroma: .noOdor, category: .grain, planetColorHex: "FFFAF0", color: .white, foodGroup: .grain),
        FoodItem(name: "Brown Rice", emoji: "🍚", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "C4A882", color: .brown, foodGroup: .grain),
        FoodItem(name: "French Fries", emoji: "🍟", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FFD700", color: .golden, foodGroup: .grain),
        FoodItem(name: "Sweet Potato Fries", emoji: "🍠", texture: .crunchy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FF6347", color: .orange, foodGroup: .grain),
        FoodItem(name: "Goldfish Crackers", emoji: "🐠", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .noOdor, category: .grain, planetColorHex: "FF8C00", color: .orange, foodGroup: .grain, allergens: [.gluten, .dairy]),
        FoodItem(name: "Pretzels", emoji: "🥨", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .noOdor, category: .grain, planetColorHex: "D2B48C", color: .brown, foodGroup: .grain, allergens: [.gluten]),
        FoodItem(name: "Bagel", emoji: "🥯", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "DEB887", color: .brown, foodGroup: .grain, allergens: [.gluten]),
        FoodItem(name: "English Muffin", emoji: "🧁", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "F5DEB3", color: .white, foodGroup: .grain, allergens: [.gluten]),
        FoodItem(name: "Popcorn", emoji: "🍿", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "FFFDD0", color: .white, foodGroup: .grain),
        FoodItem(name: "Tortilla Chips", emoji: "🫓", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .noOdor, category: .grain, planetColorHex: "F0C75E", color: .yellow, foodGroup: .grain, allergens: [.gluten]),
        FoodItem(name: "Graham Crackers", emoji: "🍪", texture: .crunchy, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "C19A6B", color: .brown, foodGroup: .grain, allergens: [.gluten]),
        FoodItem(name: "Cereal", emoji: "🥣", texture: .crunchy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .grain, planetColorHex: "F5D76E", color: .yellow, foodGroup: .grain, allergens: [.gluten]),
        FoodItem(name: "Granola Bar", emoji: "🍫", texture: .crunchy, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "8B6914", color: .brown, foodGroup: .grain, allergens: [.gluten, .treeNut]),
        FoodItem(name: "Cinnamon Toast", emoji: "🍞", texture: .crunchy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "D2691E", color: .brown, foodGroup: .grain, allergens: [.gluten, .dairy]),
        FoodItem(name: "Pancakes", emoji: "🥞", texture: .soft, flavor: .sweet, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "DEB887", color: .golden, foodGroup: .grain, allergens: [.gluten, .egg, .dairy]),
        FoodItem(name: "Waffles", emoji: "🧇", texture: .crunchy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "D4A574", color: .golden, foodGroup: .grain, allergens: [.gluten, .egg, .dairy]),
        FoodItem(name: "Oatmeal", emoji: "🥣", texture: .mushy, flavor: .bland, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "C8B084", color: .brown, foodGroup: .grain, allergens: [.gluten]),
        FoodItem(name: "Pizza", emoji: "🍕", texture: .mixedTexture, flavor: .salty, temperature: .hot, aroma: .strong, category: .grain, planetColorHex: "FF6347", color: .mixed, foodGroup: .mixed, allergens: [.gluten, .dairy]),
        FoodItem(name: "Grilled Cheese", emoji: "🥪", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "FFD700", color: .golden, foodGroup: .mixed, allergens: [.gluten, .dairy]),

        // MARK: - Fruits
        FoodItem(name: "Banana", emoji: "🍌", texture: .soft, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .fruit, planetColorHex: "FFD700", color: .yellow, foodGroup: .fruit),
        FoodItem(name: "Apple", emoji: "🍎", texture: .crunchy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "DC143C", color: .red, foodGroup: .fruit),
        FoodItem(name: "Strawberry", emoji: "🍓", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FF1493", color: .red, foodGroup: .fruit),
        FoodItem(name: "Watermelon", emoji: "🍉", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FF4500", color: .red, foodGroup: .fruit),
        FoodItem(name: "Cantaloupe", emoji: "🍈", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "F4A460", color: .orange, foodGroup: .fruit),
        FoodItem(name: "Orange", emoji: "🍊", texture: .soft, flavor: .sour, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "FF8C00", color: .orange, foodGroup: .fruit),
        FoodItem(name: "Grape", emoji: "🍇", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "8B008B", color: .purple, foodGroup: .fruit),
        FoodItem(name: "Blueberry", emoji: "🫐", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "4169E1", color: .blue, foodGroup: .fruit),
        FoodItem(name: "Mango", emoji: "🥭", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "FFA500", color: .orange, foodGroup: .fruit),
        FoodItem(name: "Pineapple", emoji: "🍍", texture: .soft, flavor: .sour, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "FFD700", color: .yellow, foodGroup: .fruit),
        FoodItem(name: "Applesauce", emoji: "🍎", texture: .mushy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "C1876B", color: .brown, foodGroup: .fruit),
        FoodItem(name: "Dried Fruit", emoji: "🍇", texture: .soft, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .fruit, planetColorHex: "8B4513", color: .brown, foodGroup: .fruit),
        FoodItem(name: "Fruit Roll-Ups", emoji: "🍬", texture: .soft, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .fruit, planetColorHex: "FF69B4", color: .red, foodGroup: .fruit),
        FoodItem(name: "Pear", emoji: "🍐", texture: .soft, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "9ACD32", color: .green, foodGroup: .fruit),
        FoodItem(name: "Raisins", emoji: "🍇", texture: .soft, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .fruit, planetColorHex: "4B0082", color: .purple, foodGroup: .fruit),

        // MARK: - Vegetables
        FoodItem(name: "Corn", emoji: "🌽", texture: .crunchy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "FFD700", color: .yellow, foodGroup: .vegetable),
        FoodItem(name: "Peas", emoji: "🫛", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "32CD32", color: .green, foodGroup: .vegetable),
        FoodItem(name: "Carrot", emoji: "🥕", texture: .crunchy, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .vegetable, planetColorHex: "FF8C00", color: .orange, foodGroup: .vegetable),
        FoodItem(name: "Broccoli", emoji: "🥦", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "228B22", color: .green, foodGroup: .vegetable),
        FoodItem(name: "Green Beans", emoji: "🫘", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "2E8B57", color: .green, foodGroup: .vegetable),
        FoodItem(name: "Sweet Potato", emoji: "🍠", texture: .mushy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "FF6347", color: .orange, foodGroup: .vegetable),
        FoodItem(name: "Butternut Squash", emoji: "🎃", texture: .mushy, flavor: .sweet, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "E8A317", color: .orange, foodGroup: .vegetable),
        FoodItem(name: "Zucchini", emoji: "🥒", texture: .soft, flavor: .bland, temperature: .hot, aroma: .noOdor, category: .vegetable, planetColorHex: "3CB371", color: .green, foodGroup: .vegetable),
        FoodItem(name: "Bell Pepper", emoji: "🫑", texture: .crunchy, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .vegetable, planetColorHex: "FF4500", color: .red, foodGroup: .vegetable),
        FoodItem(name: "Cucumber", emoji: "🥒", texture: .crunchy, flavor: .bland, temperature: .cold, aroma: .noOdor, category: .vegetable, planetColorHex: "2E8B57", color: .green, foodGroup: .vegetable),
        FoodItem(name: "Celery", emoji: "🥬", texture: .crunchy, flavor: .bland, temperature: .cold, aroma: .mild, category: .vegetable, planetColorHex: "7CFC00", color: .green, foodGroup: .vegetable),
        FoodItem(name: "Avocado", emoji: "🥑", texture: .mushy, flavor: .bland, temperature: .roomTemp, aroma: .noOdor, category: .vegetable, planetColorHex: "556B2F", color: .green, foodGroup: .vegetable),
        FoodItem(name: "Cherry Tomato", emoji: "🍅", texture: .soft, flavor: .sour, temperature: .roomTemp, aroma: .mild, category: .vegetable, planetColorHex: "FF6347", color: .red, foodGroup: .vegetable),
        FoodItem(name: "Mashed Potatoes", emoji: "🥔", texture: .mushy, flavor: .bland, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "F5F5DC", color: .white, foodGroup: .vegetable, allergens: [.dairy]),

        // MARK: - Dairy
        FoodItem(name: "Cheddar Cheese", emoji: "🧀", texture: .soft, flavor: .salty, temperature: .roomTemp, aroma: .mild, category: .dairy, planetColorHex: "FFD700", color: .yellow, foodGroup: .dairy, allergens: [.dairy]),
        FoodItem(name: "Mozzarella", emoji: "🧀", texture: .soft, flavor: .bland, temperature: .roomTemp, aroma: .noOdor, category: .dairy, planetColorHex: "FFFAF0", color: .white, foodGroup: .dairy, allergens: [.dairy]),
        FoodItem(name: "Yogurt", emoji: "🥛", texture: .mushy, flavor: .sweet, temperature: .cold, aroma: .noOdor, category: .dairy, planetColorHex: "FFF0F5", color: .white, foodGroup: .dairy, allergens: [.dairy]),
        FoodItem(name: "Fruit Yogurt", emoji: "🥛", texture: .mushy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .dairy, planetColorHex: "FFB6C1", color: .pink, foodGroup: .dairy, allergens: [.dairy]),
        FoodItem(name: "Milk", emoji: "🥛", texture: .liquid, flavor: .bland, temperature: .cold, aroma: .noOdor, category: .dairy, planetColorHex: "F5F5F5", color: .white, foodGroup: .dairy, allergens: [.dairy]),
        FoodItem(name: "Cottage Cheese", emoji: "🧀", texture: .mushy, flavor: .bland, temperature: .cold, aroma: .mild, category: .dairy, planetColorHex: "FFFACD", color: .white, foodGroup: .dairy, allergens: [.dairy]),
        FoodItem(name: "Pudding", emoji: "🍮", texture: .mushy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .dairy, planetColorHex: "D2B48C", color: .brown, foodGroup: .dairy, allergens: [.dairy]),
        FoodItem(name: "Mozzarella Sticks", emoji: "🧀", texture: .soft, flavor: .salty, temperature: .hot, aroma: .mild, category: .dairy, planetColorHex: "FFA500", color: .golden, foodGroup: .mixed, allergens: [.dairy, .gluten]),
        FoodItem(name: "Cheese Slices", emoji: "🧀", texture: .soft, flavor: .salty, temperature: .cold, aroma: .mild, category: .dairy, planetColorHex: "FFD700", color: .yellow, foodGroup: .dairy, allergens: [.dairy]),
        FoodItem(name: "String Cheese", emoji: "🧀", texture: .soft, flavor: .bland, temperature: .cold, aroma: .noOdor, category: .dairy, planetColorHex: "FFFFF0", color: .white, foodGroup: .dairy, allergens: [.dairy]),

        // MARK: - Liquids & Soups
        FoodItem(name: "Chicken Broth", emoji: "🍲", texture: .liquid, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "DAA520", color: .golden, foodGroup: .protein),
        FoodItem(name: "Tomato Soup", emoji: "🍅", texture: .liquid, flavor: .salty, temperature: .hot, aroma: .strong, category: .vegetable, planetColorHex: "FF6347", color: .red, foodGroup: .vegetable),
        FoodItem(name: "Miso Soup", emoji: "🍜", texture: .liquid, flavor: .salty, temperature: .hot, aroma: .strong, category: .protein, planetColorHex: "C8A96E", color: .brown, foodGroup: .protein, allergens: [.soy]),
        FoodItem(name: "Smoothie", emoji: "🥤", texture: .liquid, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FF69B4", color: .pink, foodGroup: .fruit, allergens: [.dairy]),
        FoodItem(name: "Orange Juice", emoji: "🧃", texture: .liquid, flavor: .sour, temperature: .cold, aroma: .strong, category: .fruit, planetColorHex: "FFA500", color: .orange, foodGroup: .fruit),
        FoodItem(name: "Apple Juice", emoji: "🧃", texture: .liquid, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FFD700", color: .yellow, foodGroup: .fruit),
        FoodItem(name: "Chocolate Milk", emoji: "🥛", texture: .liquid, flavor: .sweet, temperature: .cold, aroma: .mild, category: .dairy, planetColorHex: "8B4513", color: .brown, foodGroup: .dairy, allergens: [.dairy]),
        FoodItem(name: "Lemonade", emoji: "🍋", texture: .liquid, flavor: .sour, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FFFACD", color: .yellow, foodGroup: .fruit),

        // MARK: - Beige 20 (safe-food aisle, ingredient-tagged)
        FoodItem(name: "Potato Chips", emoji: "🥔", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "F0C75E", color: .golden, foodGroup: .grain, allergens: [], mouthfeel: .crispy, prepMethod: .fried, textureScore: 8.2, flavorSweet: 0.6, flavorSalty: 7.4, flavorSavory: 2.8, flavorSour: 0.3, flavorBitter: 0.4, temperatureCelsius: 21),
        FoodItem(name: "Cheez-Its", emoji: "🧀", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "FF8C00", color: .orange, foodGroup: .grain, allergens: [.gluten, .dairy], mouthfeel: .crispy, prepMethod: .baked, textureScore: 8.0, flavorSweet: 0.8, flavorSalty: 7.2, flavorSavory: 4.0, flavorSour: 0.3, flavorBitter: 0.4, temperatureCelsius: 21),
        FoodItem(name: "Ritz Crackers", emoji: "🍘", texture: .crunchy, flavor: .salty, temperature: .roomTemp, aroma: .noOdor, category: .grain, planetColorHex: "E8C36A", color: .golden, foodGroup: .grain, allergens: [.gluten, .dairy], mouthfeel: .crispy, prepMethod: .baked, textureScore: 7.6, flavorSweet: 1.4, flavorSalty: 5.8, flavorSavory: 2.4, flavorSour: 0.2, flavorBitter: 0.3, temperatureCelsius: 21),
        FoodItem(name: "Saltines", emoji: "🍘", texture: .crunchy, flavor: .bland, temperature: .roomTemp, aroma: .noOdor, category: .grain, planetColorHex: "F5F5DC", color: .white, foodGroup: .grain, allergens: [.gluten], mouthfeel: .crispy, prepMethod: .baked, textureScore: 7.4, flavorSweet: 0.8, flavorSalty: 4.2, flavorSavory: 1.6, flavorSour: 0.2, flavorBitter: 0.2, temperatureCelsius: 21),
        FoodItem(name: "Animal Crackers", emoji: "🦁", texture: .crunchy, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "D2B48C", color: .brown, foodGroup: .grain, allergens: [.gluten], mouthfeel: .crispy, prepMethod: .baked, textureScore: 7.2, flavorSweet: 5.5, flavorSalty: 1.8, flavorSavory: 1.2, flavorSour: 0.3, flavorBitter: 0.3, temperatureCelsius: 21),
        FoodItem(name: "Rice Cakes", emoji: "🍘", texture: .crunchy, flavor: .bland, temperature: .roomTemp, aroma: .noOdor, category: .grain, planetColorHex: "FFF8DC", color: .white, foodGroup: .grain, allergens: [], mouthfeel: .crispy, prepMethod: .baked, textureScore: 7.8, flavorSweet: 0.6, flavorSalty: 1.8, flavorSavory: 1.0, flavorSour: 0.1, flavorBitter: 0.2, temperatureCelsius: 21),
        FoodItem(name: "Tater Tots", emoji: "🍟", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "DAA520", color: .golden, foodGroup: .vegetable, allergens: [], mouthfeel: .crispy, prepMethod: .fried, textureScore: 7.4, flavorSweet: 1.0, flavorSalty: 6.2, flavorSavory: 3.0, flavorSour: 0.2, flavorBitter: 0.3, temperatureCelsius: 70),
        FoodItem(name: "Hash Browns", emoji: "🥔", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .vegetable, planetColorHex: "C4A35A", color: .golden, foodGroup: .vegetable, allergens: [], mouthfeel: .crispy, prepMethod: .fried, textureScore: 6.8, flavorSweet: 0.8, flavorSalty: 5.6, flavorSavory: 2.8, flavorSour: 0.2, flavorBitter: 0.3, temperatureCelsius: 70),
        FoodItem(name: "Corn Dog", emoji: "🌭", texture: .mixedTexture, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "B8860B", color: .golden, foodGroup: .protein, allergens: [.gluten, .egg], mouthfeel: .chewy, prepMethod: .fried, textureScore: 5.8, flavorSweet: 1.6, flavorSalty: 6.0, flavorSavory: 4.8, flavorSour: 0.3, flavorBitter: 0.4, temperatureCelsius: 70),
        FoodItem(name: "Chicken Tenders", emoji: "🍗", texture: .crunchy, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "DAA520", color: .golden, foodGroup: .protein, allergens: [.gluten], mouthfeel: .crispy, prepMethod: .fried, textureScore: 7.6, flavorSweet: 0.8, flavorSalty: 6.4, flavorSavory: 5.2, flavorSour: 0.3, flavorBitter: 0.4, temperatureCelsius: 72),
        FoodItem(name: "Meatballs", emoji: "🍖", texture: .soft, flavor: .salty, temperature: .hot, aroma: .mild, category: .protein, planetColorHex: "8B4513", color: .brown, foodGroup: .protein, allergens: [.gluten, .egg], mouthfeel: .tender, prepMethod: .baked, textureScore: 4.2, flavorSweet: 1.0, flavorSalty: 5.8, flavorSavory: 6.4, flavorSour: 0.6, flavorBitter: 0.5, temperatureCelsius: 70),
        FoodItem(name: "Butter Noodles", emoji: "🍝", texture: .soft, flavor: .bland, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "F5DEB3", color: .yellow, foodGroup: .grain, allergens: [.gluten, .dairy], mouthfeel: .tender, prepMethod: .boiled, textureScore: 3.8, flavorSweet: 1.0, flavorSalty: 3.2, flavorSavory: 2.8, flavorSour: 0.2, flavorBitter: 0.2, temperatureCelsius: 65),
        FoodItem(name: "Ice Cream", emoji: "🍦", texture: .mushy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .dairy, planetColorHex: "FFF5EE", color: .white, foodGroup: .dairy, allergens: [.dairy], mouthfeel: .creamy, prepMethod: .mixed, textureScore: 2.2, flavorSweet: 7.4, flavorSalty: 1.2, flavorSavory: 1.4, flavorSour: 0.4, flavorBitter: 0.3, temperatureCelsius: 0),
        FoodItem(name: "Popsicle", emoji: "🍭", texture: .liquid, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FF69B4", color: .pink, foodGroup: .fruit, allergens: [], mouthfeel: .juicy, prepMethod: .mixed, textureScore: 1.6, flavorSweet: 7.0, flavorSalty: 0.4, flavorSavory: 0.3, flavorSour: 2.2, flavorBitter: 0.2, temperatureCelsius: -2),
        FoodItem(name: "Jello", emoji: "🍮", texture: .mushy, flavor: .sweet, temperature: .cold, aroma: .mild, category: .fruit, planetColorHex: "FF1493", color: .red, foodGroup: .other, allergens: [], mouthfeel: .juicy, prepMethod: .mixed, textureScore: 2.0, flavorSweet: 6.8, flavorSalty: 0.6, flavorSavory: 0.3, flavorSour: 1.6, flavorBitter: 0.2, temperatureCelsius: 6),
        FoodItem(name: "Chocolate Chip Cookie", emoji: "🍪", texture: .soft, flavor: .sweet, temperature: .roomTemp, aroma: .mild, category: .grain, planetColorHex: "8B5A2B", color: .brown, foodGroup: .grain, allergens: [.gluten, .egg], mouthfeel: .chewy, prepMethod: .baked, textureScore: 5.2, flavorSweet: 7.2, flavorSalty: 2.4, flavorSavory: 1.6, flavorSour: 0.2, flavorBitter: 1.8, temperatureCelsius: 21),
        FoodItem(name: "French Toast", emoji: "🍞", texture: .soft, flavor: .sweet, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "D2691E", color: .golden, foodGroup: .grain, allergens: [.gluten, .egg, .dairy], mouthfeel: .tender, prepMethod: .fried, textureScore: 4.4, flavorSweet: 6.2, flavorSalty: 2.2, flavorSavory: 2.4, flavorSour: 0.3, flavorBitter: 0.3, temperatureCelsius: 68),
        FoodItem(name: "Pickles", emoji: "🥒", texture: .crunchy, flavor: .sour, temperature: .cold, aroma: .mild, category: .vegetable, planetColorHex: "6B8E23", color: .green, foodGroup: .vegetable, allergens: [], mouthfeel: .crispy, prepMethod: .raw, textureScore: 7.0, flavorSweet: 1.2, flavorSalty: 6.4, flavorSavory: 1.8, flavorSour: 7.6, flavorBitter: 0.6, temperatureCelsius: 5),
        FoodItem(name: "Hard-Boiled Egg", emoji: "🥚", texture: .soft, flavor: .bland, temperature: .cold, aroma: .mild, category: .protein, planetColorHex: "FFF8DC", color: .white, foodGroup: .protein, allergens: [.egg], mouthfeel: .tender, prepMethod: .boiled, textureScore: 4.0, flavorSweet: 0.6, flavorSalty: 1.8, flavorSavory: 3.6, flavorSour: 0.2, flavorBitter: 0.3, temperatureCelsius: 8),
        FoodItem(name: "Buttered Toast", emoji: "🍞", texture: .crunchy, flavor: .bland, temperature: .hot, aroma: .mild, category: .grain, planetColorHex: "DEB887", color: .golden, foodGroup: .grain, allergens: [.gluten, .dairy], mouthfeel: .crispy, prepMethod: .baked, textureScore: 6.6, flavorSweet: 1.4, flavorSalty: 3.0, flavorSavory: 2.6, flavorSour: 0.2, flavorBitter: 0.3, temperatureCelsius: 55),
    ]

    static let beige20Names: [String] = [
        "Potato Chips", "Cheez-Its", "Ritz Crackers", "Saltines", "Animal Crackers",
        "Rice Cakes", "Tater Tots", "Hash Browns", "Corn Dog", "Chicken Tenders",
        "Meatballs", "Butter Noodles", "Ice Cream", "Popsicle", "Jello",
        "Chocolate Chip Cookie", "French Toast", "Pickles", "Hard-Boiled Egg", "Buttered Toast",
    ]

    static var beige20Ids: [UUID] {
        beige20Names.compactMap { food(byName: $0)?.id }
    }

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

    static func search(_ query: String, in foods: [FoodItem]) -> [FoodItem] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return foods }
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()

        var exact: [FoodItem] = []
        var prefix: [FoodItem] = []
        var contains: [FoodItem] = []
        var fuzzy: [FoodItem] = []

        for food in foods {
            let lower = food.name.lowercased()
            let words = lower.split(separator: " ").map(String.init)

            if lower == trimmed || words.contains(trimmed) {
                exact.append(food)
            } else if lower.hasPrefix(trimmed) || words.contains(where: { $0.hasPrefix(trimmed) }) {
                prefix.append(food)
            } else if lower.localizedStandardContains(trimmed) {
                contains.append(food)
            } else if fuzzyMatch(trimmed, lower) {
                fuzzy.append(food)
            }
        }

        return exact + prefix + contains + fuzzy
    }

    private static func fuzzyMatch(_ query: String, _ target: String) -> Bool {
        guard query.count >= 3 else { return false }
        let distance = levenshteinDistance(query, target)
        let threshold = max(1, query.count / 3)
        if distance <= threshold { return true }
        let words = target.split(separator: " ").map(String.init)
        for word in words {
            let wordDist = levenshteinDistance(query, word)
            if wordDist <= threshold { return true }
        }
        return false
    }

    private static func levenshteinDistance(_ s: String, _ t: String) -> Int {
        let sArr = Array(s)
        let tArr = Array(t)
        let sLen = sArr.count
        let tLen = tArr.count
        if sLen == 0 { return tLen }
        if tLen == 0 { return sLen }
        var prev = Array(0...tLen)
        var curr = [Int](repeating: 0, count: tLen + 1)
        for i in 1...sLen {
            curr[0] = i
            for j in 1...tLen {
                let cost = sArr[i - 1] == tArr[j - 1] ? 0 : 1
                curr[j] = min(prev[j] + 1, curr[j - 1] + 1, prev[j - 1] + cost)
            }
            prev = curr
        }
        return prev[tLen]
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
