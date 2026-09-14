import Foundation

struct FoodChainingEngine {

    static let textureScale: [FoodTexture] = [.crunchy, .soft, .mushy, .liquid, .mixedTexture]

    static func textureRank(_ texture: FoodTexture) -> Int {
        textureScale.firstIndex(of: texture) ?? 0
    }

    static func areTexturesAdjacent(_ a: FoodTexture, _ b: FoodTexture) -> Bool {
        abs(textureRank(a) - textureRank(b)) <= 1
    }

    static func sensoryDistance(from a: FoodItem, to b: FoodItem) -> Int {
        var distance = 0
        if a.texture != b.texture { distance += 1 }
        if a.flavor != b.flavor { distance += 1 }
        if a.temperature != b.temperature { distance += 1 }
        if a.aroma != b.aroma { distance += 1 }
        return distance
    }

    static func attributeDifferences(from a: FoodItem, to b: FoodItem) -> (texture: Bool, flavor: Bool, temperature: Bool, aroma: Bool) {
        (
            texture: a.texture != b.texture,
            flavor: a.flavor != b.flavor,
            temperature: a.temperature != b.temperature,
            aroma: a.aroma != b.aroma
        )
    }

    static func classifyBridge(from safeFood: FoodItem, to candidate: FoodItem, target: FoodItem) -> BridgeType {
        let diffs = attributeDifferences(from: safeFood, to: candidate)
        let diffCount = [diffs.texture, diffs.flavor, diffs.temperature, diffs.aroma].filter { $0 }.count

        if diffCount == 0 && safeFood.category == candidate.category {
            return .brand
        }

        if !diffs.texture && !diffs.flavor && !diffs.aroma {
            return .visual
        }

        if diffs.texture && !diffs.flavor && !diffs.temperature && !diffs.aroma {
            guard areTexturesAdjacent(safeFood.texture, candidate.texture) else { return .flavor }
            return .texture
        }

        return .flavor
    }

    static func generateReason(
        bridgeType: BridgeType,
        safeFood: FoodItem,
        bridgeFood: FoodItem,
        targetFood: FoodItem
    ) -> String {
        switch bridgeType {
        case .brand:
            return "Same \(safeFood.texture.label.lowercased()) texture as \(safeFood.name), great first step toward \(targetFood.name)"
        case .visual:
            return "Shares \(safeFood.texture.label.lowercased()) texture with \(safeFood.name) but looks different"
        case .texture:
            return "\(bridgeFood.texture.label) texture is one step closer to \(targetFood.name)'s \(targetFood.texture.label.lowercased()) texture"
        case .flavor:
            return "Same \(bridgeFood.texture.label.lowercased()) texture as progress foods, introducing \(bridgeFood.flavor.label.lowercased()) flavor"
        }
    }

    static func suggestBridges(
        safeFoods: [FoodItem],
        targetFood: FoodItem,
        allFoods: [FoodItem],
        excludedAllergens: Set<Allergen>,
        excludedFoodIds: Set<UUID> = [],
        bridgeHistory: [BridgeRecordModel],
        maxSuggestions: Int = 5
    ) -> [BridgeSuggestion] {
        _ = bridgeHistory
        if !targetFood.allergens.isDisjoint(with: excludedAllergens) || excludedFoodIds.contains(targetFood.id) {
            return []
        }

        var extra = excludedFoodIds
        extra.insert(targetFood.id)

        let logs: [BridgeFoodMatcher.FoodLog]
        let superSafe: Set<UUID>
        let regularSafe: Set<UUID>
        if let profile = MatcherContext.profile {
            logs = RecommendationEngine.logs(from: profile)
            let sets = RecommendationEngine.safeSets(from: profile)
            superSafe = sets.superSafe
            regularSafe = sets.regularSafe
        } else {
            logs = []
            superSafe = Set(safeFoods.map(\.id))
            regularSafe = []
        }

        let picks = BridgeFoodMatcher.generateRecommendations(
            logs: logs,
            superSafeFoods: superSafe,
            regularSafeFoods: regularSafe,
            foods: allFoods,
            kidAllergens: excludedAllergens,
            extraExclude: extra
        )
        let mapped = suggestionsFromMatcherPicks(
            picks: picks,
            foods: allFoods,
            safeFoods: safeFoods,
            targetFood: targetFood
        )
        return Array(mapped.prefix(maxSuggestions))
    }

    static func suggestNextBridge(
        safeFoods: [FoodItem],
        targetFood: FoodItem,
        allFoods: [FoodItem],
        excludedAllergens: Set<Allergen>,
        excludedFoodIds: Set<UUID> = [],
        bridgeHistory: [BridgeRecordModel]
    ) -> BridgeSuggestion? {
        suggestBridges(
            safeFoods: safeFoods,
            targetFood: targetFood,
            allFoods: allFoods,
            excludedAllergens: excludedAllergens,
            excludedFoodIds: excludedFoodIds,
            bridgeHistory: bridgeHistory,
            maxSuggestions: 1
        ).first
    }

    static func suggestionsFromMatcherPicks(
        picks: [BridgeFoodMatcher.Pick],
        foods: [FoodItem],
        safeFoods: [FoodItem],
        targetFood: FoodItem?
    ) -> [BridgeSuggestion] {
        let byId = Dictionary(uniqueKeysWithValues: foods.map { ($0.id, $0) })
        let fromSafe = safeFoods.first
        return picks.compactMap { pick in
            guard let food = byId[pick.foodId] else { return nil }
            let source = fromSafe ?? food
            let target = targetFood ?? food
            let bridgeType: BridgeType
            switch pick.rank {
            case .safe: bridgeType = .texture
            case .stretch: bridgeType = .flavor
            case .variety: bridgeType = .visual
            }
            return BridgeSuggestion(
                bridgeFood: food,
                fromSafeFood: source,
                targetFood: target,
                bridgeType: bridgeType,
                reason: pick.explanation,
                sensoryDistance: Int(pick.distance.rounded())
            )
        }
    }
}
