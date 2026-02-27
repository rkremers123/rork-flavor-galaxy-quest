import Foundation

nonisolated struct QuestProgress: Codable, Identifiable, Sendable, Hashable {
    var id: UUID { foodId }
    let foodId: UUID
    var completedSteps: [SensoryStep]
    var lastAttemptDate: Date?
    var starDustEarned: Int
    var skippedSteps: [SensoryStep]
    var stepStartTime: Date?

    init(foodId: UUID) {
        self.foodId = foodId
        self.completedSteps = []
        self.lastAttemptDate = nil
        self.starDustEarned = 0
        self.skippedSteps = []
        self.stepStartTime = nil
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

    var isExpired: Bool {
        guard let lastAttempt = lastAttemptDate else { return false }
        return Date().timeIntervalSince(lastAttempt) > 86400
    }
}

nonisolated struct StarJarConfig: Codable, Sendable {
    var rewardName: String
    var targetStarDust: Int
    var rewardUnlocked: Bool
    var rewardUnlockedDate: Date?

    init(
        rewardName: String = "Mystery Prize",
        targetStarDust: Int = 200,
        rewardUnlocked: Bool = false,
        rewardUnlockedDate: Date? = nil
    ) {
        self.rewardName = rewardName
        self.targetStarDust = targetStarDust
        self.rewardUnlocked = rewardUnlocked
        self.rewardUnlockedDate = rewardUnlockedDate
    }
}

nonisolated struct ChildProfile: Codable, Sendable {
    var name: String
    var age: Int
    var avatarEmoji: String
    var safeFoodIds: [UUID]
    var targetFoodName: String
    var targetFoodId: UUID?
    var totalStarDust: Int
    var questProgress: [UUID: QuestProgress]
    var unlockedGear: [String]
    var starJar: StarJarConfig
    var createdDate: Date

    var currentStreak: Int
    var longestStreak: Int
    var lastActivityDate: Date?
    var streakBrokenDate: Date?
    var lastStreakResumeDate: Date?

    var interactions: [SensoryInteraction]
    var bridgeRecords: [BridgeRecord]
    var excludedAllergens: Set<Allergen>

    var hardestSensoryZone: SensoryStep?

    init(
        name: String = "",
        age: Int = 5,
        avatarEmoji: String = "👨‍🚀",
        safeFoodIds: [UUID] = [],
        targetFoodName: String = "",
        targetFoodId: UUID? = nil,
        totalStarDust: Int = 0,
        questProgress: [UUID: QuestProgress] = [:],
        unlockedGear: [String] = ["basic_helmet"],
        starJar: StarJarConfig = StarJarConfig(),
        createdDate: Date = Date(),
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastActivityDate: Date? = nil,
        streakBrokenDate: Date? = nil,
        lastStreakResumeDate: Date? = nil,
        interactions: [SensoryInteraction] = [],
        bridgeRecords: [BridgeRecord] = [],
        excludedAllergens: Set<Allergen> = [],
        hardestSensoryZone: SensoryStep? = nil
    ) {
        self.name = name
        self.age = age
        self.avatarEmoji = avatarEmoji
        self.safeFoodIds = safeFoodIds
        self.targetFoodName = targetFoodName
        self.targetFoodId = targetFoodId
        self.totalStarDust = totalStarDust
        self.questProgress = questProgress
        self.unlockedGear = unlockedGear
        self.starJar = starJar
        self.createdDate = createdDate
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastActivityDate = lastActivityDate
        self.streakBrokenDate = streakBrokenDate
        self.lastStreakResumeDate = lastStreakResumeDate
        self.interactions = interactions
        self.bridgeRecords = bridgeRecords
        self.excludedAllergens = excludedAllergens
        self.hardestSensoryZone = hardestSensoryZone
    }

    var totalInteractions: Int {
        interactions.count
    }

    var todayInteractionCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return interactions.filter { calendar.startOfDay(for: $0.timestamp) == today }.count
    }

    func comfortLevel(for step: SensoryStep) -> Double {
        let totalAttempts = interactions.filter { $0.sensoryStep == step }.count
        let completedAttempts = interactions.filter { $0.sensoryStep == step && $0.completed }.count
        guard totalAttempts > 0 else { return 0 }
        return Double(completedAttempts) / Double(totalAttempts) * 100
    }

    func interactionsForFood(_ foodId: UUID) -> [SensoryInteraction] {
        interactions.filter { $0.foodId == foodId }
    }

    var activeBridges: [BridgeRecord] {
        bridgeRecords.filter { $0.status == .active }
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
