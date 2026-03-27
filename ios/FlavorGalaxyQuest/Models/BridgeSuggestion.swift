import SwiftData
import Foundation

nonisolated enum BridgeType: String, Codable, CaseIterable, Sendable, Hashable {
    case brand
    case visual
    case texture
    case flavor

    var label: String {
        switch self {
        case .brand: "Brand Bridge"
        case .visual: "Visual Bridge"
        case .texture: "Texture Bridge"
        case .flavor: "Flavor Fade"
        }
    }

    var icon: String {
        switch self {
        case .brand: "tag.fill"
        case .visual: "eye.fill"
        case .texture: "hand.raised.fill"
        case .flavor: "drop.fill"
        }
    }

    var priority: Int {
        switch self {
        case .brand: 0
        case .visual: 1
        case .texture: 2
        case .flavor: 3
        }
    }

    var exposureDaysNeeded: Int {
        switch self {
        case .brand: 0
        case .visual: 3
        case .texture: 7
        case .flavor: 14
        }
    }

    var successRate: String {
        switch self {
        case .brand: "80%"
        case .visual: "60%"
        case .texture: "50%"
        case .flavor: "40%"
        }
    }

    var explanation: String {
        switch self {
        case .brand: "Same type of food, slightly different form"
        case .visual: "Similar texture and aroma, different appearance"
        case .texture: "One step closer on the texture scale"
        case .flavor: "Introducing a new flavor gradually"
        }
    }
}

nonisolated struct BridgeSuggestion: Sendable, Identifiable, Hashable {
    let id: UUID
    let bridgeFood: FoodItem
    let fromSafeFood: FoodItem
    let targetFood: FoodItem
    let bridgeType: BridgeType
    let reason: String
    let sensoryDistance: Int

    init(
        bridgeFood: FoodItem,
        fromSafeFood: FoodItem,
        targetFood: FoodItem,
        bridgeType: BridgeType,
        reason: String,
        sensoryDistance: Int
    ) {
        self.id = UUID()
        self.bridgeFood = bridgeFood
        self.fromSafeFood = fromSafeFood
        self.targetFood = targetFood
        self.bridgeType = bridgeType
        self.reason = reason
        self.sensoryDistance = sensoryDistance
    }
}

nonisolated enum BridgeStatus: String, Codable, Sendable {
    case active
    case completed
    case failed
    case skipped
}

@Model
class BridgeRecordModel {
    var recordId: UUID = UUID()
    var safeFoodId: UUID = UUID()
    var bridgeFoodId: UUID = UUID()
    var targetFoodId: UUID = UUID()
    var bridgeTypeRawValue: String = BridgeType.brand.rawValue
    var startDate: Date = Date()
    var exposureCount: Int = 0
    var statusRawValue: String = BridgeStatus.active.rawValue
    var lastExposureDate: Date?
    var profile: ChildProfileModel?

    init() {}

    init(safeFoodId: UUID, bridgeFoodId: UUID, targetFoodId: UUID, bridgeType: BridgeType) {
        self.recordId = UUID()
        self.safeFoodId = safeFoodId
        self.bridgeFoodId = bridgeFoodId
        self.targetFoodId = targetFoodId
        self.bridgeTypeRawValue = bridgeType.rawValue
        self.startDate = Date()
        self.exposureCount = 0
        self.statusRawValue = BridgeStatus.active.rawValue
    }

    var bridgeType: BridgeType {
        get { BridgeType(rawValue: bridgeTypeRawValue) ?? .brand }
        set { bridgeTypeRawValue = newValue.rawValue }
    }

    var status: BridgeStatus {
        get { BridgeStatus(rawValue: statusRawValue) ?? .active }
        set { statusRawValue = newValue.rawValue }
    }

    var daysActive: Int {
        let days = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return max(days, 0)
    }

    var isReadyForNextBridge: Bool {
        daysActive >= bridgeType.exposureDaysNeeded && exposureCount >= bridgeType.exposureDaysNeeded
    }
}
