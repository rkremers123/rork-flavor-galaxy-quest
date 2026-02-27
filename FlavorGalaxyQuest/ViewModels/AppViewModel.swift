import SwiftUI

enum AppMode {
    case onboarding
    case explorer
    case parentDashboard
}

@Observable
@MainActor
class AppViewModel {
    var mode: AppMode = .onboarding
    var profile: ChildProfile = ChildProfile()
    var showParentGate: Bool = false
    var isTransitioning: Bool = false
    var bridgeSuggestions: [BridgeSuggestion] = []
    var showRewardUnlocked: Bool = false
    var pendingVerification: PendingVerification?

    struct PendingVerification {
        let foodId: UUID
        let step: SensoryStep
    }

    init() {
        if PersistenceService.hasOnboarded, let saved = PersistenceService.loadProfile() {
            profile = saved
            mode = .explorer
            StreakService.updateStreak(profile: &profile, interactions: profile.interactions)
            refreshBridgeSuggestions()
            saveProfile()
        }
    }

    func completeOnboarding() {
        PersistenceService.hasOnboarded = true
        resolveTargetFoodId()
        saveProfile()
        refreshBridgeSuggestions()
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
        var progress = profile.questProgress[foodId] ?? QuestProgress(foodId: foodId)

        if step.isHighStakes {
            pendingVerification = PendingVerification(foodId: foodId, step: step)
        }

        if !progress.completedSteps.contains(step) {
            progress.completedSteps.append(step)
            progress.starDustEarned += step.starDustReward
            profile.totalStarDust += step.starDustReward

            checkStarJarReward()
            checkGearUnlocks()
        }

        progress.lastAttemptDate = Date()
        progress.stepStartTime = nil
        profile.questProgress[foodId] = progress

        let interaction = SensoryInteraction(
            foodId: foodId,
            sensoryStep: step,
            completed: true,
            parentVerified: !step.isHighStakes
        )
        profile.interactions.append(interaction)

        StreakService.recordDailyAction(profile: &profile)
        updateBridgeExposure(foodId: foodId)
        PersistenceService.saveQuestState(progress, for: foodId)
        saveProfile()
    }

    func verifyTasteStep(foodId: UUID, verification: TasteVerification) {
        if let index = profile.interactions.lastIndex(where: { $0.foodId == foodId && $0.sensoryStep == .taste || $0.sensoryStep == .lick }) {
            profile.interactions[index].parentVerified = true
            profile.interactions[index].tasteVerification = verification
        }
        pendingVerification = nil
        saveProfile()
    }

    func skipStep(_ step: SensoryStep, for foodId: UUID) {
        var progress = profile.questProgress[foodId] ?? QuestProgress(foodId: foodId)
        if !progress.skippedSteps.contains(step) {
            progress.skippedSteps.append(step)
        }
        progress.lastAttemptDate = Date()
        profile.questProgress[foodId] = progress

        let interaction = SensoryInteraction(
            foodId: foodId,
            sensoryStep: step,
            completed: false
        )
        profile.interactions.append(interaction)

        saveProfile()
    }

    func startStep(for foodId: UUID) {
        var progress = profile.questProgress[foodId] ?? QuestProgress(foodId: foodId)
        progress.stepStartTime = Date()
        profile.questProgress[foodId] = progress
    }

    func questProgress(for foodId: UUID) -> QuestProgress {
        profile.questProgress[foodId] ?? QuestProgress(foodId: foodId)
    }

    var exploredFoodsCount: Int {
        profile.questProgress.values.filter { !$0.completedSteps.isEmpty }.count
    }

    var completedQuestsCount: Int {
        profile.questProgress.values.filter { $0.isComplete }.count
    }

    var starJarProgress: Double {
        guard profile.starJar.targetStarDust > 0 else { return 0 }
        return min(Double(profile.totalStarDust) / Double(profile.starJar.targetStarDust), 1.0)
    }

    func sensoryComfortLevels() -> [SensoryStep: Int] {
        var levels: [SensoryStep: Int] = [:]
        for step in SensoryStep.allCases {
            let completed = profile.questProgress.values.filter { $0.completedSteps.contains(step) }.count
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
        let record = BridgeRecord(
            safeFoodId: suggestion.fromSafeFood.id,
            bridgeFoodId: suggestion.bridgeFood.id,
            targetFoodId: suggestion.targetFood.id,
            bridgeType: suggestion.bridgeType
        )
        profile.bridgeRecords.append(record)
        refreshBridgeSuggestions()
        saveProfile()
    }

    func completeBridge(_ bridgeId: UUID) {
        if let index = profile.bridgeRecords.firstIndex(where: { $0.id == bridgeId }) {
            profile.bridgeRecords[index].status = .completed
            let bridgeFoodId = profile.bridgeRecords[index].bridgeFoodId
            if !profile.safeFoodIds.contains(bridgeFoodId) {
                profile.safeFoodIds.append(bridgeFoodId)
            }
        }
        refreshBridgeSuggestions()
        saveProfile()
    }

    func failBridge(_ bridgeId: UUID) {
        if let index = profile.bridgeRecords.firstIndex(where: { $0.id == bridgeId }) {
            profile.bridgeRecords[index].status = .failed
        }
        refreshBridgeSuggestions()
        saveProfile()
    }

    func resumeStreak() {
        StreakService.resumeStreak(profile: &profile)
        saveProfile()
    }

    var canResumeStreak: Bool {
        StreakService.canResumeStreak(profile: profile) && profile.currentStreak == 0 && profile.streakBrokenDate != nil
    }

    func saveProfile() {
        PersistenceService.saveProfile(profile)
    }

    func resetApp() {
        PersistenceService.resetAll()
        profile = ChildProfile()
        bridgeSuggestions = []
        mode = .onboarding
    }

    private func resolveTargetFoodId() {
        if profile.targetFoodId == nil, !profile.targetFoodName.isEmpty {
            profile.targetFoodId = FoodDatabase.food(byName: profile.targetFoodName)?.id
        }
    }

    private func updateBridgeExposure(foodId: UUID) {
        for i in profile.bridgeRecords.indices {
            if profile.bridgeRecords[i].bridgeFoodId == foodId && profile.bridgeRecords[i].status == .active {
                profile.bridgeRecords[i].exposureCount += 1
                profile.bridgeRecords[i].lastExposureDate = Date()
            }
        }
    }

    private func checkStarJarReward() {
        if profile.totalStarDust >= profile.starJar.targetStarDust && !profile.starJar.rewardUnlocked {
            profile.starJar.rewardUnlocked = true
            profile.starJar.rewardUnlockedDate = Date()
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

    var targetFoodProgress: Double {
        guard let targetId = profile.targetFoodId else { return 0 }
        let progress = questProgress(for: targetId)
        return progress.progressFraction
    }

    var targetFood: FoodItem? {
        guard let targetId = profile.targetFoodId else { return nil }
        return FoodDatabase.food(byId: targetId)
    }
}
