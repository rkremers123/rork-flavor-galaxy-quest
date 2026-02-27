import Foundation

nonisolated struct QuestProgress: Codable, Identifiable, Sendable, Hashable {
    var id: UUID { foodId }
    let foodId: UUID
    var completedSteps: [SensoryStep]
    var lastAttemptDate: Date?
    var starDustEarned: Int
    var skippedSteps: [SensoryStep]

    init(foodId: UUID) {
        self.foodId = foodId
        self.completedSteps = []
        self.lastAttemptDate = nil
        self.starDustEarned = 0
        self.skippedSteps = []
    }

    var currentStep: SensoryStep? {
        let allSteps = SensoryStep.allCases
        return allSteps.first { !completedSteps.contains($0) && !skippedSteps.contains($0) }
    }

    var progressFraction: Double {
        Double(completedSteps.count) / Double(SensoryStep.allCases.count)
    }

    var isComplete: Bool {
        completedSteps.count == SensoryStep.allCases.count
    }
}

nonisolated struct StarJarConfig: Codable, Sendable {
    var rewardName: String
    var targetStarDust: Int

    init(rewardName: String = "Mystery Prize", targetStarDust: Int = 200) {
        self.rewardName = rewardName
        self.targetStarDust = targetStarDust
    }
}

nonisolated struct ChildProfile: Codable, Sendable {
    var name: String
    var age: Int
    var avatarEmoji: String
    var safeFoodIds: [UUID]
    var targetFoodName: String
    var totalStarDust: Int
    var questProgress: [UUID: QuestProgress]
    var unlockedGear: [String]
    var starJar: StarJarConfig
    var createdDate: Date

    init(
        name: String = "",
        age: Int = 5,
        avatarEmoji: String = "👨‍🚀",
        safeFoodIds: [UUID] = [],
        targetFoodName: String = "",
        totalStarDust: Int = 0,
        questProgress: [UUID: QuestProgress] = [:],
        unlockedGear: [String] = ["basic_helmet"],
        starJar: StarJarConfig = StarJarConfig(),
        createdDate: Date = Date()
    ) {
        self.name = name
        self.age = age
        self.avatarEmoji = avatarEmoji
        self.safeFoodIds = safeFoodIds
        self.targetFoodName = targetFoodName
        self.totalStarDust = totalStarDust
        self.questProgress = questProgress
        self.unlockedGear = unlockedGear
        self.starJar = starJar
        self.createdDate = createdDate
    }
}

nonisolated struct SensoryComfortLevel: Codable, Sendable {
    var look: Int
    var touch: Int
    var smell: Int
    var lick: Int
    var taste: Int

    init(look: Int = 0, touch: Int = 0, smell: Int = 0, lick: Int = 0, taste: Int = 0) {
        self.look = look
        self.touch = touch
        self.smell = smell
        self.lick = lick
        self.taste = taste
    }

    func value(for step: SensoryStep) -> Int {
        switch step {
        case .look: look
        case .touch: touch
        case .smell: smell
        case .lick: lick
        case .taste: taste
        }
    }
}
