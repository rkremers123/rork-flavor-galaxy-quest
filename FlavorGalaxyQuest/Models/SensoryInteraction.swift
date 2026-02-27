import Foundation

nonisolated enum TasteVerification: String, Codable, Sendable {
    case swallowed
    case lickOnly
    case spitOut
    case unverified
}

nonisolated struct SensoryInteraction: Codable, Identifiable, Sendable, Hashable {
    let id: UUID
    let foodId: UUID
    let sensoryStep: SensoryStep
    let completed: Bool
    let timestamp: Date
    var parentVerified: Bool
    var tasteVerification: TasteVerification?
    var duration: TimeInterval?

    init(
        foodId: UUID,
        sensoryStep: SensoryStep,
        completed: Bool,
        parentVerified: Bool = false,
        tasteVerification: TasteVerification? = nil,
        duration: TimeInterval? = nil
    ) {
        self.id = UUID()
        self.foodId = foodId
        self.sensoryStep = sensoryStep
        self.completed = completed
        self.timestamp = Date()
        self.parentVerified = parentVerified
        self.tasteVerification = tasteVerification
        self.duration = duration
    }
}
