import SwiftData
import Foundation

nonisolated enum TasteVerification: String, Codable, Sendable {
    case swallowed
    case lickOnly
    case spitOut
    case unverified
}

@Model
class SensoryInteractionModel {
    var foodId: UUID = UUID()
    var sensoryStepRawValue: Int = 0
    var completed: Bool = false
    var timestamp: Date = Date()
    var parentVerified: Bool = false
    var tasteVerificationRawValue: String?
    var duration: Double?
    var profile: ChildProfileModel?

    init() {}

    init(foodId: UUID, sensoryStep: SensoryStep, completed: Bool, parentVerified: Bool = false, tasteVerification: TasteVerification? = nil, duration: TimeInterval? = nil) {
        self.foodId = foodId
        self.sensoryStepRawValue = sensoryStep.rawValue
        self.completed = completed
        self.timestamp = Date()
        self.parentVerified = parentVerified
        self.tasteVerificationRawValue = tasteVerification?.rawValue
        self.duration = duration
    }

    var sensoryStep: SensoryStep {
        get { SensoryStep(rawValue: sensoryStepRawValue) ?? .look }
        set { sensoryStepRawValue = newValue.rawValue }
    }

    var tasteVerification: TasteVerification? {
        get { tasteVerificationRawValue.flatMap { TasteVerification(rawValue: $0) } }
        set { tasteVerificationRawValue = newValue?.rawValue }
    }
}
