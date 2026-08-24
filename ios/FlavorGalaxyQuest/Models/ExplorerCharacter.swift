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

    var imageName: String {
        switch self {
        case .nova: "explorer_nova"
        case .cosmo: "explorer_cosmo"
        case .star: "explorer_star"
        case .orbit: "explorer_orbit"
        }
    }

    var boardImageName: String {
        switch self {
        case .nova: "explorer_nova_board"
        case .cosmo: "explorer_cosmo_board"
        case .star: "explorer_star_board"
        case .orbit: "explorer_orbit_board"
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

    var imageName: String {
        switch self {
        case .baseCamp: "planet_base_camp"
        case .sensoryGrove: "planet_sensory_grove"
        case .flavorMountains: "planet_flavor_mountains"
        case .crystalCaves: "planet_texture_trails"
        case .tasteOcean: "planet_taste_ocean"
        case .stardustFields: "planet_aroma_airship"
        case .nebulaRidge: "planet_taste_jungle"
        case .harvestFestival: "planet_galaxys_heart"
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

nonisolated enum CosmeticCategory: String, Codable, CaseIterable, Sendable {
    case achievementBadge
    case milestoneBadge
    case backpack
    case handheld
    case aura
    case particle

    var label: String {
        switch self {
        case .achievementBadge: "Achievement Badges"
        case .milestoneBadge: "Milestone Badges"
        case .backpack: "Backpacks & Bags"
        case .handheld: "Handheld Items"
        case .aura: "Glowing Auras"
        case .particle: "Particle Effects"
        }
    }

    var icon: String {
        switch self {
        case .achievementBadge: "star.circle.fill"
        case .milestoneBadge: "calendar.badge.checkmark"
        case .backpack: "bag.fill"
        case .handheld: "wand.and.stars"
        case .aura: "sparkle"
        case .particle: "bubbles.and.sparkles.fill"
        }
    }
}

nonisolated enum CosmeticUnlockCondition: Sendable {
    case level(ExplorerLevel)
    case foodsLogged(Int)
    case daysLogged(Int)
    case reachPhase(SensoryStep)
    case completeAllPhases
    case foodFamilies(Int)
    case planetsUnlocked(Int)
}

nonisolated enum Cosmetic: String, Codable, CaseIterable, Sendable, Hashable {
    case speedExplorerBadge
    case scienceMasterBadge
    case flavorPioneerBadge
    case sensoryWizardBadge
    case galaxyLegendBadge

    case day7Badge
    case week2Badge
    case month1Badge
    case days100Badge
    case year1Badge

    case cosmicBackpack
    case sensoryExplorerPack
    case flavorQuestSatchel
    case scientistBag

    case cosmicCompass
    case flavorTelescope
    case explorerStaff
    case discoveryWand
    case sensoryScanner

    case cyanNebulaAura
    case goldCosmicAura
    case purpleMysticAura
    case rainbowGalaxyAura

    case stardustTrail
    case cosmicSparkles
    case galaxyShimmer

    var name: String {
        switch self {
        case .speedExplorerBadge: "Speed Explorer"
        case .scienceMasterBadge: "Science Master"
        case .flavorPioneerBadge: "Flavor Pioneer"
        case .sensoryWizardBadge: "Sensory Wizard"
        case .galaxyLegendBadge: "Galaxy Legend"
        case .day7Badge: "Day 7 Explorer"
        case .week2Badge: "Week 2 Navigator"
        case .month1Badge: "Month 1 Master"
        case .days100Badge: "100 Days!"
        case .year1Badge: "Galaxy Guardian"
        case .cosmicBackpack: "Cosmic Backpack"
        case .sensoryExplorerPack: "Sensory Pack"
        case .flavorQuestSatchel: "Flavor Satchel"
        case .scientistBag: "Scientist's Bag"
        case .cosmicCompass: "Cosmic Compass"
        case .flavorTelescope: "Flavor Telescope"
        case .explorerStaff: "Explorer's Staff"
        case .discoveryWand: "Discovery Wand"
        case .sensoryScanner: "Sensory Scanner"
        case .cyanNebulaAura: "Cyan Nebula"
        case .goldCosmicAura: "Gold Cosmic"
        case .purpleMysticAura: "Purple Mystic"
        case .rainbowGalaxyAura: "Rainbow Galaxy"
        case .stardustTrail: "Stardust Trail"
        case .cosmicSparkles: "Cosmic Sparkles"
        case .galaxyShimmer: "Galaxy Shimmer"
        }
    }

    var emoji: String {
        switch self {
        case .speedExplorerBadge: "🚀"
        case .scienceMasterBadge: "🔬"
        case .flavorPioneerBadge: "🍴"
        case .sensoryWizardBadge: "🪄"
        case .galaxyLegendBadge: "👑"
        case .day7Badge: "7️⃣"
        case .week2Badge: "🧭"
        case .month1Badge: "📅"
        case .days100Badge: "💯"
        case .year1Badge: "🛡️"
        case .cosmicBackpack: "🎒"
        case .sensoryExplorerPack: "🌊"
        case .flavorQuestSatchel: "👜"
        case .scientistBag: "🧪"
        case .cosmicCompass: "🧭"
        case .flavorTelescope: "🔭"
        case .explorerStaff: "✨"
        case .discoveryWand: "💫"
        case .sensoryScanner: "📡"
        case .cyanNebulaAura: "🫧"
        case .goldCosmicAura: "☀️"
        case .purpleMysticAura: "🔮"
        case .rainbowGalaxyAura: "🌈"
        case .stardustTrail: "⭐"
        case .cosmicSparkles: "💖"
        case .galaxyShimmer: "🌌"
        }
    }

    var category: CosmeticCategory {
        switch self {
        case .speedExplorerBadge, .scienceMasterBadge, .flavorPioneerBadge,
             .sensoryWizardBadge, .galaxyLegendBadge:
            .achievementBadge
        case .day7Badge, .week2Badge, .month1Badge, .days100Badge, .year1Badge:
            .milestoneBadge
        case .cosmicBackpack, .sensoryExplorerPack, .flavorQuestSatchel, .scientistBag:
            .backpack
        case .cosmicCompass, .flavorTelescope, .explorerStaff, .discoveryWand, .sensoryScanner:
            .handheld
        case .cyanNebulaAura, .goldCosmicAura, .purpleMysticAura, .rainbowGalaxyAura:
            .aura
        case .stardustTrail, .cosmicSparkles, .galaxyShimmer:
            .particle
        }
    }

    var unlockCondition: CosmeticUnlockCondition {
        switch self {
        case .speedExplorerBadge: .foodsLogged(50)
        case .scienceMasterBadge: .reachPhase(.taste)
        case .flavorPioneerBadge: .foodFamilies(5)
        case .sensoryWizardBadge: .completeAllPhases
        case .galaxyLegendBadge: .planetsUnlocked(8)
        case .day7Badge: .daysLogged(7)
        case .week2Badge: .daysLogged(14)
        case .month1Badge: .daysLogged(30)
        case .days100Badge: .daysLogged(100)
        case .year1Badge: .daysLogged(365)
        case .cosmicBackpack: .level(.level3)
        case .sensoryExplorerPack: .reachPhase(.touch)
        case .flavorQuestSatchel: .reachPhase(.smell)
        case .scientistBag: .reachPhase(.taste)
        case .cosmicCompass: .level(.level2)
        case .flavorTelescope: .level(.level4)
        case .explorerStaff: .planetsUnlocked(5)
        case .discoveryWand: .foodsLogged(75)
        case .sensoryScanner: .planetsUnlocked(8)
        case .cyanNebulaAura: .level(.level2)
        case .goldCosmicAura: .reachPhase(.lick)
        case .purpleMysticAura: .daysLogged(50)
        case .rainbowGalaxyAura: .planetsUnlocked(8)
        case .stardustTrail: .level(.level5)
        case .cosmicSparkles: .daysLogged(100)
        case .galaxyShimmer: .daysLogged(365)
        }
    }

    var unlockDescription: String {
        switch unlockCondition {
        case .level(let lvl): "Reach Level \(lvl.rawValue)"
        case .foodsLogged(let n): "Log \(n) foods"
        case .daysLogged(let n): "\(n) days logging"
        case .reachPhase(let step): "Complete \(step.label) Phase"
        case .completeAllPhases: "Complete all 5 SOS phases"
        case .foodFamilies(let n): "Try \(n) food families"
        case .planetsUnlocked(let n): "Unlock \(n) planets"
        }
    }

    var primaryColorHex: String {
        switch self {
        case .speedExplorerBadge: "00d9ff"
        case .scienceMasterBadge: "667eea"
        case .flavorPioneerBadge: "e91e63"
        case .sensoryWizardBadge: "00d9ff"
        case .galaxyLegendBadge: "d4af37"
        case .day7Badge: "00d9ff"
        case .week2Badge: "667eea"
        case .month1Badge: "e91e63"
        case .days100Badge: "00d9ff"
        case .year1Badge: "d4af37"
        case .cosmicBackpack: "667eea"
        case .sensoryExplorerPack: "00d9ff"
        case .flavorQuestSatchel: "e91e63"
        case .scientistBag: "4CA5FF"
        case .cosmicCompass: "00d9ff"
        case .flavorTelescope: "d4af37"
        case .explorerStaff: "667eea"
        case .discoveryWand: "e91e63"
        case .sensoryScanner: "00d9ff"
        case .cyanNebulaAura: "00d9ff"
        case .goldCosmicAura: "d4af37"
        case .purpleMysticAura: "667eea"
        case .rainbowGalaxyAura: "00d9ff"
        case .stardustTrail: "00d9ff"
        case .cosmicSparkles: "e91e63"
        case .galaxyShimmer: "667eea"
        }
    }

    var secondaryColorHex: String {
        switch self {
        case .speedExplorerBadge: "d4af37"
        case .scienceMasterBadge: "4CA5FF"
        case .flavorPioneerBadge: "d4af37"
        case .sensoryWizardBadge: "e91e63"
        case .galaxyLegendBadge: "667eea"
        case .day7Badge: "d4af37"
        case .week2Badge: "4CA5FF"
        case .month1Badge: "d4af37"
        case .days100Badge: "667eea"
        case .year1Badge: "667eea"
        case .cosmicBackpack: "00d9ff"
        case .sensoryExplorerPack: "d4af37"
        case .flavorQuestSatchel: "667eea"
        case .scientistBag: "d4af37"
        case .cosmicCompass: "d4af37"
        case .flavorTelescope: "e91e63"
        case .explorerStaff: "d4af37"
        case .discoveryWand: "d4af37"
        case .sensoryScanner: "667eea"
        case .cyanNebulaAura: "667eea"
        case .goldCosmicAura: "FFD700"
        case .purpleMysticAura: "764ba2"
        case .rainbowGalaxyAura: "e91e63"
        case .stardustTrail: "d4af37"
        case .cosmicSparkles: "667eea"
        case .galaxyShimmer: "d4af37"
        }
    }
}
