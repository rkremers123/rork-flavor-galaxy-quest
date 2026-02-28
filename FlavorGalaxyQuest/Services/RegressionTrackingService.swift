import Foundation

struct RegressionTrackingService {
    static func detectPatterns(regressions: [RegressionModel], childName: String) -> [RegressionPattern] {
        let activeRegressions = regressions.filter { $0.status == .active && $0.daysSinceRegression <= 30 }
        guard activeRegressions.count >= 2 else { return [] }

        var patterns: [RegressionPattern] = []

        let textureGroups = Dictionary(grouping: activeRegressions) { $0.texture }
        for (texture, foods) in textureGroups where foods.count >= 2 {
            let foodNames = foods.map(\.foodName)
            let pattern = RegressionPattern(
                patternType: .texture,
                attributeLabel: texture.label,
                foods: foodNames,
                message: "\(childName) has regressed on \(foods.count) \(texture.label.lowercased()) foods recently (\(foodNames.joined(separator: ", "))). This might signal sensory anxiety or texture avoidance.",
                suggestion: "Consider taking a break from \(texture.label.lowercased()) textures for 2 weeks, then slowly reintroduce with familiar flavors."
            )
            patterns.append(pattern)
        }

        let flavorGroups = Dictionary(grouping: activeRegressions) { $0.flavor }
        for (flavor, foods) in flavorGroups where foods.count >= 2 {
            let foodNames = foods.map(\.foodName)
            let pattern = RegressionPattern(
                patternType: .flavor,
                attributeLabel: flavor.label,
                foods: foodNames,
                message: "\(childName) used to enjoy \(flavor.label.lowercased()) flavors like \(foodNames.joined(separator: ", ")), but hasn't eaten them recently. This could be sensory sensitivity or taste preference changing.",
                suggestion: "Take a 2-week break from \(flavor.label.lowercased()) foods. Restart with a gentle option that bridges to familiar textures."
            )
            patterns.append(pattern)
        }

        let tempGroups = Dictionary(grouping: activeRegressions) { $0.temperature }
        for (temp, foods) in tempGroups where foods.count >= 2 {
            let foodNames = foods.map(\.foodName)
            let pattern = RegressionPattern(
                patternType: .temperature,
                attributeLabel: temp.label,
                foods: foodNames,
                message: "\(childName) used to eat \(temp.label.lowercased()) foods but has avoided them recently. \(temp == .hot ? "Hot foods might feel threatening right now." : "This temperature preference may be shifting.")",
                suggestion: temp == .hot
                    ? "Cool things down and restart warm foods in a few weeks."
                    : "Try bridging through room temperature versions of these foods."
            )
            patterns.append(pattern)
        }

        return patterns.sorted { $0.count > $1.count }
    }

    static func generateAlerts(patterns: [RegressionPattern], childName: String) -> [RegressionAlertItem] {
        patterns.map { pattern in
            RegressionAlertItem(
                title: "\(pattern.patternType == .flavor ? "Flavor" : pattern.patternType == .texture ? "Texture" : "Temperature") Pattern Detected",
                message: pattern.message,
                pattern: pattern
            )
        }
    }
}
