import Foundation

struct SensoryProfileCalculator {

    static let successZoneThreshold = 3

    static func calculateProfile(
        profile: ChildProfileModel,
        allFoods: [FoodItem]
    ) -> SensoryProfile {
        MatcherContext.profile = profile
        let calendar = Calendar.current
        let daysActive = max((calendar.dateComponents([.day], from: profile.createdDate, to: Date()).day ?? 0) + 1, 1)

        let consumedFoodIds = profile.questProgressItems
            .filter { quest in
                isActuallyConsumed(quest, interactions: profile.interactions)
            }
            .map(\.foodId)

        let consumedFoods = consumedFoodIds.compactMap { id in
            allFoods.first { $0.id == id }
        }

        let totalConsumed = consumedFoods.count
        guard totalConsumed > 0 else {
            return SensoryProfile(
                childName: profile.explorerDisplayName,
                daysActive: daysActive,
                totalFoodsConsumed: 0,
                successfulFoodIds: [],
                textureAggregates: [:],
                flavorAggregates: [:],
                temperatureAggregates: [:],
                successZoneTextures: [],
                successZoneFlavors: [],
                successZoneTemperatures: [],
                avoidanceZoneTextures: [],
                avoidanceZoneFlavors: [],
                archetype: "New Explorer",
                lastUpdated: Date()
            )
        }

        var textureCounts: [FoodTexture: Int] = [:]
        var flavorCounts: [FoodFlavor: Int] = [:]
        var tempCounts: [FoodTemperature: Int] = [:]

        for food in consumedFoods {
            textureCounts[food.texture, default: 0] += 1
            flavorCounts[food.flavor, default: 0] += 1
            tempCounts[food.temperature, default: 0] += 1
        }

        let textureAggregates = buildAggregates(textureCounts, total: totalConsumed)
        let flavorAggregates = buildAggregates(flavorCounts, total: totalConsumed)
        let tempAggregates = buildAggregates(tempCounts, total: totalConsumed)

        let successTextures = textureCounts.filter { $0.value >= successZoneThreshold }.map(\.key)
        let successFlavors = flavorCounts.filter { $0.value >= successZoneThreshold }.map(\.key)
        let successTemps = tempCounts.filter { $0.value >= successZoneThreshold }.map(\.key)

        let refusedFoodIds = profile.questProgressItems
            .filter { quest in
                quest.completedStepValues.isEmpty && quest.skippedStepValues.count >= 2
            }
            .map(\.foodId)

        let refusedFoods = refusedFoodIds.compactMap { id in
            allFoods.first { $0.id == id }
        }

        var refusedTextureCounts: [FoodTexture: Int] = [:]
        var refusedFlavorCounts: [FoodFlavor: Int] = [:]
        for food in refusedFoods {
            refusedTextureCounts[food.texture, default: 0] += 1
            refusedFlavorCounts[food.flavor, default: 0] += 1
        }

        let avoidTextures = refusedTextureCounts.filter { $0.value >= 2 }.map(\.key)
        let avoidFlavors = refusedFlavorCounts.filter { $0.value >= 2 }.map(\.key)

        let archetype = generateArchetype(
            topTexture: textureCounts.max(by: { $0.value < $1.value })?.key,
            topFlavor: flavorCounts.max(by: { $0.value < $1.value })?.key
        )

        return SensoryProfile(
            childName: profile.explorerDisplayName,
            daysActive: daysActive,
            totalFoodsConsumed: totalConsumed,
            successfulFoodIds: consumedFoodIds,
            textureAggregates: textureAggregates,
            flavorAggregates: flavorAggregates,
            temperatureAggregates: tempAggregates,
            successZoneTextures: successTextures,
            successZoneFlavors: successFlavors,
            successZoneTemperatures: successTemps,
            avoidanceZoneTextures: avoidTextures,
            avoidanceZoneFlavors: avoidFlavors,
            archetype: archetype,
            lastUpdated: Date()
        )
    }


    /// Eaten only when taste is completed AND parent verified swallowed.
    /// Lick alone never counts. Onboarding safes (isPreCompleted) never count.
    private static func isActuallyConsumed(
        _ quest: QuestProgressModel,
        interactions: [SensoryInteractionModel]
    ) -> Bool {
        guard !quest.isPreCompleted else { return false }
        guard quest.completedSteps.contains(.taste) else { return false }
        return interactions.contains { interaction in
            interaction.foodId == quest.foodId
                && interaction.sensoryStep == .taste
                && interaction.completed
                && interaction.tasteVerification == .swallowed
        }
    }

    private static func buildAggregates<T: Hashable>(_ counts: [T: Int], total: Int) -> [T: SensoryAggregate] {
        var result: [T: SensoryAggregate] = [:]
        for (key, count) in counts {
            let pct = Double(count) / Double(total) * 100.0
            result[key] = SensoryAggregate(
                attribute: "\(key)",
                count: count,
                percentage: pct,
                isInSuccessZone: count >= successZoneThreshold
            )
        }
        return result
    }

    private static func generateArchetype(topTexture: FoodTexture?, topFlavor: FoodFlavor?) -> String {
        guard let texture = topTexture, let flavor = topFlavor else {
            return "New Explorer"
        }
        return "\(texture.label) \(flavor.label) Adventurer"
    }

    static func generateInsights(profile: SensoryProfile) -> [String] {
        var insights: [String] = []

        if let topTexture = profile.textureAggregates.max(by: { $0.value.count < $1.value.count }) {
            insights.append("\(profile.childName) loves \(topTexture.key.label.lowercased()) foods. Try adding more variety in this texture category.")
        }

        if !profile.avoidanceZoneTextures.isEmpty {
            let names = profile.avoidanceZoneTextures.map(\.label).joined(separator: " and ")
            insights.append("\(names) textures are challenging right now. Consider bridging through familiar flavors first.")
        }

        if !profile.avoidanceZoneFlavors.isEmpty {
            let names = profile.avoidanceZoneFlavors.map(\.label).joined(separator: " and ")
            insights.append("\(names) flavors need more time. Try pairing with preferred textures to ease the transition.")
        }

        if profile.successZoneTextures.count >= 3 {
            insights.append("Great progress! \(profile.childName) is comfortable with \(profile.successZoneTextures.count) texture types.")
        }

        if let topTemp = profile.temperatureAggregates.max(by: { $0.value.count < $1.value.count }) {
            insights.append("\(profile.childName) prefers \(topTemp.key.label.lowercased()) foods. Use this as an anchor when introducing new flavors.")
        }

        return insights
    }
}
