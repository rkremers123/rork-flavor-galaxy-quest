import Foundation

struct RecommendationEngine {

    private static let matchWeight: Double = 0.35
    private static let bridgeWeight: Double = 0.30
    private static let confidenceWeight: Double = 0.20
    private static let difficultyWeight: Double = 0.15

    static func generateRecommendations(
        sensoryProfile: SensoryProfile,
        allFoods: [FoodItem],
        excludedAllergens: Set<Allergen>,
        excludedFoodIds: Set<UUID> = [],
        maxPerTier: Int = 8
    ) -> [FoodRecommendation] {
        guard sensoryProfile.totalFoodsConsumed > 0 else { return [] }

        let triedFoodIds = Set(sensoryProfile.successfulFoodIds)

        let candidates = allFoods.filter { food in
            !triedFoodIds.contains(food.id) &&
            !excludedFoodIds.contains(food.id) &&
            food.allergens.isDisjoint(with: excludedAllergens)
        }

        var recommendations: [FoodRecommendation] = []

        for food in candidates {
            let avoidanceCount = countAvoidanceAttributes(food: food, profile: sensoryProfile)
            guard avoidanceCount < 3 else { continue }

            let matchScore = calculateMatchScore(food: food, profile: sensoryProfile)
            let bridgeScore = calculateBridgeScore(food: food, profile: sensoryProfile)
            let confidenceScore = calculateConfidenceScore(food: food, profile: sensoryProfile)
            let difficultyScore = calculateDifficultyScore(food: food, profile: sensoryProfile)

            let compositeScore = matchWeight * matchScore +
                bridgeWeight * bridgeScore +
                confidenceWeight * confidenceScore +
                difficultyWeight * (100.0 - difficultyScore)

            let tier = tierForScore(compositeScore)
            let matching = matchingAttributes(food: food, profile: sensoryProfile)
            let newAttrs = newAttributes(food: food, profile: sensoryProfile)
            let explanation = generateExplanation(
                food: food,
                tier: tier,
                profile: sensoryProfile,
                matching: matching,
                newAttrs: newAttrs
            )

            recommendations.append(FoodRecommendation(
                food: food,
                score: compositeScore,
                tier: tier,
                matchScore: matchScore,
                bridgeScore: bridgeScore,
                confidenceScore: confidenceScore,
                difficultyScore: difficultyScore,
                explanation: explanation,
                matchingAttributes: matching,
                newAttributes: newAttrs
            ))
        }

        recommendations.sort { $0.score > $1.score }
        return recommendations
    }

    private static func calculateMatchScore(food: FoodItem, profile: SensoryProfile) -> Double {
        var matchCount = 0
        if profile.successZoneTextures.contains(food.texture) { matchCount += 1 }
        if profile.successZoneFlavors.contains(food.flavor) { matchCount += 1 }
        if profile.successZoneTemperatures.contains(food.temperature) { matchCount += 1 }

        switch matchCount {
        case 3: return 100
        case 2: return 80
        case 1: return 50
        default:
            let hasAvoidance = profile.avoidanceZoneTextures.contains(food.texture) ||
                profile.avoidanceZoneFlavors.contains(food.flavor)
            return hasAvoidance ? 0 : 20
        }
    }

    private static func calculateBridgeScore(food: FoodItem, profile: SensoryProfile) -> Double {
        var score: Double = 0
        let allSuccessTextures = Set(profile.successZoneTextures)
        let allSuccessFlavors = Set(profile.successZoneFlavors)
        let allSuccessTemps = Set(profile.successZoneTemperatures)

        if !allSuccessTextures.contains(food.texture) && !profile.avoidanceZoneTextures.contains(food.texture) {
            score += 50
        }
        if !allSuccessFlavors.contains(food.flavor) && !profile.avoidanceZoneFlavors.contains(food.flavor) {
            score += 50
        }
        if !allSuccessTemps.contains(food.temperature) {
            score += 25
        }

        if profile.avoidanceZoneTextures.contains(food.texture) { score += 30 }
        if profile.avoidanceZoneFlavors.contains(food.flavor) { score += 30 }

        return min(score, 100)
    }

    private static func calculateConfidenceScore(food: FoodItem, profile: SensoryProfile) -> Double {
        let total = max(profile.totalFoodsConsumed, 1)
        var scores: [Double] = []

        if let agg = profile.textureAggregates[food.texture], agg.isInSuccessZone {
            scores.append(Double(agg.count) / Double(total) * 100.0)
        }
        if let agg = profile.flavorAggregates[food.flavor], agg.isInSuccessZone {
            scores.append(Double(agg.count) / Double(total) * 100.0)
        }
        if let agg = profile.temperatureAggregates[food.temperature], agg.isInSuccessZone {
            scores.append(Double(agg.count) / Double(total) * 100.0)
        }

        guard !scores.isEmpty else { return 10 }
        return min(scores.reduce(0, +) / Double(scores.count), 100)
    }

    private static func calculateDifficultyScore(food: FoodItem, profile: SensoryProfile) -> Double {
        var newCount = 0
        if !profile.successZoneTextures.contains(food.texture) { newCount += 1 }
        if !profile.successZoneFlavors.contains(food.flavor) { newCount += 1 }
        if !profile.successZoneTemperatures.contains(food.temperature) { newCount += 1 }

        var base: Double
        switch newCount {
        case 0: base = 10
        case 1: base = 50
        default: base = 80
        }

        if profile.avoidanceZoneTextures.contains(food.texture) { base += 20 }
        if profile.avoidanceZoneFlavors.contains(food.flavor) { base += 20 }

        return min(base, 100)
    }

    private static func countAvoidanceAttributes(food: FoodItem, profile: SensoryProfile) -> Int {
        var count = 0
        if profile.avoidanceZoneTextures.contains(food.texture) { count += 1 }
        if profile.avoidanceZoneFlavors.contains(food.flavor) { count += 1 }
        return count
    }

    private static func tierForScore(_ score: Double) -> RecommendationTier {
        if score >= 85 { return .perfectMatch }
        if score >= 70 { return .greatMatch }
        if score >= 50 { return .goodChallenge }
        return .expertChallenge
    }

    private static func matchingAttributes(food: FoodItem, profile: SensoryProfile) -> [String] {
        var attrs: [String] = []
        if profile.successZoneTextures.contains(food.texture) { attrs.append(food.texture.label) }
        if profile.successZoneFlavors.contains(food.flavor) { attrs.append(food.flavor.label) }
        if profile.successZoneTemperatures.contains(food.temperature) { attrs.append(food.temperature.label) }
        return attrs
    }

    private static func newAttributes(food: FoodItem, profile: SensoryProfile) -> [String] {
        var attrs: [String] = []
        if !profile.successZoneTextures.contains(food.texture) { attrs.append(food.texture.label) }
        if !profile.successZoneFlavors.contains(food.flavor) { attrs.append(food.flavor.label) }
        if !profile.successZoneTemperatures.contains(food.temperature) { attrs.append(food.temperature.label) }
        return attrs
    }

    private static func generateExplanation(
        food: FoodItem,
        tier: RecommendationTier,
        profile: SensoryProfile,
        matching: [String],
        newAttrs: [String]
    ) -> String {
        let matchList = matching.joined(separator: ", ")
        let newList = newAttrs.joined(separator: ", ")

        switch tier {
        case .perfectMatch:
            return "\(food.name) matches \(profile.childName)'s comfort zone perfectly: \(matchList). High confidence recommendation!"
        case .greatMatch:
            if !newList.isEmpty {
                return "\(food.name) shares familiar attributes (\(matchList)) but introduces \(newList). A great progression step."
            }
            return "\(food.name) aligns well with \(profile.childName)'s preferences (\(matchList))."
        case .goodChallenge:
            if !newList.isEmpty {
                return "\(food.name) introduces \(newList), which is new territory. But \(matchList.isEmpty ? "the category is familiar" : matchList + " is familiar"), making it a gentle bridge."
            }
            return "\(food.name) is a moderate challenge that builds on existing comfort."
        case .expertChallenge:
            if !matchList.isEmpty {
                return "\(food.name) is quite different from \(profile.childName)'s comfort zone, but contains \(matchList). Take time with this one."
            }
            return "\(food.name) is a stretch goal. Consider building more bridges before attempting."
        }
    }
}
