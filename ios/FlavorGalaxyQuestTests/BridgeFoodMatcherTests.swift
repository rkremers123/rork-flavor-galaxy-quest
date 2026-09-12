import Foundation
import Testing
@testable import FlavorGalaxyQuest

struct BridgeFoodMatcherTests {

    @Test func lickRanksBetweenSmellAndTaste() {
        #expect(BridgeFoodMatcher.ExposureState.licked.multiplier == 0.7)
        #expect(BridgeFoodMatcher.ExposureState.smelled.multiplier < BridgeFoodMatcher.ExposureState.licked.multiplier)
        #expect(BridgeFoodMatcher.ExposureState.licked.multiplier < BridgeFoodMatcher.ExposureState.tasted.multiplier)
        let (name, _) = BridgeFoodMatcher.getHighestState(["looked_at", "touched", "smelled", "licked"])
        #expect(name == "licked")
        let (alias, _) = BridgeFoodMatcher.getHighestState(["lick"])
        #expect(alias == "licked")
        #expect(BridgeFoodMatcher.trulyExploredStates.contains("licked"))
        #expect(!BridgeFoodMatcher.trulyExploredStates.contains("looked_at"))
    }

    @Test func noSafePickLeapWhenNothingInRange() {
        let cracker = FoodDatabase.food(byName: "Saltines")
        let blue = FoodDatabase.food(byName: "Blueberry")
        guard let cracker, let blue else { return }
        let recs = BridgeFoodMatcher.generateRecommendations(
            logs: [],
            superSafeFoods: [cracker.id],
            regularSafeFoods: [],
            foods: [cracker, blue],
            kidAllergens: [],
            extraExclude: [],
            today: Date()
        )
        #expect(!recs.contains { $0.rank == .safe })
    }

    @Test func glutenKidKeepsUntaggedRiceCakes() {
        guard let rice = FoodDatabase.food(byName: "Rice Cakes"),
              let bread = FoodDatabase.food(byName: "White Bread"),
              let chips = FoodDatabase.food(byName: "Potato Chips") else { return }
        let blocked = BridgeFoodMatcher.allergenBlockedIds(
            foodDB: [
                rice.id: BridgeFoodMatcher.SensoryVector.from(food: rice),
                bread.id: BridgeFoodMatcher.SensoryVector.from(food: bread),
                chips.id: BridgeFoodMatcher.SensoryVector.from(food: chips),
            ],
            kidAllergens: BridgeFoodMatcher.allergenTokens([.gluten])
        )
        #expect(blocked.contains(bread.id))
        #expect(!blocked.contains(rice.id))
        #expect(!blocked.contains(chips.id))
    }

    @Test func explanationNamesAChange() {
        let a = FoodDatabase.food(byName: "Potato Chips")!
        let b = FoodDatabase.food(byName: "Cheez-Its")!
        let msg = BridgeFoodMatcher.explainBridge(
            baseline: BridgeFoodMatcher.SensoryVector.from(food: a),
            profile: BridgeFoodMatcher.SensoryVector.from(food: b),
            rank: "Safe Pick"
        ).lowercased()
        #expect(!msg.contains("new adventure"))
        #expect(!msg.contains("high chance of success"))
        let sensory = ["crunch", "salt", "sweet", "soft", "color", "mouthfeel", "cheez"]
        #expect(sensory.contains { msg.contains($0) })
    }

    @Test func beige20PresentAndTagged() {
        for name in FoodDatabase.beige20Names {
            #expect(FoodDatabase.food(byName: name) != nil, "missing \(name)")
        }
        #expect(FoodDatabase.food(byName: "Rice Cakes")?.allergens.contains(.gluten) == false)
        #expect(FoodDatabase.food(byName: "Potato Chips")?.allergens.contains(.gluten) == false)
        #expect(FoodDatabase.food(byName: "Cheez-Its")?.allergens.contains(.gluten) == true)
        #expect(FoodDatabase.food(byName: "Cheez-Its")?.allergens.contains(.dairy) == true)
        #expect(FoodDatabase.food(byName: "French Toast")?.allergens.isSuperset(of: [.gluten, .egg, .dairy]) == true)
        #expect(FoodDatabase.food(byName: "Hard-Boiled Egg")?.allergens.contains(.egg) == true)
    }
}
