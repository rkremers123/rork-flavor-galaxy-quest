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
        bridgeHistory: [BridgeRecord],
        maxSuggestions: Int = 5
    ) -> [BridgeSuggestion] {
        let failedFoodIds = Set(bridgeHistory.filter { $0.status == .failed }.map(\.bridgeFoodId))
        let activeBridgeFoodIds = Set(bridgeHistory.filter { $0.status == .active }.map(\.bridgeFoodId))

        let filteredFoods = allFoods.filter { candidate in
            candidate.id != targetFood.id &&
            !failedFoodIds.contains(candidate.id) &&
            !activeBridgeFoodIds.contains(candidate.id) &&
            candidate.allergens.isDisjoint(with: excludedAllergens)
        }

        let calendar = Calendar.current
        let latestActiveBridge = bridgeHistory
            .filter { $0.status == .active || $0.status == .completed }
            .sorted { $0.startDate > $1.startDate }
            .first
        let daysAtCurrentBridge: Int = {
            guard let bridge = latestActiveBridge else { return 0 }
            return max(calendar.dateComponents([.day], from: bridge.startDate, to: Date()).day ?? 0, 0)
        }()

        var suggestions: [BridgeSuggestion] = []

        for safeFood in safeFoods {
            guard safeFood.id != targetFood.id else { continue }

            let currentDist = sensoryDistance(from: safeFood, to: targetFood)

            for candidate in filteredFoods {
                guard candidate.id != safeFood.id else { continue }

                let distFromSafe = sensoryDistance(from: safeFood, to: candidate)
                let distToTarget = sensoryDistance(from: candidate, to: targetFood)

                guard distToTarget < currentDist else { continue }

                let diffs = attributeDifferences(from: safeFood, to: candidate)
                let diffCount = [diffs.texture, diffs.flavor, diffs.temperature, diffs.aroma].filter { $0 }.count

                guard diffCount <= 1 else { continue }

                if diffs.texture && !areTexturesAdjacent(safeFood.texture, candidate.texture) {
                    continue
                }

                let bridgeType = classifyBridge(from: safeFood, to: candidate, target: targetFood)

                guard daysAtCurrentBridge >= bridgeType.exposureDaysNeeded else { continue }

                let reason = generateReason(
                    bridgeType: bridgeType,
                    safeFood: safeFood,
                    bridgeFood: candidate,
                    targetFood: targetFood
                )

                suggestions.append(BridgeSuggestion(
                    bridgeFood: candidate,
                    fromSafeFood: safeFood,
                    targetFood: targetFood,
                    bridgeType: bridgeType,
                    reason: reason,
                    sensoryDistance: distToTarget
                ))
            }
        }

        suggestions.sort { a, b in
            if a.bridgeType.priority != b.bridgeType.priority {
                return a.bridgeType.priority < b.bridgeType.priority
            }
            return a.sensoryDistance < b.sensoryDistance
        }

        var seen = Set<UUID>()
        var unique: [BridgeSuggestion] = []
        for suggestion in suggestions {
            if seen.insert(suggestion.bridgeFood.id).inserted {
                unique.append(suggestion)
            }
        }

        return Array(unique.prefix(maxSuggestions))
    }

    static func suggestNextBridge(
        safeFoods: [FoodItem],
        targetFood: FoodItem,
        allFoods: [FoodItem],
        excludedAllergens: Set<Allergen>,
        bridgeHistory: [BridgeRecord]
    ) -> BridgeSuggestion? {
        suggestBridges(
            safeFoods: safeFoods,
            targetFood: targetFood,
            allFoods: allFoods,
            excludedAllergens: excludedAllergens,
            bridgeHistory: bridgeHistory,
            maxSuggestions: 1
        ).first
    }
}
