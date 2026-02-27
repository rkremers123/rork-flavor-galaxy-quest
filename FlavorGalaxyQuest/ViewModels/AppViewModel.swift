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

    init() {
        if PersistenceService.hasOnboarded, let saved = PersistenceService.loadProfile() {
            profile = saved
            mode = .explorer
        }
    }

    func completeOnboarding() {
        PersistenceService.hasOnboarded = true
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
        var progress = profile.questProgress[foodId] ?? QuestProgress(foodId: foodId)
        if !progress.completedSteps.contains(step) {
            progress.completedSteps.append(step)
            progress.starDustEarned += step.starDustReward
            profile.totalStarDust += step.starDustReward
        }
        progress.lastAttemptDate = Date()
        profile.questProgress[foodId] = progress
        saveProfile()
    }

    func skipStep(_ step: SensoryStep, for foodId: UUID) {
        var progress = profile.questProgress[foodId] ?? QuestProgress(foodId: foodId)
        if !progress.skippedSteps.contains(step) {
            progress.skippedSteps.append(step)
        }
        progress.lastAttemptDate = Date()
        profile.questProgress[foodId] = progress
        saveProfile()
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

    func saveProfile() {
        PersistenceService.saveProfile(profile)
    }

    func resetApp() {
        PersistenceService.resetAll()
        profile = ChildProfile()
        mode = .onboarding
    }
}
