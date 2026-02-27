import SwiftUI
import SwiftData

enum AppMode {
    case onboarding
    case explorer
    case parentDashboard
}

@Observable
@MainActor
class AppViewModel {
    var mode: AppMode = .onboarding
    var profile: ChildProfileModel
    var showParentGate: Bool = false
    var isTransitioning: Bool = false
    var bridgeSuggestions: [BridgeSuggestion] = []
    var showRewardUnlocked: Bool = false
    var showLevelUp: Bool = false
    var newLevelReached: ExplorerLevel?
    var pendingVerification: PendingVerification?
    var customFoodItems: [FoodItem] = []

    struct PendingVerification {
        let foodId: UUID
        let step: SensoryStep
    }

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        let descriptor = FetchDescriptor<ChildProfileModel>()
        if let existing = try? modelContext.fetch(descriptor).first {
            self.profile = existing
        } else {
            let newProfile = ChildProfileModel()
            modelContext.insert(newProfile)
            self.profile = newProfile
        }

        loadCustomFoods()

        if PersistenceService.hasOnboarded {
            mode = .explorer
            StreakService.updateStreak(profile: profile)
            refreshBridgeSuggestions()
        }
    }

    func completeOnboarding() {
        PersistenceService.hasOnboarded = true
        resolveTargetFoodId()
        refreshBridgeSuggestions()
        saveProfile()
        withAnimation(.spring(duration: 0.6)) {
            mode = .explorer
        }
    }

    func switchToParentMode() {
        withAnimation(.spring(duration: 0.5)) {
            mode = .parentDashboard
        }
    }

    func switchToExplorerMode() {
        isTransitioning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(duration: 0.5)) {
                self.mode = .explorer
                self.isTransitioning = false
            }
        }
    }

    func completeStep(_ step: SensoryStep, for foodId: UUID) {
        let progress = getOrCreateQuestProgress(for: foodId)

        if step.isHighStakes {
            pendingVerification = PendingVerification(foodId: foodId, step: step)
        }

        if !progress.completedSteps.contains(step) {
            var steps = progress.completedSteps
            steps.append(step)
            progress.completedSteps = steps
            progress.starDustEarned += step.starDustReward
            profile.totalStarDust += step.starDustReward

            let previousLevel = profile.currentLevel
            checkStarJarReward()
            checkGearUnlocks()
            checkCosmeticUnlocks()
            checkLevelUp(previousLevel: previousLevel)
        }

        progress.lastAttemptDate = Date()
        progress.stepStartTime = nil

        let interaction = SensoryInteractionModel(
            foodId: foodId,
            sensoryStep: step,
            completed: true,
            parentVerified: !step.isHighStakes
        )
        modelContext.insert(interaction)
        profile.interactions.append(interaction)

        StreakService.recordDailyAction(profile: profile)
        updateBridgeExposure(foodId: foodId)
        saveProfile()
    }

    func verifyTasteStep(foodId: UUID, verification: TasteVerification) {
        if let interaction = profile.interactions
            .sorted(by: { $0.timestamp > $1.timestamp })
            .first(where: { $0.foodId == foodId && ($0.sensoryStep == .taste || $0.sensoryStep == .lick) }) {
            interaction.parentVerified = true
            interaction.tasteVerification = verification
        }
        pendingVerification = nil
        saveProfile()
    }

    func skipStep(_ step: SensoryStep, for foodId: UUID) {
        let progress = getOrCreateQuestProgress(for: foodId)
        if !progress.skippedSteps.contains(step) {
            var steps = progress.skippedSteps
            steps.append(step)
            progress.skippedSteps = steps
        }
        progress.lastAttemptDate = Date()

        let interaction = SensoryInteractionModel(
            foodId: foodId,
            sensoryStep: step,
            completed: false
        )
        modelContext.insert(interaction)
        profile.interactions.append(interaction)

        saveProfile()
    }

    func startStep(for foodId: UUID) {
        let progress = getOrCreateQuestProgress(for: foodId)
        progress.stepStartTime = Date()
    }

    func questProgress(for foodId: UUID) -> QuestProgressModel? {
        profile.questProgressItems.first { $0.foodId == foodId }
    }

    var exploredFoodsCount: Int {
        profile.questProgressItems.filter { !$0.completedStepValues.isEmpty }.count
    }

    var completedQuestsCount: Int {
        profile.questProgressItems.filter { $0.isComplete }.count
    }

    var starJarProgress: Double {
        guard profile.starJarTargetStarDust > 0 else { return 0 }
        return min(Double(profile.totalStarDust) / Double(profile.starJarTargetStarDust), 1.0)
    }

    func sensoryComfortLevels() -> [SensoryStep: Int] {
        var levels: [SensoryStep: Int] = [:]
        for step in SensoryStep.allCases {
            let completed = profile.questProgressItems.filter { $0.completedSteps.contains(step) }.count
            levels[step] = completed
        }
        return levels
    }

    func comfortPercentages() -> [SensoryStep: Double] {
        var percentages: [SensoryStep: Double] = [:]
        for step in SensoryStep.allCases {
            percentages[step] = profile.comfortLevel(for: step)
        }
        return percentages
    }

    func refreshBridgeSuggestions() {
        let safeFoods = profile.safeFoodIds.compactMap { FoodDatabase.food(byId: $0) }
        guard !safeFoods.isEmpty else {
            bridgeSuggestions = []
            return
        }

        if let targetId = profile.targetFoodId, let targetFood = FoodDatabase.food(byId: targetId) {
            bridgeSuggestions = FoodChainingEngine.suggestBridges(
                safeFoods: safeFoods,
                targetFood: targetFood,
                allFoods: FoodDatabase.allFoods,
                excludedAllergens: profile.excludedAllergens,
                bridgeHistory: profile.bridgeRecords
            )
        } else if let targetFood = FoodDatabase.food(byName: profile.targetFoodName) {
            profile.targetFoodId = targetFood.id
            bridgeSuggestions = FoodChainingEngine.suggestBridges(
                safeFoods: safeFoods,
                targetFood: targetFood,
                allFoods: FoodDatabase.allFoods,
                excludedAllergens: profile.excludedAllergens,
                bridgeHistory: profile.bridgeRecords
            )
        } else {
            bridgeSuggestions = []
        }
    }

    func startBridge(_ suggestion: BridgeSuggestion) {
        let record = BridgeRecordModel(
            safeFoodId: suggestion.fromSafeFood.id,
            bridgeFoodId: suggestion.bridgeFood.id,
            targetFoodId: suggestion.targetFood.id,
            bridgeType: suggestion.bridgeType
        )
        modelContext.insert(record)
        profile.bridgeRecords.append(record)
        refreshBridgeSuggestions()
        saveProfile()
    }

    func completeBridge(_ bridgeId: UUID) {
        if let record = profile.bridgeRecords.first(where: { $0.recordId == bridgeId }) {
            record.status = .completed
            let bridgeFoodId = record.bridgeFoodId
            if !profile.safeFoodIds.contains(bridgeFoodId) {
                profile.safeFoodIds.append(bridgeFoodId)
            }
        }
        refreshBridgeSuggestions()
        saveProfile()
    }

    func failBridge(_ bridgeId: UUID) {
        if let record = profile.bridgeRecords.first(where: { $0.recordId == bridgeId }) {
            record.status = .failed
        }
        refreshBridgeSuggestions()
        saveProfile()
    }

    func resumeStreak() {
        StreakService.resumeStreak(profile: profile)
        saveProfile()
    }

    var canResumeStreak: Bool {
        StreakService.canResumeStreak(profile: profile) && profile.currentStreak == 0 && profile.streakBrokenDate != nil
    }

    func saveProfile() {
        try? modelContext.save()
    }

    func resetApp() {
        PersistenceService.resetOnboarding()
        try? modelContext.delete(model: QuestProgressModel.self)
        try? modelContext.delete(model: SensoryInteractionModel.self)
        try? modelContext.delete(model: BridgeRecordModel.self)
        try? modelContext.delete(model: ChildProfileModel.self)
        try? modelContext.save()

        let newProfile = ChildProfileModel()
        modelContext.insert(newProfile)
        profile = newProfile
        bridgeSuggestions = []
        mode = .onboarding
    }

    private func resolveTargetFoodId() {
        if profile.targetFoodId == nil, !profile.targetFoodName.isEmpty {
            profile.targetFoodId = FoodDatabase.food(byName: profile.targetFoodName)?.id
        }
    }

    private func getOrCreateQuestProgress(for foodId: UUID) -> QuestProgressModel {
        if let existing = profile.questProgressItems.first(where: { $0.foodId == foodId }) {
            return existing
        }
        let new = QuestProgressModel(foodId: foodId)
        modelContext.insert(new)
        profile.questProgressItems.append(new)
        return new
    }

    private func updateBridgeExposure(foodId: UUID) {
        for record in profile.bridgeRecords {
            if record.bridgeFoodId == foodId && record.status == .active {
                record.exposureCount += 1
                record.lastExposureDate = Date()
            }
        }
    }

    private func checkStarJarReward() {
        if profile.totalStarDust >= profile.starJarTargetStarDust && !profile.starJarRewardUnlocked {
            profile.starJarRewardUnlocked = true
            profile.starJarRewardUnlockedDate = Date()
            showRewardUnlocked = true
        }
    }

    private func checkGearUnlocks() {
        let dust = profile.totalStarDust
        if dust >= 50 && !profile.unlockedGear.contains("glow_helmet") {
            profile.unlockedGear.append("glow_helmet")
        }
        if dust >= 150 && !profile.unlockedGear.contains("space_suit") {
            profile.unlockedGear.append("space_suit")
        }
        if dust >= 300 && !profile.unlockedGear.contains("rocket_boots") {
            profile.unlockedGear.append("rocket_boots")
        }
        if dust >= 500 && !profile.unlockedGear.contains("galaxy_cape") {
            profile.unlockedGear.append("galaxy_cape")
        }
    }

    private func checkCosmeticUnlocks() {
        let level = profile.currentLevel
        var unlocked = profile.unlockedCosmetics
        for cosmetic in Cosmetic.allCases {
            if cosmetic.requiredLevel.rawValue <= level.rawValue {
                unlocked.insert(cosmetic)
            }
        }
        profile.unlockedCosmetics = unlocked
    }

    private func checkLevelUp(previousLevel: ExplorerLevel) {
        let newLevel = profile.currentLevel
        if newLevel.rawValue > previousLevel.rawValue {
            newLevelReached = newLevel
            showLevelUp = true
        }
    }

    func dismissLevelUp() {
        withAnimation(.spring) {
            showLevelUp = false
            newLevelReached = nil
        }
    }

    func toggleCosmetic(_ cosmetic: Cosmetic) {
        var equipped = profile.equippedCosmetics
        if equipped.contains(cosmetic) {
            equipped.remove(cosmetic)
        } else {
            let sameCategory = equipped.filter { $0.category == cosmetic.category }
            for item in sameCategory { equipped.remove(item) }
            equipped.insert(cosmetic)
        }
        profile.equippedCosmetics = equipped
        saveProfile()
    }

    var targetFoodProgress: Double {
        guard let targetId = profile.targetFoodId else { return 0 }
        let progress = questProgress(for: targetId)
        return progress?.progressFraction ?? 0
    }

    var targetFood: FoodItem? {
        guard let targetId = profile.targetFoodId else { return nil }
        return FoodDatabase.food(byId: targetId) ?? customFoodItems.first { $0.id == targetId }
    }

    func createCustomFood(name: String, texture: FoodTexture, flavor: FoodFlavor, temperature: FoodTemperature) {
        let custom = CustomFoodModel(name: name, texture: texture, flavor: flavor, temperature: temperature)
        modelContext.insert(custom)
        try? modelContext.save()
        loadCustomFoods()
    }

    private func loadCustomFoods() {
        let descriptor = FetchDescriptor<CustomFoodModel>(sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
        let models = (try? modelContext.fetch(descriptor)) ?? []
        customFoodItems = models.map { $0.toFoodItem() }
    }

    func allDisplayFoods(for category: FoodCategory?) -> [FoodItem] {
        let combined = FoodDatabase.allFoods + customFoodItems
        if let category {
            return combined.filter { $0.category == category }
        }
        return combined
    }
}
