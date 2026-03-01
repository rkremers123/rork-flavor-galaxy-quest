import Foundation

struct DynamicDifficultyService {
    static func calculateFoodsPerPlanet(totalFoods: Int, preSelectedFoods: Int) -> [Int] {
        let planetsCount = JourneyPlanet.allCases.count
        let remaining = max(totalFoods - preSelectedFoods, planetsCount)
        let base = Double(remaining) / Double(planetsCount)

        var distribution: [Int] = []
        for i in 0..<planetsCount {
            let adjusted: Double
            switch i {
            case 0...2:
                adjusted = max(base - 1.0, 4)
            case 3...5:
                adjusted = base + 0.5
            default:
                adjusted = base + 1.0
            }
            distribution.append(max(Int(adjusted.rounded()), 3))
        }

        let total = distribution.reduce(0, +)
        let diff = remaining - total
        if diff != 0 {
            let lastIndex = planetsCount - 1
            distribution[lastIndex] = max(distribution[lastIndex] + diff, 3)
        }

        return distribution
    }

    static func foodsPerPlanet(for profile: ChildProfileModel) -> [Int] {
        let totalFoods = FoodDatabase.allFoods.count
        let preSelected = profile.safeFoodIds.count
        return calculateFoodsPerPlanet(totalFoods: totalFoods, preSelectedFoods: preSelected)
    }

    static func foodsRequiredForPlanet(_ planet: JourneyPlanet, distribution: [Int]) -> Int {
        guard planet.rawValue < distribution.count else { return 0 }
        var total = 0
        for i in 0..<planet.rawValue {
            total += distribution[i]
        }
        return total
    }

    static func foodsForPlanet(_ planet: JourneyPlanet, distribution: [Int]) -> Int {
        guard planet.rawValue < distribution.count else { return 5 }
        return distribution[planet.rawValue]
    }

    static func foodsCompletedInPlanet(_ planet: JourneyPlanet, totalExplored: Int, distribution: [Int]) -> Int {
        let required = foodsRequiredForPlanet(planet, distribution: distribution)
        let planetFoods = foodsForPlanet(planet, distribution: distribution)
        return min(max(totalExplored - required, 0), planetFoods)
    }

    static func isPlanetCompleted(_ planet: JourneyPlanet, totalExplored: Int, distribution: [Int]) -> Bool {
        foodsCompletedInPlanet(planet, totalExplored: totalExplored, distribution: distribution) >= foodsForPlanet(planet, distribution: distribution)
    }

    static func isPlanetLocked(_ planet: JourneyPlanet, totalExplored: Int, distribution: [Int]) -> Bool {
        totalExplored < foodsRequiredForPlanet(planet, distribution: distribution)
    }

    static func currentPlanet(for foodsExplored: Int, distribution: [Int]) -> JourneyPlanet {
        for planet in JourneyPlanet.allCases.reversed() {
            if foodsExplored >= foodsRequiredForPlanet(planet, distribution: distribution) {
                return planet
            }
        }
        return .baseCamp
    }

    static func currentSpaceInPlanet(_ planet: JourneyPlanet, totalExplored: Int, distribution: [Int]) -> Int {
        foodsCompletedInPlanet(planet, totalExplored: totalExplored, distribution: distribution)
    }
}
