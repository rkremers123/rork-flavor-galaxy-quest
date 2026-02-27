import Foundation

nonisolated enum Allergen: String, Codable, CaseIterable, Sendable, Hashable {
    case gluten
    case dairy
    case peanut
    case treeNut
    case shellfish
    case soy
    case egg
    case fish
    case sesame

    var label: String {
        switch self {
        case .gluten: "Gluten"
        case .dairy: "Dairy"
        case .peanut: "Peanut"
        case .treeNut: "Tree Nut"
        case .shellfish: "Shellfish"
        case .soy: "Soy"
        case .egg: "Egg"
        case .fish: "Fish"
        case .sesame: "Sesame"
        }
    }

    var icon: String {
        switch self {
        case .gluten: "leaf.fill"
        case .dairy: "cup.and.saucer.fill"
        case .peanut: "exclamationmark.triangle.fill"
        case .treeNut: "tree.fill"
        case .shellfish: "tortoise.fill"
        case .soy: "drop.fill"
        case .egg: "oval.fill"
        case .fish: "fish.fill"
        case .sesame: "circle.grid.3x3.fill"
        }
    }
}
