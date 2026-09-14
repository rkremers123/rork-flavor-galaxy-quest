import SwiftUI
import SwiftData

enum AppMode {
    case parentOnboarding
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
    var selectedTab: Int = 0
    var activeQuestFoodId: UUID?
    var showPlanetCelebration: Bool = false
    var celebratedPlanet: JourneyPlanet?
    var showPlanetWisdom: Bool = false
    var wisdomPlanet: JourneyPlanet?
    var showCertificate: Bool = false

    var showStreakBroken: Bool = false
    var showStreakMilestone: Bool = false
    var streakMilestone: StreakMilestone?
    var lastCompletedStreak: Int = 0

    var sensoryProfile: SensoryProfile = .empty
    var foodRecommendations: [FoodRecommendation] = []
    var sensoryInsights: [String] = []
    let subscription = SubscriptionManager.shared

    var regressionPatterns: [RegressionPattern] = []
    var regressionAlerts: [RegressionAlertItem] = []
    var showRegressionModal: Bool = false
    var regressionTargetFood: FoodItem?
    var regressionTargetProgress: QuestProgressModel?
    var planetDistribution: [Int] = []

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
        planetDistribution = DynamicDifficultyService.foodsPerPlanet(for: profile)

        if PersistenceService.hasOnboarded {
            mode = .explorer
            let wasBroken = StreakService.updateStreak(profile: profile)
            if wasBroken {
                showStreakBroken = true
            }
            refreshBridgeSuggestions()
            refreshSensoryProfile()
            refreshRegressionPatterns()
            Task { await subscription.checkSubscriptionStatus() }
        } else {
            mode = .parentOnboarding
        }
    }

    func finishParentOnboarding() {
        withAnimation(.spring(duration: 0.5)) {
            mode = .onboarding
        }
    }

    func skipParentOnboarding() {
        withAnimation(.spring(duration: 0.5)) {
            mode = .onboarding
        }
    }

    func completeOnboarding() {
        PersistenceService.hasOnboarded = true
        planetDistribution = DynamicDifficultyService.foodsPerPlanet(for: profile)
        preCompleteSafeFoods()
        resolveTargetFoodId()
        refreshBridgeSuggestions()
        refreshSensoryProfile()
        selectedTab = 0
        activeQuestFoodId = nil
        saveProfile()
        withAnimation(.spring(duration: 0.6)) {
            mode = .explorer
        }
    }

    func preCompleteSafeFoods() {
        for foodId in profile.safeFoodIds {
            guard profile.questProgressItems.first(where: { $0.foodId == foodId }) == nil else { continue }
            let progress = QuestProgressModel(foodId: foodId)
            progress.completedSteps = []
            progress.starDustEarned = 0
            progress.isPreCompleted = true
            modelContext.insert(progress)
            profile.questProgressItems.append(progress)
        }
    }

    func resetFoodProgress(foodId: UUID) {
        if let progress = profile.questProgressItems.first(where: { $0.foodId == foodId }) {
            // Refund dust this food paid so reset + replay cannot farm Star Dust.
            let refund = max(0, progress.starDustEarned)
            if refund > 0 {
                profile.totalStarDust = max(0, profile.totalStarDust - refund)
            }
            progress.completedSteps = []
            progress.skippedSteps = []
            progress.lastAttemptDate = nil
            progress.starDustEarned = 0
            progress.stepStartTime = nil
            progress.isPreCompleted = false
        }

        let toRemove = profile.interactions.filter { $0.foodId == foodId }
        for interaction in toRemove {
            profile.interactions.removeAll { $0.foodId == foodId }
            modelContext.delete(interaction)
        }

        refreshSensoryProfile()
        saveProfile()
    }

    func switchToParentMode() {
        refreshSensoryProfile()
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
        let previousExplored = activeExploredFoodsCount
        let previousPlanet = DynamicDifficultyService.currentPlanet(for: previousExplored, distribution: planetDistribution)

        let progress = getOrCreateQuestProgress(for: foodId)

        if step.isHighStakes {
            pendingVerification = PendingVerification(foodId: foodId, step: step)
        }

        if !progress.completedSteps.contains(step) {
            // A real logged step graduates an onboarding seed into a live quest.
            if progress.isPreCompleted {
                progress.isPreCompleted = false
            }
            var steps = progress.completedSteps
            steps.append(step)
            progress.completedSteps = steps
            let reward = step.starDustReward
            if reward > 0 {
                progress.starDustEarned += reward
                profile.totalStarDust += reward
            }

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

        let milestone = StreakService.recordDailyAction(profile: profile)
        if let milestone {
            streakMilestone = milestone
            lastCompletedStreak = profile.currentStreak
        }
        updateBridgeExposure(foodId: foodId)
        saveProfile()

        if step == .taste || step == .lick {
            refreshSensoryProfile()
        }

        if isRegressed(foodId: foodId) {
            resolveRegression(foodId: foodId)
        }

        let newExplored = activeExploredFoodsCount
        let newPlanet = DynamicDifficultyService.currentPlanet(for: newExplored, distribution: planetDistribution)
        if newPlanet.rawValue > previousPlanet.rawValue {
            celebratedPlanet = newPlanet
            Task {
                try? await Task.sleep(for: .seconds(2.5))
                withAnimation(.spring) {
                    showPlanetCelebration = true
                }
            }
        }

        let lastPlanet = JourneyPlanet.harvestFestival
        if DynamicDifficultyService.isPlanetCompleted(lastPlanet, totalExplored: newExplored, distribution: planetDistribution) && !DynamicDifficultyService.isPlanetCompleted(lastPlanet, totalExplored: previousExplored, distribution: planetDistribution) {
            Task {
                try? await Task.sleep(for: .seconds(3))
                showCertificate = true
            }
        }
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
        refreshSensoryProfile()
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
        refreshSensoryProfile()
    }

    func startStep(for foodId: UUID) {
        let progress = getOrCreateQuestProgress(for: foodId)
        progress.stepStartTime = Date()
    }

    func questProgress(for foodId: UUID) -> QuestProgressModel? {
        profile.questProgressItems.first { $0.foodId == foodId }
    }

    /// Onboarding safes / parent-marked already-likes. Not a quest.
    var alreadyLikeFoodsCount: Int {
        profile.questProgressItems.filter { $0.isPreCompleted }.count
    }

    /// Planet foods need a real active exploration: not onboarding precomplete, and not look-only.
    func countsAsPlanetFood(_ progress: QuestProgressModel) -> Bool {
        guard !progress.isPreCompleted else { return false }
        return progress.completedSteps.contains { $0 != .look }
    }

    var activeExploredFoodsCount: Int {
        profile.questProgressItems.filter { countsAsPlanetFood($0) }.count
    }

    /// Explored = real quests with a step beyond look-only. Same rule as planet foods.
    var exploredFoodsCount: Int {
        activeExploredFoodsCount
    }

    /// Eaten / mastered = taste completed and parent verified swallowed. Lick and onboarding never count.
    func isEatenProgress(_ progress: QuestProgressModel) -> Bool {
        guard !progress.isPreCompleted else { return false }
        guard progress.completedSteps.contains(.taste) else { return false }
        return profile.interactions.contains { interaction in
            interaction.foodId == progress.foodId
                && interaction.sensoryStep == .taste
                && interaction.completed
                && interaction.tasteVerification == .swallowed
        }
    }

    var eatenFoodsCount: Int {
        profile.questProgressItems.filter { isEatenProgress($0) }.count
    }

    var isFirstRun: Bool {
        activeExploredFoodsCount == 0
    }

    var firstQuestFood: FoodItem? {
        guard let goal = resolvedGoalFood() else { return nil }
        if !isHardExcluded(goal) { return goal }
        return firstSafeSuggestion()
    }

    private func resolvedGoalFood() -> FoodItem? {
        if let food = targetFood { return food }
        for raw in [profile.goalFoodName, profile.targetFoodName] {
            let name = raw.trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { continue }
            if let food = FoodDatabase.food(byName: name) { return food }
            if let custom = customFoodItems.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) {
                return custom
            }
        }
        return nil
    }

    var firstQuestDisplayName: String {
        if let food = firstQuestFood { return food.name }
        let goal = profile.goalFoodName.trimmingCharacters(in: .whitespaces)
        if !goal.isEmpty {
            if let catalog = FoodDatabase.food(byName: goal), isHardExcluded(catalog) { return "" }
            return goal
        }
        let target = profile.targetFoodName.trimmingCharacters(in: .whitespaces)
        if let catalog = FoodDatabase.food(byName: target), isHardExcluded(catalog) { return "" }
        return target
    }

    var completedQuestsCount: Int {
        eatenFoodsCount
    }

    var starJarProgress: Double {
        guard profile.starJarTargetStarDust > 0 else { return 0 }
        return min(Double(profile.totalStarDust) / Double(profile.starJarTargetStarDust), 1.0)
    }

    func sensoryComfortLevels() -> [SensoryStep: Int] {
        var levels: [SensoryStep: Int] = [:]
        for step in SensoryStep.allCases {
            let completed = profile.questProgressItems.filter { !$0.isPreCompleted && $0.completedSteps.contains(step) }.count
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
            if isHardExcluded(targetFood) {
                bridgeSuggestions = []
                return
            }
            bridgeSuggestions = FoodChainingEngine.suggestBridges(
                safeFoods: safeFoods,
                targetFood: targetFood,
                allFoods: FoodDatabase.allFoods + customFoodItems,
                excludedAllergens: profile.excludedAllergens,
                excludedFoodIds: Set(profile.neverOfferFoodIds),
                bridgeHistory: profile.bridgeRecords
            )
        } else if let targetFood = FoodDatabase.food(byName: profile.targetFoodName) {
            profile.targetFoodId = targetFood.id
            if isHardExcluded(targetFood) {
                bridgeSuggestions = []
                return
            }
            bridgeSuggestions = FoodChainingEngine.suggestBridges(
                safeFoods: safeFoods,
                targetFood: targetFood,
                allFoods: FoodDatabase.allFoods + customFoodItems,
                excludedAllergens: profile.excludedAllergens,
                excludedFoodIds: Set(profile.neverOfferFoodIds),
                bridgeHistory: profile.bridgeRecords
            )
        } else {
            bridgeSuggestions = []
        }
    }

    func refreshSensoryProfile() {
        let allFoods = FoodDatabase.allFoods + customFoodItems
        sensoryProfile = SensoryProfileCalculator.calculateProfile(
            profile: profile,
            allFoods: allFoods
        )
        sensoryInsights = SensoryProfileCalculator.generateInsights(profile: sensoryProfile)
        refreshRecommendations()
    }

    func refreshRecommendations() {
        let allFoods = FoodDatabase.allFoods + customFoodItems
        var excludedIds = Set(profile.neverOfferFoodIds)
        excludedIds.formUnion(profile.safeFoodIds)
        foodRecommendations = RecommendationEngine.generateRecommendations(
            sensoryProfile: sensoryProfile,
            allFoods: allFoods,
            excludedAllergens: profile.excludedAllergens,
            excludedFoodIds: excludedIds
        )
    }

    func exportTherapistPDF() -> Data {
        let allFoods = FoodDatabase.allFoods + customFoodItems
        return TherapistExportService.generatePDFData(
            profile: profile,
            sensoryProfile: sensoryProfile,
            allFoods: allFoods
        )
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
        try? modelContext.delete(model: RegressionModel.self)
        try? modelContext.delete(model: ChildProfileModel.self)
        try? modelContext.save()

        let newProfile = ChildProfileModel()
        modelContext.insert(newProfile)
        profile = newProfile
        bridgeSuggestions = []
        sensoryProfile = .empty
        foodRecommendations = []
        sensoryInsights = []
        regressionPatterns = []
        regressionAlerts = []
        mode = .parentOnboarding
    }

    private func resolveTargetFoodId() {
        if profile.targetFoodId == nil {
            let name = profile.targetFoodName.isEmpty ? profile.goalFoodName : profile.targetFoodName
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty {
                profile.targetFoodId = FoodDatabase.food(byName: trimmed)?.id
                if profile.targetFoodName.isEmpty {
                    profile.targetFoodName = trimmed
                }
            }
        }
    }

    func getOrCreateQuestProgress(for foodId: UUID) -> QuestProgressModel {
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

    func checkCosmeticUnlocks() {
        let level = profile.currentLevel
        let foodsLogged = activeExploredFoodsCount
        let daysLogged = profile.longestStreak
        let planetsUnlocked = JourneyPlanet.allCases.filter { dynamicIsPlanetCompleted($0) }.count

        let exploredFoodIds = Set(profile.questProgressItems.filter { countsAsPlanetFood($0) }.map { $0.foodId })
        let allFoods = FoodDatabase.allFoods + customFoodItems
        let completedCategories = Set(allFoods.filter { exploredFoodIds.contains($0.id) }.map { $0.category })

        var phaseCompletion: [SensoryStep: Bool] = [:]
        for step in SensoryStep.allCases {
            let count = profile.questProgressItems.filter { !$0.isPreCompleted && $0.completedSteps.contains(step) }.count
            phaseCompletion[step] = count > 0
        }
        let allPhasesComplete = SensoryStep.allCases.allSatisfy { phaseCompletion[$0] == true }

        var unlocked = profile.unlockedCosmetics
        for cosmetic in Cosmetic.allCases {
            let met: Bool
            switch cosmetic.unlockCondition {
            case .level(let req): met = level.rawValue >= req.rawValue
            case .foodsLogged(let n): met = foodsLogged >= n
            case .daysLogged(let n): met = daysLogged >= n
            case .reachPhase(let step): met = phaseCompletion[step] == true
            case .completeAllPhases: met = allPhasesComplete
            case .foodFamilies(let n): met = completedCategories.count >= n
            case .planetsUnlocked(let n): met = planetsUnlocked >= n
            }
            if met { unlocked.insert(cosmetic) }
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

    var activeQuestFood: FoodItem? {
        guard let id = activeQuestFoodId else { return nil }
        return FoodDatabase.food(byId: id) ?? customFoodItems.first { $0.id == id }
    }

    var activeQuestProgress: QuestProgressModel? {
        guard let id = activeQuestFoodId else { return nil }
        return questProgress(for: id)
    }

    /// Starts this food as the live quest and opens the Quest tab.
    /// If another quest is already active, this switches to the new food (parent-safe, no confirm).
    /// Allergen / do-not-give foods never become the Start Quest target.
    func setActiveQuest(food: FoodItem) {
        if isHardExcluded(food) {
            if let next = firstSafeSuggestion() {
                activeQuestFoodId = next.id
                _ = getOrCreateQuestProgress(for: next.id)
                selectedTab = 1
            } else {
                selectedTab = 2
            }
            return
        }
        activeQuestFoodId = food.id
        _ = getOrCreateQuestProgress(for: food.id)
        selectedTab = 1
    }

    /// Kid escape hatch: leave this sitting without completing or skipping a step.
    /// Star Dust, lick, and ate are unchanged. The food stays the active quest.
    func pauseQuestSitting() {
        selectedTab = 0
    }

    func isHardExcluded(_ food: FoodItem) -> Bool {
        if !food.allergens.isDisjoint(with: profile.excludedAllergens) { return true }
        if profile.neverOfferFoodIds.contains(food.id) { return true }
        if let catalog = FoodDatabase.food(byName: food.name), catalog.id != food.id {
            if !catalog.allergens.isDisjoint(with: profile.excludedAllergens) { return true }
            if profile.neverOfferFoodIds.contains(catalog.id) { return true }
        }
        return false
    }

    func isKnownSafeOrLiked(_ food: FoodItem) -> Bool {
        profile.safeFoodIds.contains(food.id) || sensoryProfile.successfulFoodIds.contains(food.id)
    }

    func firstSafeSuggestion() -> FoodItem? {
        if let rec = foodRecommendations.first(where: { !isHardExcluded($0.food) && !isKnownSafeOrLiked($0.food) }) {
            return rec.food
        }
        if let bridge = bridgeSuggestions.first(where: { !isHardExcluded($0.bridgeFood) }) {
            return bridge.bridgeFood
        }
        return nil
    }

    func toggleNeverOffer(food: FoodItem) {
        if let idx = profile.neverOfferFoodIds.firstIndex(of: food.id) {
            profile.neverOfferFoodIds.remove(at: idx)
        } else {
            profile.neverOfferFoodIds.append(food.id)
        }
        refreshBridgeSuggestions()
        refreshRecommendations()
        saveProfile()
    }

    var neverOfferFoods: [FoodItem] {
        let all = FoodDatabase.allFoods + customFoodItems
        return profile.neverOfferFoodIds.compactMap { id in all.first { $0.id == id } }
    }

    func suggestedQuestFood(for planet: JourneyPlanet? = nil) -> FoodItem? {
        if let planet {
            let foods = foodsForPlanet(planet)
            if let inProgress = foods.first(where: { questProgress(for: $0.id)?.isComplete != true && !isHardExcluded($0) }) {
                return inProgress
            }
        }
        if let first = firstQuestFood, !isHardExcluded(first) { return first }
        if let rec = foodRecommendations.first(where: { !isHardExcluded($0.food) }) { return rec.food }
        if let bridge = bridgeSuggestions.first(where: { !isHardExcluded($0.bridgeFood) }) { return bridge.bridgeFood }
        return firstSafeSuggestion()
    }

    func startFirstQuest() {
        if let food = firstQuestFood {
            setActiveQuest(food: food)
            return
        }
        let goal = profile.goalFoodName.trimmingCharacters(in: .whitespaces)
        let target = profile.targetFoodName.trimmingCharacters(in: .whitespaces)
        let name = !goal.isEmpty ? goal : target
        if !name.isEmpty {
            if let catalog = FoodDatabase.food(byName: name), isHardExcluded(catalog) {
                if let next = firstSafeSuggestion() {
                    setActiveQuest(food: next)
                } else {
                    selectedTab = 2
                }
                return
            }
            let food = createCustomFood(
                name: name,
                texture: profile.goalFoodTextures.first ?? .soft,
                flavor: profile.goalFoodFlavors.first ?? .bland,
                temperature: profile.goalFoodTemperature ?? .roomTemp
            )
            if isHardExcluded(food) {
                if let next = firstSafeSuggestion() {
                    setActiveQuest(food: next)
                } else {
                    selectedTab = 2
                }
                return
            }
            profile.targetFoodId = food.id
            profile.targetFoodName = name
            saveProfile()
            setActiveQuest(food: food)
            return
        }
        selectedTab = 2
    }

    func startSuggestedQuest(for planet: JourneyPlanet? = nil) {
        if let food = suggestedQuestFood(for: planet) {
            setActiveQuest(food: food)
        } else {
            selectedTab = 2
        }
    }

    func dismissPlanetCelebration() {
        let planet = celebratedPlanet
        withAnimation(.spring) {
            showPlanetCelebration = false
            celebratedPlanet = nil
        }
        if let planet {
            wisdomPlanet = planet
            withAnimation(.spring(duration: 0.4)) {
                showPlanetWisdom = true
            }
        }
    }

    func dismissPlanetWisdom() {
        withAnimation(.spring) {
            showPlanetWisdom = false
            wisdomPlanet = nil
            selectedTab = 0
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

    @discardableResult
    func createCustomFood(name: String, texture: FoodTexture, flavor: FoodFlavor, temperature: FoodTemperature, color: FoodColor = .brown, foodGroup: FoodGroup = .other) -> FoodItem {
        let custom = CustomFoodModel(name: name, texture: texture, flavor: flavor, temperature: temperature, color: color, foodGroup: foodGroup)
        modelContext.insert(custom)
        try? modelContext.save()
        loadCustomFoods()
        return custom.toFoodItem()
    }

    private func loadCustomFoods() {
        let descriptor = FetchDescriptor<CustomFoodModel>(sortBy: [SortDescriptor(\.createdDate, order: .reverse)])
        let models = (try? modelContext.fetch(descriptor)) ?? []
        customFoodItems = models.map { $0.toFoodItem() }
    }

    func foodsForPlanet(_ planet: JourneyPlanet) -> [FoodItem] {
        let explored = profile.questProgressItems
            .filter { countsAsPlanetFood($0) }
            .sorted { ($0.lastAttemptDate ?? .distantPast) < ($1.lastAttemptDate ?? .distantPast) }

        let start = DynamicDifficultyService.foodsRequiredForPlanet(planet, distribution: planetDistribution)
        let planetFoods = DynamicDifficultyService.foodsForPlanet(planet, distribution: planetDistribution)
        let end = min(start + planetFoods, explored.count)
        guard start < explored.count else { return [] }

        let allFoods = FoodDatabase.allFoods + customFoodItems
        return explored[start..<end].compactMap { progress in
            allFoods.first { $0.id == progress.foodId }
        }
    }

    func dynamicFoodsForPlanet(_ planet: JourneyPlanet) -> Int {
        DynamicDifficultyService.foodsForPlanet(planet, distribution: planetDistribution)
    }

    func dynamicFoodsCompleted(_ planet: JourneyPlanet) -> Int {
        DynamicDifficultyService.foodsCompletedInPlanet(planet, totalExplored: activeExploredFoodsCount, distribution: planetDistribution)
    }

    func dynamicIsPlanetCompleted(_ planet: JourneyPlanet) -> Bool {
        DynamicDifficultyService.isPlanetCompleted(planet, totalExplored: activeExploredFoodsCount, distribution: planetDistribution)
    }

    func dynamicIsPlanetLocked(_ planet: JourneyPlanet) -> Bool {
        DynamicDifficultyService.isPlanetLocked(planet, totalExplored: activeExploredFoodsCount, distribution: planetDistribution)
    }

    var dynamicCurrentPlanet: JourneyPlanet {
        DynamicDifficultyService.currentPlanet(for: activeExploredFoodsCount, distribution: planetDistribution)
    }

    func allDisplayFoods(for category: FoodCategory?) -> [FoodItem] {
        let combined = FoodDatabase.allFoods + customFoodItems
        if let category {
            return combined.filter { $0.category == category }
        }
        return combined
    }

    func markAsUsedToEat(food: FoodItem, regressionDate: Date, notes: String) {
        let progress = questProgress(for: food.id)
        let masterDate = progress?.lastAttemptDate ?? profile.createdDate

        let regression = RegressionModel(
            foodId: food.id,
            foodName: food.name,
            regressionDate: regressionDate,
            masterDate: masterDate,
            texture: food.texture,
            flavor: food.flavor,
            temperature: food.temperature,
            notes: notes
        )
        modelContext.insert(regression)
        profile.regressions.append(regression)

        refreshRegressionPatterns()
        saveProfile()
    }

    func resolveRegression(foodId: UUID) {
        let activeRegressions = profile.regressions.filter { $0.foodId == foodId && $0.status == .active }
        for regression in activeRegressions {
            regression.status = .resolved
            regression.resolvedDate = Date()
        }
        refreshRegressionPatterns()
        saveProfile()
    }

    func reMasterFood(foodId: UUID) {
        resolveRegression(foodId: foodId)
        refreshSensoryProfile()
    }

    func isRegressed(foodId: UUID) -> Bool {
        profile.regressions.contains { $0.foodId == foodId && $0.status == .active }
    }

    func regressionForFood(_ foodId: UUID) -> RegressionModel? {
        profile.regressions.first { $0.foodId == foodId && $0.status == .active }
    }

    func refreshRegressionPatterns() {
        regressionPatterns = RegressionTrackingService.detectPatterns(
            regressions: profile.regressions,
            childName: profile.explorerDisplayName
        )
        regressionAlerts = RegressionTrackingService.generateAlerts(
            patterns: regressionPatterns,
            childName: profile.explorerDisplayName
        )
    }

    var activeRegressionCount: Int {
        profile.regressions.filter { $0.status == .active }.count
    }

    var activeRegressions: [RegressionModel] {
        profile.regressions.filter { $0.status == .active }
            .sorted { $0.regressionDate > $1.regressionDate }
    }

    var recentRegressions: [RegressionModel] {
        profile.regressions
            .sorted { $0.regressionDate > $1.regressionDate }
            .prefix(10)
            .map { $0 }
    }

    func beginRegressionFlow(food: FoodItem) {
        regressionTargetFood = food
        regressionTargetProgress = questProgress(for: food.id)
        showRegressionModal = true
    }
}
