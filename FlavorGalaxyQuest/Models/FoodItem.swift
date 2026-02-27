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
    let allergens: Set<Allergen>
    let commonBrands: [String]

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
        allergens: Set<Allergen> = [],
        commonBrands: [String] = []
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
        self.allergens = allergens
        self.commonBrands = commonBrands
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
