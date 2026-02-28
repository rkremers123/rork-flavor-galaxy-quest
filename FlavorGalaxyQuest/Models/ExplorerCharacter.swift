import Foundation

nonisolated enum ExplorerType: String, Codable, CaseIterable, Sendable, Hashable {
    case nova
    case cosmo
    case star
    case orbit

    var defaultName: String {
        switch self {
        case .nova: "Nova"
        case .cosmo: "Cosmo"
        case .star: "Star"
        case .orbit: "Orbit"
        }
    }

    var emoji: String {
        switch self {
        case .nova: "🚀"
        case .cosmo: "🔭"
        case .star: "🌟"
        case .orbit: "🛸"
        }
    }

    var title: String {
        switch self {
        case .nova: "Speed Explorer"
        case .cosmo: "Science Explorer"
        case .star: "Brave Explorer"
        case .orbit: "Adventurous Explorer"
        }
    }

    var tagline: String {
        switch self {
        case .nova: "Loves discovering fast & trying new things!"
        case .cosmo: "Curious about flavors & tastes!"
        case .star: "Not afraid to try new things!"
        case .orbit: "Loves collecting & exploring!"
        }
    }

    var accentHex: String {
        switch self {
        case .nova: "FF6B6B"
        case .cosmo: "4ECDC4"
        case .star: "FFD93D"
        case .orbit: "6C5CE7"
        }
    }
}

nonisolated enum ExplorerLevel: Int, Codable, CaseIterable, Sendable {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    case level5 = 5

    var title: String {
        switch self {
        case .level1: "Rookie Explorer"
        case .level2: "Sensory Expert"
        case .level3: "Brave Taster"
        case .level4: "Flavor Master"
        case .level5: "Galaxy Legend"
        }
    }

    var pointsRequired: Int {
        switch self {
        case .level1: 0
        case .level2: 100
        case .level3: 250
        case .level4: 450
        case .level5: 700
        }
    }

    var nextLevelPoints: Int? {
        switch self {
        case .level1: 100
        case .level2: 250
        case .level3: 450
        case .level4: 700
        case .level5: nil
        }
    }

    static func level(for points: Int) -> ExplorerLevel {
        if points >= 700 { return .level5 }
        if points >= 450 { return .level4 }
        if points >= 250 { return .level3 }
        if points >= 100 { return .level2 }
        return .level1
    }

    static func progressToNext(points: Int) -> Double {
        let current = level(for: points)
        guard let next = current.nextLevelPoints else { return 1.0 }
        let base = current.pointsRequired
        let range = next - base
        guard range > 0 else { return 1.0 }
        return Double(points - base) / Double(range)
    }
}

nonisolated enum JourneyPlanet: Int, Codable, CaseIterable, Sendable, Identifiable {
    case baseCamp = 0
    case sensoryGrove = 1
    case flavorMountains = 2
    case crystalCaves = 3
    case tasteOcean = 4
    case stardustFields = 5
    case nebulaRidge = 6
    case harvestFestival = 7

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .baseCamp: "Base Camp"
        case .sensoryGrove: "Sensory Grove"
        case .flavorMountains: "Flavor Mountains"
        case .crystalCaves: "Crystal Caves"
        case .tasteOcean: "Taste Ocean"
        case .stardustFields: "Stardust Fields"
        case .nebulaRidge: "Nebula Ridge"
        case .harvestFestival: "Harvest Festival"
        }
    }

    var emoji: String {
        switch self {
        case .baseCamp: "🏕"
        case .sensoryGrove: "🌲"
        case .flavorMountains: "⛰"
        case .crystalCaves: "💎"
        case .tasteOcean: "🌊"
        case .stardustFields: "✨"
        case .nebulaRidge: "☄️"
        case .harvestFestival: "🎉"
        }
    }

    var subtitle: String {
        switch self {
        case .baseCamp: "Starting Point"
        case .sensoryGrove: "Look & Touch"
        case .flavorMountains: "Smell & Taste"
        case .crystalCaves: "Deep Discovery"
        case .tasteOcean: "Full Consumption"
        case .stardustFields: "Bold Flavors"
        case .nebulaRidge: "Final Frontier"
        case .harvestFestival: "Master Explorer"
        }
    }

    static let foodsPerPlanet: Int = 5

    var foodsRequired: Int { rawValue * Self.foodsPerPlanet }

    var accentColor: String {
        switch self {
        case .baseCamp: "22C55E"
        case .sensoryGrove: "06B6D4"
        case .flavorMountains: "EC4899"
        case .crystalCaves: "8B5CF6"
        case .tasteOcean: "3B82F6"
        case .stardustFields: "F59E0B"
        case .nebulaRidge: "EF4444"
        case .harvestFestival: "EAB308"
        }
    }

    func foodsCompleted(totalExplored: Int) -> Int {
        min(max(totalExplored - foodsRequired, 0), Self.foodsPerPlanet)
    }

    func isCompleted(totalExplored: Int) -> Bool {
        foodsCompleted(totalExplored: totalExplored) >= Self.foodsPerPlanet
    }

    func isLocked(totalExplored: Int) -> Bool {
        totalExplored < foodsRequired
    }

    static func current(for foodsExplored: Int) -> JourneyPlanet {
        for planet in allCases.reversed() {
            if foodsExplored >= planet.foodsRequired {
                return planet
            }
        }
        return .baseCamp
    }

    static func progressToNext(foodsExplored: Int) -> Double {
        let planet = current(for: foodsExplored)
        let completed = planet.foodsCompleted(totalExplored: foodsExplored)
        return Double(completed) / Double(foodsPerPlanet)
    }
}

nonisolated enum Cosmetic: String, Codable, CaseIterable, Sendable, Hashable {
    case explorerHat
    case flavorBackpack
    case crystalBadge
    case glowAura
    case victoryCrown
    case scienceCap
    case scannerTech
    case sparkleTrail
    case rainbowAura
    case powerGlow

    var name: String {
        switch self {
        case .explorerHat: "Explorer Hat"
        case .flavorBackpack: "Flavor Backpack"
        case .crystalBadge: "Crystal Badge"
        case .glowAura: "Glow Aura"
        case .victoryCrown: "Victory Crown"
        case .scienceCap: "Science Cap"
        case .scannerTech: "Scanner Tech"
        case .sparkleTrail: "Sparkle Trail"
        case .rainbowAura: "Rainbow Aura"
        case .powerGlow: "Power Glow"
        }
    }

    var emoji: String {
        switch self {
        case .explorerHat: "🎩"
        case .flavorBackpack: "🎒"
        case .crystalBadge: "💎"
        case .glowAura: "✨"
        case .victoryCrown: "👑"
        case .scienceCap: "🎓"
        case .scannerTech: "🔭"
        case .sparkleTrail: "⭐️"
        case .rainbowAura: "🌈"
        case .powerGlow: "⚡"
        }
    }

    var category: CosmeticCategory {
        switch self {
        case .explorerHat, .scienceCap, .victoryCrown: .hat
        case .flavorBackpack, .crystalBadge, .scannerTech: .badge
        case .glowAura, .sparkleTrail, .rainbowAura, .powerGlow: .effect
        }
    }

    var requiredLevel: ExplorerLevel {
        switch self {
        case .explorerHat: .level1
        case .flavorBackpack, .scienceCap: .level2
        case .crystalBadge, .sparkleTrail: .level3
        case .glowAura, .scannerTech, .rainbowAura: .level4
        case .victoryCrown, .powerGlow: .level5
        }
    }
}

nonisolated enum CosmeticCategory: String, Codable, CaseIterable, Sendable {
    case hat
    case badge
    case effect

    var label: String {
        switch self {
        case .hat: "Hats & Headgear"
        case .badge: "Badges & Accessories"
        case .effect: "Visual Effects"
        }
    }
}
