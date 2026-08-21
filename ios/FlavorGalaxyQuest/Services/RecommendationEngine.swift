import Foundation

enum MatcherContext {
    static var profile: ChildProfileModel?
}

struct RecommendationEngine {

    /// Existing call site stays the same. Uses the stashed child profile when present
    /// so Suggest / Start Quest / parent recs run the repaired matcher.
    static func generateRecommendations(
        sensoryProfile: SensoryProfile,
        allFoods: [FoodItem],
        excludedAllergens: Set<Allergen>,
        excludedFoodIds: Set<UUID> = [],
        maxPerTier: Int = 8
    ) -> [FoodRecommendation] {
        _ = maxPerTier
        if let profile = MatcherContext.profile ?? nil {
            return generateRecommendations(
                profile: profile,
                allFoods: allFoods,
                excludedAllergens: excludedAllergens,
                excludedFoodIds: excludedFoodIds
            )
        }
        let regular = Set(sensoryProfile.successfulFoodIds)
        let picks = BridgeFoodMatcher.generateRecommendations(
            logs: [],
            superSafeFoods: [],
            regularSafeFoods: regular,
            foods: allFoods,
            kidAllergens: excludedAllergens,
            extraExclude: excludedFoodIds
        )
        let byId = Dictionary(uniqueKeysWithValues: allFoods.map { ($0.id, $0) })
        return picks.compactMap { pick in
            guard let food = byId[pick.foodId] else { return nil }
            return mapPick(pick, food: food)
        }
    }

    static func generateRecommendations(
        profile: ChildProfileModel,
        allFoods: [FoodItem],
        excludedAllergens: Set<Allergen>,
        excludedFoodIds: Set<UUID> = [],
        maxPerTier: Int = 8
    ) -> [FoodRecommendation] {
        _ = maxPerTier
        MatcherContext.profile = profile
        let logs = Self.logs(from: profile)
        let safes = Self.safeSets(from: profile)
        let picks = BridgeFoodMatcher.generateRecommendations(
            logs: logs,
            superSafeFoods: safes.superSafe,
            regularSafeFoods: safes.regularSafe,
            foods: allFoods,
            kidAllergens: excludedAllergens,
            extraExclude: excludedFoodIds
        )
        let byId = Dictionary(uniqueKeysWithValues: allFoods.map { ($0.id, $0) })
        return picks.compactMap { pick in
            guard let food = byId[pick.foodId] else { return nil }
            return mapPick(pick, food: food)
        }
    }

    static func logs(from profile: ChildProfileModel) -> [BridgeFoodMatcher.FoodLog] {
        let calendar = Calendar.current
        var buckets: [String: (UUID, Date, [String])] = [:]

        for interaction in profile.interactions where interaction.completed {
            if let quest = profile.questProgressItems.first(where: { $0.foodId == interaction.foodId }),
               quest.isPreCompleted,
               quest.completedSteps.isEmpty {
                continue
            }
            var states: [String] = []
            switch interaction.sensoryStep {
            case .look:
                states.append("looked_at")
            case .touch:
                states.append("touched")
            case .smell:
                states.append("smelled")
            case .lick:
                states.append("licked")
            case .taste:
                if interaction.tasteVerification == .swallowed {
                    states.append("ate")
                } else {
                    states.append("tasted")
                }
            }
            let day = calendar.startOfDay(for: interaction.timestamp)
            let key = "\(interaction.foodId.uuidString)|\(day.timeIntervalSince1970)"
            if var existing = buckets[key] {
                existing.2.append(contentsOf: states)
                if interaction.timestamp > existing.1 { existing.1 = interaction.timestamp }
                buckets[key] = existing
            } else {
                buckets[key] = (interaction.foodId, interaction.timestamp, states)
            }
        }

        return buckets.values.map {
            BridgeFoodMatcher.FoodLog(foodId: $0.0, timestamp: $0.1, exposureStates: $0.2)
        }
    }

    static func safeSets(from profile: ChildProfileModel) -> (superSafe: Set<UUID>, regularSafe: Set<UUID>) {
        var superSafe: Set<UUID> = []
        var regular: Set<UUID> = []
        for id in profile.safeFoodIds {
            if let quest = profile.questProgressItems.first(where: { $0.foodId == id }), quest.isPreCompleted {
                superSafe.insert(id)
            } else if profile.questProgressItems.first(where: { $0.foodId == id }) == nil {
                superSafe.insert(id)
            } else {
                regular.insert(id)
            }
        }
        return (superSafe, regular)
    }

    static func mapPick(_ pick: BridgeFoodMatcher.Pick, food: FoodItem) -> FoodRecommendation {
        let tier: RecommendationTier
        let match: Double
        let bridge: Double
        let confidence: Double
        switch pick.rank {
        case .safe:
            tier = .perfectMatch
            match = max(0, 100 - pick.distance * 20)
            bridge = 90
            confidence = 80
        case .stretch:
            tier = .goodChallenge
            match = max(0, 100 - pick.distance * 18)
            bridge = 70
            confidence = 60
        case .variety:
            tier = .greatMatch
            match = max(0, 100 - pick.distance * 18)
            bridge = 80
            confidence = 70
        }
        return FoodRecommendation(
            food: food,
            score: match,
            tier: tier,
            matchScore: match,
            bridgeScore: bridge,
            confidenceScore: confidence,
            difficultyScore: min(100, pick.distance * 20),
            explanation: pick.explanation,
            matchingAttributes: [pick.rank.rawValue],
            newAttributes: [String(format: "distance %.1f", pick.distance)]
        )
    }
}
