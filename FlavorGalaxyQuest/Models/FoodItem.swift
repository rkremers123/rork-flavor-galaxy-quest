import Foundation

nonisolated enum FoodTexture: String, Codable, CaseIterable, Sendable {
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
}

nonisolated enum FoodFlavor: String, Codable, CaseIterable, Sendable {
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

nonisolated enum FoodTemperature: String, Codable, CaseIterable, Sendable {
    case hot, roomTemp, cold

    var label: String {
        switch self {
        case .hot: "Hot"
        case .roomTemp: "Room Temp"
        case .cold: "Cold"
        }
    }
}

nonisolated enum FoodAroma: String, Codable, CaseIterable, Sendable {
    case noOdor, mild, strong

    var label: String {
        switch self {
        case .noOdor: "No Odor"
        case .mild: "Mild"
        case .strong: "Strong"
        }
    }
}

nonisolated enum FoodCategory: String, Codable, CaseIterable, Sendable {
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

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        texture: FoodTexture,
        flavor: FoodFlavor,
        temperature: FoodTemperature,
        aroma: FoodAroma,
        category: FoodCategory,
        planetColorHex: String
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.texture = texture
        self.flavor = flavor
        self.temperature = temperature
        self.aroma = aroma
        self.category = category
        self.planetColorHex = planetColorHex
    }
}
