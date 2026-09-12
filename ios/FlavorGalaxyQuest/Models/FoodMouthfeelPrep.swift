import Foundation

nonisolated enum FoodMouthfeel: String, Codable, CaseIterable, Sendable, Hashable {
    case juicy, dry, creamy, crispy, tender, chewy, mixed

    var label: String {
        switch self {
        case .juicy: "Juicy"
        case .dry: "Dry"
        case .creamy: "Creamy"
        case .crispy: "Crispy"
        case .tender: "Tender"
        case .chewy: "Chewy"
        case .mixed: "Mixed"
        }
    }
}

nonisolated enum FoodPrepMethod: String, Codable, CaseIterable, Sendable, Hashable {
    case raw, boiled, baked, fried, steamed, mixed

    var label: String {
        switch self {
        case .raw: "Raw"
        case .boiled: "Boiled"
        case .baked: "Baked"
        case .fried: "Fried"
        case .steamed: "Steamed"
        case .mixed: "Mixed"
        }
    }
}
