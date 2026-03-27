import Foundation

nonisolated struct SensoryAggregate: Sendable {
    let attribute: String
    let count: Int
    let percentage: Double
    let isInSuccessZone: Bool
}

nonisolated struct SensoryProfile: Sendable {
    let childName: String
    let daysActive: Int
    let totalFoodsConsumed: Int
    let successfulFoodIds: [UUID]

    let textureAggregates: [FoodTexture: SensoryAggregate]
    let flavorAggregates: [FoodFlavor: SensoryAggregate]
    let temperatureAggregates: [FoodTemperature: SensoryAggregate]

    let successZoneTextures: [FoodTexture]
    let successZoneFlavors: [FoodFlavor]
    let successZoneTemperatures: [FoodTemperature]

    let avoidanceZoneTextures: [FoodTexture]
    let avoidanceZoneFlavors: [FoodFlavor]

    let archetype: String
    let lastUpdated: Date

    var confidenceScore: Double {
        guard totalFoodsConsumed > 0 else { return 0 }
        return min(Double(totalFoodsConsumed) / 10.0, 1.0)
    }

    static let empty = SensoryProfile(
        childName: "",
        daysActive: 0,
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

nonisolated enum RecommendationTier: String, Sendable, CaseIterable {
    case perfectMatch
    case greatMatch
    case goodChallenge
    case expertChallenge

    var label: String {
        switch self {
        case .perfectMatch: "Perfect Match"
        case .greatMatch: "Great Match"
        case .goodChallenge: "Good Challenge"
        case .expertChallenge: "Expert Challenge"
        }
    }

    var scoreRange: ClosedRange<Double> {
        switch self {
        case .perfectMatch: 85...100
        case .greatMatch: 70...84.99
        case .goodChallenge: 50...69.99
        case .expertChallenge: 0...49.99
        }
    }

    var icon: String {
        switch self {
        case .perfectMatch: "star.fill"
        case .greatMatch: "hand.thumbsup.fill"
        case .goodChallenge: "flame.fill"
        case .expertChallenge: "mountain.2.fill"
        }
    }
}

nonisolated struct FoodRecommendation: Identifiable, Sendable {
    let id: UUID
    let food: FoodItem
    let score: Double
    let tier: RecommendationTier
    let matchScore: Double
    let bridgeScore: Double
    let confidenceScore: Double
    let difficultyScore: Double
    let explanation: String
    let matchingAttributes: [String]
    let newAttributes: [String]

    init(
        food: FoodItem,
        score: Double,
        tier: RecommendationTier,
        matchScore: Double,
        bridgeScore: Double,
        confidenceScore: Double,
        difficultyScore: Double,
        explanation: String,
        matchingAttributes: [String],
        newAttributes: [String]
    ) {
        self.id = UUID()
        self.food = food
        self.score = score
        self.tier = tier
        self.matchScore = matchScore
        self.bridgeScore = bridgeScore
        self.confidenceScore = confidenceScore
        self.difficultyScore = difficultyScore
        self.explanation = explanation
        self.matchingAttributes = matchingAttributes
        self.newAttributes = newAttributes
    }
}
