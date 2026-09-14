import Foundation

nonisolated enum FoodTexture: String, Codable, CaseIterable, Sendable, Hashable {
    case crunchy, soft, mushy, liquid, mixedTexture

    var label: String {
        switch self {
        case .crunchy: "Crunchy"
        case .soft: "Soft"
        case .mushy: "Mushy"
        case .liquid: "Liquid"
        case .mixedTexture: "Mixed"
        }
    }

    var scaleRank: Int {
        switch self {
        case .crunchy: 0
        case .soft: 1
        case .mushy: 2
        case .liquid: 3
        case .mixedTexture: 4
        }
    }

    /// 0-10 liquid → hard, matching the repaired matcher.
    var matcherScore: Double {
        switch self {
        case .liquid: 1.0
        case .mushy: 2.5
        case .soft: 4.0
        case .mixedTexture: 5.5
        case .crunchy: 8.0
        }
    }
}

nonisolated enum FoodFlavor: String, Codable, CaseIterable, Sendable, Hashable {
    case bland, salty, sweet, sour, bitter

    var label: String {
        switch self {
        case .bland: "Bland"
        case .salty: "Salty"
        case .sweet: "Sweet"
        case .sour: "Sour"
        case .bitter: "Bitter"
        }
    }
}

nonisolated enum FoodTemperature: String, Codable, CaseIterable, Sendable, Hashable {
    case hot, roomTemp, cold

    var label: String {
        switch self {
        case .hot: "Hot"
        case .roomTemp: "Room Temp"
        case .cold: "Cold"
        }
    }

    /// Celsius, matching the repaired matcher 0-100 scale.
    var matcherCelsius: Double {
        switch self {
        case .cold: 5
        case .roomTemp: 21
        case .hot: 70
        }
    }
}

nonisolated enum FoodAroma: String, Codable, CaseIterable, Sendable, Hashable {
    case noOdor, mild, strong

    var label: String {
        switch self {
        case .noOdor: "No Odor"
        case .mild: "Mild"
        case .strong: "Strong"
        }
    }
}

nonisolated enum FoodColor: String, Codable, CaseIterable, Sendable, Hashable {
    case red, orange, yellow, green, blue, purple, brown, white, golden, pink, mixed

    var emoji: String {
        switch self {
        case .red: "🔴"
        case .orange: "🟠"
        case .yellow: "🟡"
        case .green: "🟢"
        case .blue: "🔵"
        case .purple: "🟣"
        case .brown: "🟤"
        case .white: "⚪"
        case .golden: "🟡"
        case .pink: "🩷"
        case .mixed: "🌈"
        }
    }

    /// Swatch hex for UI (no emoji).
    var hex: String {
        switch self {
        case .red: "EF4444"
        case .orange: "F97316"
        case .yellow: "EAB308"
        case .green: "22C55E"
        case .blue: "3B82F6"
        case .purple: "A855F7"
        case .brown: "92400E"
        case .white: "E5E7EB"
        case .golden: "F59E0B"
        case .pink: "EC4899"
        case .mixed: "8B5CF6"
        }
    }

    var label: String {
        switch self {
        case .red: "Red"
        case .orange: "Orange"
        case .yellow: "Yellow"
        case .green: "Green"
        case .blue: "Blue"
        case .purple: "Purple"
        case .brown: "Brown"
        case .white: "White"
        case .golden: "Golden"
        case .pink: "Pink"
        case .mixed: "Mixed"
        }
    }

    /// Concrete matcher color. Golden maps to yellow; mixed stays mixed.
    var matcherValue: String {
        switch self {
        case .golden: "yellow"
        case .mixed: "mixed"
        default: rawValue
        }
    }
}

nonisolated enum FoodGroup: String, Codable, CaseIterable, Sendable, Hashable {
    case fruit, vegetable, protein, grain, dairy, mixed, other

    var label: String {
        switch self {
        case .fruit: "Fruit"
        case .vegetable: "Vegetable"
        case .protein: "Protein"
        case .grain: "Grain"
        case .dairy: "Dairy"
        case .mixed: "Mixed"
        case .other: "Other"
        }
    }

    var icon: String {
        switch self {
        case .fruit: "leaf.fill"
        case .vegetable: "carrot.fill"
        case .grain: "birthday.cake.fill"
        case .protein: "fish.fill"
        case .dairy: "cup.and.saucer.fill"
        case .mixed: "square.stack.3d.up.fill"
        case .other: "questionmark.circle.fill"
        }
    }

    /// Nutritional group string used by the repaired variety pick.
    var matcherValue: String {
        rawValue
    }

    static func fromCategory(_ category: FoodCategory) -> FoodGroup {
        switch category {
        case .fruit: .fruit
        case .vegetable: .vegetable
        case .grain: .grain
        case .protein: .protein
        case .dairy: .dairy
        }
    }
}

nonisolated enum FoodCategory: String, Codable, CaseIterable, Sendable, Hashable {
    case fruit, vegetable, grain, protein, dairy

    var label: String {
        switch self {
        case .fruit: "Fruit"
        case .vegetable: "Vegetable"
        case .grain: "Grain"
        case .protein: "Protein"
        case .dairy: "Dairy"
        }
    }

    var icon: String {
        switch self {
        case .fruit: "leaf.fill"
        case .vegetable: "carrot.fill"
        case .grain: "birthday.cake.fill"
        case .protein: "fish.fill"
        case .dairy: "cup.and.saucer.fill"
        }
    }
}

nonisolated struct FoodItem: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let emoji: String
    let texture: FoodTexture
    let flavor: FoodFlavor
    let temperature: FoodTemperature
    let aroma: FoodAroma
    let category: FoodCategory
    let planetColorHex: String
    let color: FoodColor
    let foodGroup: FoodGroup
    let allergens: Set<Allergen>
    let commonBrands: [String]
    let mouthfeel: FoodMouthfeel
    let prepMethod: FoodPrepMethod
    let textureScore: Double
    let flavorSweet: Double
    let flavorSalty: Double
    let flavorSavory: Double
    let flavorSour: Double
    let flavorBitter: Double
    let temperatureCelsius: Double

    /// Asset catalog name (`food_<stem>`) for the illustrated icon.
    var iconName: String {
        "food_\(Self.iconStem(for: name).replacingOccurrences(of: "-", with: "_"))"
    }

    static let customGemIconName = "food_custom_gem"

    private static let iconStemAliases: [String: String] = [
        "Blueberry": "blueberries",
        "Grape": "grapes",
        "Cheddar Cheese": "cheddar",
        "Fruit Roll-Ups": "fruit-roll-up",
        "Goldfish Crackers": "goldfish",
        "Ritz Crackers": "ritz",
        "PB&J Sandwich": "pbj",
        "Mac & Cheese": "mac-and-cheese",
    ]

    static func iconStem(for name: String) -> String {
        if let alias = iconStemAliases[name] {
            return alias
        }
        return defaultIconStem(name)
    }

    private static func defaultIconStem(_ name: String) -> String {
        var s = name.lowercased().replacingOccurrences(of: "&", with: " and ")
        var out = ""
        for ch in s {
            if ch.isLetter || ch.isNumber || ch == "-" {
                out.append(ch)
            } else {
                out.append(" ")
            }
        }
        return out.split(whereSeparator: { $0.isWhitespace }).joined(separator: "-")
    }

    init(
        id: UUID? = nil,
        name: String,
        emoji: String,
        texture: FoodTexture,
        flavor: FoodFlavor,
        temperature: FoodTemperature,
        aroma: FoodAroma,
        category: FoodCategory,
        planetColorHex: String,
        color: FoodColor = .brown,
        foodGroup: FoodGroup? = nil,
        allergens: Set<Allergen> = [],
        commonBrands: [String] = [],
        mouthfeel: FoodMouthfeel? = nil,
        prepMethod: FoodPrepMethod? = nil,
        textureScore: Double? = nil,
        flavorSweet: Double? = nil,
        flavorSalty: Double? = nil,
        flavorSavory: Double? = nil,
        flavorSour: Double? = nil,
        flavorBitter: Double? = nil,
        temperatureCelsius: Double? = nil
    ) {
        self.id = id ?? FoodItem.stableID(name)
        self.name = name
        self.emoji = emoji
        self.texture = texture
        self.flavor = flavor
        self.temperature = temperature
        self.aroma = aroma
        self.category = category
        self.planetColorHex = planetColorHex
        self.color = color
        self.foodGroup = foodGroup ?? FoodGroup.fromCategory(category)
        self.allergens = allergens
        self.commonBrands = commonBrands
        let inferred = FoodSensoryInference.infer(name: name, texture: texture, flavor: flavor, temperature: temperature, category: category, foodGroup: foodGroup ?? FoodGroup.fromCategory(category))
        self.mouthfeel = mouthfeel ?? inferred.mouthfeel
        self.prepMethod = prepMethod ?? inferred.prepMethod
        self.textureScore = textureScore ?? inferred.textureScore
        self.flavorSweet = flavorSweet ?? inferred.flavorSweet
        self.flavorSalty = flavorSalty ?? inferred.flavorSalty
        self.flavorSavory = flavorSavory ?? inferred.flavorSavory
        self.flavorSour = flavorSour ?? inferred.flavorSour
        self.flavorBitter = flavorBitter ?? inferred.flavorBitter
        self.temperatureCelsius = temperatureCelsius ?? inferred.temperatureCelsius
    }

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, texture, flavor, temperature, aroma, category
        case planetColorHex, color, foodGroup, allergens, commonBrands
        case mouthfeel, prepMethod, textureScore
        case flavorSweet, flavorSalty, flavorSavory, flavorSour, flavorBitter
        case temperatureCelsius
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let name = try c.decode(String.self, forKey: .name)
        let texture = try c.decode(FoodTexture.self, forKey: .texture)
        let flavor = try c.decode(FoodFlavor.self, forKey: .flavor)
        let temperature = try c.decode(FoodTemperature.self, forKey: .temperature)
        let category = try c.decode(FoodCategory.self, forKey: .category)
        let foodGroup = try c.decodeIfPresent(FoodGroup.self, forKey: .foodGroup) ?? FoodGroup.fromCategory(category)
        let inferred = FoodSensoryInference.infer(name: name, texture: texture, flavor: flavor, temperature: temperature, category: category, foodGroup: foodGroup)

        self.id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? FoodItem.stableID(name)
        self.name = name
        self.emoji = try c.decode(String.self, forKey: .emoji)
        self.texture = texture
        self.flavor = flavor
        self.temperature = temperature
        self.aroma = try c.decode(FoodAroma.self, forKey: .aroma)
        self.category = category
        self.planetColorHex = try c.decode(String.self, forKey: .planetColorHex)
        self.color = try c.decodeIfPresent(FoodColor.self, forKey: .color) ?? .brown
        self.foodGroup = foodGroup
        self.allergens = try c.decodeIfPresent(Set<Allergen>.self, forKey: .allergens) ?? []
        self.commonBrands = try c.decodeIfPresent([String].self, forKey: .commonBrands) ?? []
        self.mouthfeel = try c.decodeIfPresent(FoodMouthfeel.self, forKey: .mouthfeel) ?? inferred.mouthfeel
        self.prepMethod = try c.decodeIfPresent(FoodPrepMethod.self, forKey: .prepMethod) ?? inferred.prepMethod
        self.textureScore = try c.decodeIfPresent(Double.self, forKey: .textureScore) ?? inferred.textureScore
        self.flavorSweet = try c.decodeIfPresent(Double.self, forKey: .flavorSweet) ?? inferred.flavorSweet
        self.flavorSalty = try c.decodeIfPresent(Double.self, forKey: .flavorSalty) ?? inferred.flavorSalty
        self.flavorSavory = try c.decodeIfPresent(Double.self, forKey: .flavorSavory) ?? inferred.flavorSavory
        self.flavorSour = try c.decodeIfPresent(Double.self, forKey: .flavorSour) ?? inferred.flavorSour
        self.flavorBitter = try c.decodeIfPresent(Double.self, forKey: .flavorBitter) ?? inferred.flavorBitter
        self.temperatureCelsius = try c.decodeIfPresent(Double.self, forKey: .temperatureCelsius) ?? inferred.temperatureCelsius
    }

    private static func stableID(_ seed: String) -> UUID {
        var bytes = [UInt8](repeating: 0, count: 16)
        let seedBytes = Array(seed.lowercased().utf8)
        for (i, byte) in seedBytes.enumerated() {
            bytes[i % 16] = bytes[i % 16] &+ byte
        }
        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}

/// Honest catalog defaults from the food name + existing enums so the matcher can run.
nonisolated enum FoodSensoryInference: Sendable {
    struct Result: Sendable {
        var textureScore: Double
        var flavorSweet: Double
        var flavorSalty: Double
        var flavorSavory: Double
        var flavorSour: Double
        var flavorBitter: Double
        var temperatureCelsius: Double
        var mouthfeel: FoodMouthfeel
        var prepMethod: FoodPrepMethod
    }

    static func infer(
        name: String,
        texture: FoodTexture,
        flavor: FoodFlavor,
        temperature: FoodTemperature,
        category: FoodCategory,
        foodGroup: FoodGroup
    ) -> Result {
        var sweet = 1.0, salty = 1.0, savory = 1.0, sour = 0.5, bitter = 0.5
        switch flavor {
        case .bland:
            sweet = 1.0; salty = 1.5; savory = 1.8; sour = 0.4; bitter = 0.4
        case .salty:
            sweet = 0.6; salty = 7.0; savory = 3.2; sour = 0.4; bitter = 0.5
        case .sweet:
            sweet = 7.0; salty = 1.0; savory = 1.0; sour = 1.2; bitter = 0.4
        case .sour:
            sweet = 2.2; salty = 1.0; savory = 1.0; sour = 7.0; bitter = 0.5
        case .bitter:
            sweet = 0.5; salty = 1.0; savory = 2.0; sour = 1.0; bitter = 6.5
        }

        let lower = name.lowercased()
        if foodGroup == .protein || category == .protein {
            savory = max(savory, 4.5)
        }
        if lower.contains("cheese") || lower.contains("cheddar") || lower.contains("mozzarella") || lower.contains("mac") {
            savory = max(savory, 4.0)
            salty = max(salty, 4.5)
        }
        if lower.contains("bacon") || lower.contains("hot dog") || lower.contains("deli") {
            salty = max(salty, 7.0)
            savory = max(savory, 5.5)
        }
        if lower.contains("pickle") {
            sour = max(sour, 7.5)
            salty = max(salty, 6.0)
        }
        if lower.contains("chocolate") {
            sweet = max(sweet, 6.5)
            bitter = max(bitter, 2.5)
        }
        if lower.contains("butter") {
            savory = max(savory, 3.0)
        }

        var mouthfeel: FoodMouthfeel
        switch texture {
        case .crunchy: mouthfeel = .crispy
        case .soft: mouthfeel = .tender
        case .mushy: mouthfeel = .creamy
        case .liquid: mouthfeel = .juicy
        case .mixedTexture: mouthfeel = .mixed
        }
        if lower.contains("ice cream") || lower.contains("yogurt") || lower.contains("pudding") || lower.contains("hummus") || lower.contains("avocado") {
            mouthfeel = .creamy
        } else if lower.contains("jerky") || lower.contains("bagel") || lower.contains("meatball") || lower.contains("corn dog") {
            mouthfeel = .chewy
        } else if lower.contains("juice") || lower.contains("watermelon") || lower.contains("orange") || lower.contains("grape") {
            mouthfeel = .juicy
        } else if lower.contains("cracker") || lower.contains("chip") || lower.contains("pretzel") || lower.contains("toast") || lower.contains("rice cake") {
            mouthfeel = .crispy
        } else if lower.contains("bread") || lower.contains("muffin") || lower.contains("noodle") || lower.contains("pasta") {
            mouthfeel = .tender
        } else if lower.contains("jello") || lower.contains("popsicle") {
            mouthfeel = .juicy
        }

        var prep: FoodPrepMethod
        if category == .fruit || lower.contains("pickle") || lower.contains("carrot") || lower.contains("celery") || lower.contains("cucumber") || lower.contains("pepper") {
            prep = temperature == .hot ? .steamed : .raw
        } else if texture == .liquid {
            prep = temperature == .hot ? .boiled : .mixed
        } else if texture == .crunchy && temperature == .hot {
            prep = .fried
        } else if texture == .mushy && temperature == .hot {
            prep = .boiled
        } else if category == .grain && temperature == .hot && (lower.contains("rice") || lower.contains("pasta") || lower.contains("noodle") || lower.contains("oatmeal")) {
            prep = .boiled
        } else if temperature == .hot && (lower.contains("steam") || category == .vegetable) {
            prep = .steamed
        } else if lower.contains("toast") || lower.contains("cracker") || lower.contains("cookie") || lower.contains("bread") || lower.contains("bagel") {
            prep = .baked
        } else if lower.contains("nugget") || lower.contains("tender") || lower.contains("fry") || lower.contains("tot") || lower.contains("hash") || lower.contains("corn dog") {
            prep = .fried
        } else if lower.contains("egg") && lower.contains("boil") {
            prep = .boiled
        } else if temperature == .hot {
            prep = .baked
        } else {
            prep = category == .fruit || category == .vegetable ? .raw : .baked
        }

        return Result(
            textureScore: texture.matcherScore,
            flavorSweet: sweet,
            flavorSalty: salty,
            flavorSavory: savory,
            flavorSour: sour,
            flavorBitter: bitter,
            temperatureCelsius: temperature.matcherCelsius,
            mouthfeel: mouthfeel,
            prepMethod: prep
        )
    }
}
