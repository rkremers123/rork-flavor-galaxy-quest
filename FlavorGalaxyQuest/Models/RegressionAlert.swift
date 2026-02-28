import Foundation

nonisolated enum RegressionPatternType: String, Sendable {
    case texture
    case flavor
    case temperature
}

nonisolated struct RegressionPattern: Identifiable, Sendable {
    let id: UUID
    let patternType: RegressionPatternType
    let attributeLabel: String
    let foods: [String]
    let count: Int
    let message: String
    let suggestion: String

    init(patternType: RegressionPatternType, attributeLabel: String, foods: [String], message: String, suggestion: String) {
        self.id = UUID()
        self.patternType = patternType
        self.attributeLabel = attributeLabel
        self.foods = foods
        self.count = foods.count
        self.message = message
        self.suggestion = suggestion
    }
}

nonisolated struct RegressionAlertItem: Identifiable, Sendable {
    let id: UUID
    let title: String
    let message: String
    let pattern: RegressionPattern?
    let date: Date
    var isRead: Bool

    init(title: String, message: String, pattern: RegressionPattern? = nil, date: Date = Date(), isRead: Bool = false) {
        self.id = UUID()
        self.title = title
        self.message = message
        self.pattern = pattern
        self.date = date
        self.isRead = isRead
    }
}
