import SwiftData
import Foundation

@Model
class QuestProgressModel {
    var foodId: UUID = UUID()
    var completedStepValues: [Int] = []
    var lastAttemptDate: Date?
    var starDustEarned: Int = 0
    var skippedStepValues: [Int] = []
    var stepStartTime: Date?
    var profile: ChildProfileModel?

    init() {}

    init(foodId: UUID) {
        self.foodId = foodId
    }

    var completedSteps: [SensoryStep] {
        get { completedStepValues.compactMap { SensoryStep(rawValue: $0) } }
        set { completedStepValues = newValue.map(\.rawValue) }
    }

    var skippedSteps: [SensoryStep] {
        get { skippedStepValues.compactMap { SensoryStep(rawValue: $0) } }
        set { skippedStepValues = newValue.map(\.rawValue) }
    }

    var currentStep: SensoryStep? {
        let allSteps = SensoryStep.allCases
        return allSteps.first { !completedSteps.contains($0) && !skippedSteps.contains($0) }
    }

    var progressFraction: Double {
        Double(completedStepValues.count) / Double(SensoryStep.allCases.count)
    }

    var isComplete: Bool {
        completedStepValues.count == SensoryStep.allCases.count
    }

    var isExpired: Bool {
        guard let lastAttempt = lastAttemptDate else { return false }
        return Date().timeIntervalSince(lastAttempt) > 86400
    }
}
