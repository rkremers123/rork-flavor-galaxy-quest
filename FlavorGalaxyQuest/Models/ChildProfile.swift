import SwiftData
import Foundation

@Model
class ChildProfileModel {
    var name: String = ""
    var age: Int = 5
    var avatarEmoji: String = "👨‍🚀"
    var explorerTypeRawValue: String = ExplorerType.nova.rawValue
    var explorerCustomName: String = ""
    var equippedCosmeticValues: [String] = [Cosmetic.explorerHat.rawValue]
    var unlockedCosmeticValues: [String] = [Cosmetic.explorerHat.rawValue]
    var safeFoodIds: [UUID] = []
    var targetFoodName: String = ""
    var targetFoodId: UUID?
    var totalStarDust: Int = 0
    var unlockedGear: [String] = ["basic_helmet"]
    var createdDate: Date = Date()

    var starJarRewardName: String = "Mystery Prize"
    var starJarTargetStarDust: Int = 200
    var starJarRewardUnlocked: Bool = false
    var starJarRewardUnlockedDate: Date?

    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastActivityDate: Date?
    var streakBrokenDate: Date?
    var lastStreakResumeDate: Date?

    var excludedAllergenValues: [String] = []
    var hardestSensoryZoneRawValue: Int?

    @Relationship(deleteRule: .cascade) var questProgressItems: [QuestProgressModel] = []
    @Relationship(deleteRule: .cascade) var interactions: [SensoryInteractionModel] = []
    @Relationship(deleteRule: .cascade) var bridgeRecords: [BridgeRecordModel] = []

    init() {}

    var explorerType: ExplorerType {
        get { ExplorerType(rawValue: explorerTypeRawValue) ?? .nova }
        set { explorerTypeRawValue = newValue.rawValue }
    }

    var currentLevel: ExplorerLevel {
        ExplorerLevel.level(for: totalStarDust)
    }

    var levelProgress: Double {
        ExplorerLevel.progressToNext(points: totalStarDust)
    }

    var currentJourneyPlanet: JourneyPlanet {
        let explored = questProgressItems.filter { !$0.completedStepValues.isEmpty }.count
        return JourneyPlanet.current(for: explored)
    }

    var journeyProgress: Double {
        let explored = questProgressItems.filter { !$0.completedStepValues.isEmpty }.count
        return JourneyPlanet.progressToNext(foodsExplored: explored)
    }

    var unlockedCosmetics: Set<Cosmetic> {
        get { Set(unlockedCosmeticValues.compactMap { Cosmetic(rawValue: $0) }) }
        set { unlockedCosmeticValues = newValue.map(\.rawValue) }
    }

    var equippedCosmetics: Set<Cosmetic> {
        get { Set(equippedCosmeticValues.compactMap { Cosmetic(rawValue: $0) }) }
        set { equippedCosmeticValues = newValue.map(\.rawValue) }
    }

    var explorerDisplayName: String {
        explorerCustomName.isEmpty ? explorerType.defaultName : explorerCustomName
    }

    var excludedAllergens: Set<Allergen> {
        get { Set(excludedAllergenValues.compactMap { Allergen(rawValue: $0) }) }
        set { excludedAllergenValues = newValue.map(\.rawValue) }
    }

    var hardestSensoryZone: SensoryStep? {
        get { hardestSensoryZoneRawValue.flatMap { SensoryStep(rawValue: $0) } }
        set { hardestSensoryZoneRawValue = newValue?.rawValue }
    }

    var totalInteractions: Int { interactions.count }

    var todayInteractionCount: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return interactions.filter { calendar.startOfDay(for: $0.timestamp) == today }.count
    }

    func comfortLevel(for step: SensoryStep) -> Double {
        let stepRaw = step.rawValue
        let totalAttempts = interactions.filter { $0.sensoryStepRawValue == stepRaw }.count
        let completedAttempts = interactions.filter { $0.sensoryStepRawValue == stepRaw && $0.completed }.count
        guard totalAttempts > 0 else { return 0 }
        return Double(completedAttempts) / Double(totalAttempts) * 100
    }

    func interactionsForFood(_ foodId: UUID) -> [SensoryInteractionModel] {
        interactions.filter { $0.foodId == foodId }
    }

    var activeBridges: [BridgeRecordModel] {
        bridgeRecords.filter { $0.statusRawValue == BridgeStatus.active.rawValue }
    }
}
