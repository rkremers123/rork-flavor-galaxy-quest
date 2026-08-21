import Foundation

/// Faithful Swift port of bridge_food_algorithm_v3_repaired.py (passes 1–5).
/// Public generateRecommendations stays compatible with the iOS rec / quest paths.
nonisolated enum BridgeFoodMatcher {

    // MARK: - Exposure

    enum ExposureState: String, Sendable {
        case lookedAt = "looked_at"
        case touched = "touched"
        case smelled = "smelled"
        case licked = "licked"
        case tasted = "tasted"
        case ate = "ate"

        var multiplier: Double {
            switch self {
            case .lookedAt: 0.3
            case .touched: 0.5
            case .smelled: 0.6
            case .licked: 0.7
            case .tasted: 0.8
            case .ate: 1.0
            }
        }
    }

    static let trulyExploredStates: Set<String> = ["touched", "smelled", "licked", "tasted", "ate"]

    // MARK: - Profiles

    struct SensoryVector: Sendable, Equatable {
        var texture: Double
        var flavorSweet: Double
        var flavorSalty: Double
        var flavorSavory: Double
        var flavorSour: Double
        var flavorBitter: Double
        var temperature: Double
        var color: String
        var mouthfeel: String
        var prepMethod: String
        var foodGroup: String
        var allergens: Set<String>

        func toVector() -> [Double] {
            [texture, flavorSweet, flavorSalty, flavorSavory, flavorSour, flavorBitter, temperature / 10.0]
        }

        static func from(food: FoodItem) -> SensoryVector {
            SensoryVector(
                texture: food.textureScore,
                flavorSweet: food.flavorSweet,
                flavorSalty: food.flavorSalty,
                flavorSavory: food.flavorSavory,
                flavorSour: food.flavorSour,
                flavorBitter: food.flavorBitter,
                temperature: food.temperatureCelsius,
                color: food.color.matcherValue,
                mouthfeel: food.mouthfeel.rawValue,
                prepMethod: food.prepMethod.rawValue,
                foodGroup: food.foodGroup.matcherValue,
                allergens: allergenTokens(food.allergens)
            )
        }
    }

    struct FoodLog: Sendable {
        let foodId: UUID
        let timestamp: Date
        let exposureStates: [String]
    }

    struct FoodProfile: Sendable {
        let foodId: UUID
        let highestState: String
        let highestStateMultiplier: Double
        let mostRecentDate: Date
        let lastSuccessfulState: String

        func weight(today: Date, numExplored: Int, isSuperSafe: Bool, isRegularSafe: Bool) -> Double {
            var stateMult = highestStateMultiplier
            let recency = recencyWeight(daysAgo: max(0, Calendar.current.dateComponents([.day], from: mostRecentDate, to: today).day ?? 0))
            if isSuperSafe {
                stateMult = 0.60 / (1 + log(max(1.0, Double(numExplored))))
            } else if isRegularSafe {
                stateMult = 0.40 / (1 + log(max(1.0, Double(numExplored))))
            }
            let regression = lastSuccessfulState != highestState ? 0.8 : 1.0
            return stateMult * recency * regression
        }
    }

    struct Pick: Sendable {
        let rank: Rank
        let foodId: UUID
        let foodName: String
        let distance: Double
        let explanation: String
    }

    enum Rank: String, Sendable {
        case safe = "Safe Pick"
        case stretch = "Stretch Pick"
        case variety = "Variety Pick"
    }

    // MARK: - Weights (raw, then renormalize to 1.0)

    static let rawDistanceWeights: [String: Double] = [
        "texture": 0.15,
        "flavor_sweet": 0.08,
        "flavor_salty": 0.12,
        "flavor_savory": 0.08,
        "flavor_sour": 0.05,
        "flavor_bitter": 0.08,
        "temperature": 0.10,
        "color": 0.10,
        "mouthfeel": 0.14,
        "prep_method": 0.10,
    ]

    static let distanceWeights: [String: Double] = {
        let total = rawDistanceWeights.values.reduce(0, +)
        return rawDistanceWeights.mapValues { $0 / total }
    }()

    static let dimensionNames = [
        "texture", "flavor_sweet", "flavor_salty", "flavor_savory",
        "flavor_sour", "flavor_bitter", "temperature",
    ]
    static let categoricalFields = ["color", "mouthfeel", "prep_method"]
    static let unknownCategorical: Set<String> = ["", "mixed", "unknown"]
    static let categoricalMismatch = 3.0
    static let categoricalHalf = 1.5

    static let safePickMax = 2.5
    static let stretchPickMin = 2.5
    static let stretchPickMax = 4.5
    static let varietyPickMax = 4.5
    static let minFoodsForTrend = 5
    static let trendStrengthThreshold = 5.0 / 7.0
    static let trendDistanceBonus = 0.3
    static let bigDimDelta = 1.5

    // MARK: - Allergens

    /// Ingredient tags only. gluten ↔ wheat alias so a gluten kid is not aisle-banned.
    static func allergenTokens(_ allergens: Set<Allergen>) -> Set<String> {
        var tokens = Set(allergens.map(\.rawValue))
        if tokens.contains("gluten") { tokens.insert("wheat") }
        if tokens.contains("wheat") { tokens.insert("gluten") }
        return tokens
    }

    // MARK: - Distance

    static func recencyWeight(daysAgo: Int) -> Double {
        if daysAgo <= 3 { return 1.0 }
        if daysAgo <= 7 { return 0.75 }
        if daysAgo <= 14 { return 0.50 }
        if daysAgo <= 30 { return 0.25 }
        return 0.10
    }

    static func catNorm(_ value: String?) -> String {
        (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func isUnknownCat(_ value: String?) -> Bool {
        unknownCategorical.contains(catNorm(value))
    }

    static func categoricalPenalty(_ a: String?, _ b: String?) -> Double {
        if isUnknownCat(a) || isUnknownCat(b) { return categoricalHalf }
        if catNorm(a) == catNorm(b) { return 0 }
        return categoricalMismatch
    }

    static func calculateDistance(_ a: SensoryVector, _ b: SensoryVector) -> Double {
        let v1 = a.toVector()
        let v2 = b.toVector()
        var distanceSq = 0.0
        for (i, name) in dimensionNames.enumerated() {
            let diff = v1[i] - v2[i]
            distanceSq += (distanceWeights[name] ?? 0) * diff * diff
        }
        let cats = [
            ("color", a.color, b.color),
            ("mouthfeel", a.mouthfeel, b.mouthfeel),
            ("prep_method", a.prepMethod, b.prepMethod),
        ]
        for (field, av, bv) in cats {
            let penalty = categoricalPenalty(av, bv)
            distanceSq += (distanceWeights[field] ?? 0) * penalty * penalty
        }
        return sqrt(distanceSq)
    }

    static func getHighestState(_ stateNames: [String]) -> (String, Double) {
        let order: [String: ExposureState] = [
            "looked_at": .lookedAt,
            "look": .lookedAt,
            "looking": .lookedAt,
            "touched": .touched,
            "touch": .touched,
            "smelled": .smelled,
            "smell": .smelled,
            "licked": .licked,
            "lick": .licked,
            "tasted": .tasted,
            "taste": .tasted,
            "ate": .ate,
            "eaten": .ate,
            "swallowed": .ate,
        ]
        var highest: ExposureState?
        for name in stateNames {
            guard let state = order[name] else { continue }
            if highest == nil || state.multiplier > highest!.multiplier {
                highest = state
            }
        }
        let resolved = highest ?? .lookedAt
        return (resolved.rawValue, resolved.multiplier)
    }

    static func safeScaling(isSuperSafe: Bool, isRegularSafe: Bool, numExplored: Int) -> Double? {
        let denom = 1 + log(max(1.0, Double(numExplored)))
        if isSuperSafe { return 0.60 / denom }
        if isRegularSafe { return 0.40 / denom }
        return nil
    }

    // MARK: - Logs → profiles

    static func aggregateFoodLogs(_ allLogs: [FoodLog]) -> [UUID: FoodProfile] {
        var byFood: [UUID: [FoodLog]] = [:]
        for log in allLogs {
            byFood[log.foodId, default: []].append(log)
        }
        var profiles: [UUID: FoodProfile] = [:]
        for (foodId, logs) in byFood {
            let sortedLogs = logs.sorted { $0.timestamp < $1.timestamp }
            let allStates = sortedLogs.flatMap(\.exposureStates)
            let (highest, mult) = getHighestState(allStates)
            let last3 = Array(sortedLogs.suffix(3))
            let (lastSuccess, _) = getHighestState(last3.flatMap(\.exposureStates))
            profiles[foodId] = FoodProfile(
                foodId: foodId,
                highestState: highest,
                highestStateMultiplier: mult,
                mostRecentDate: sortedLogs.last?.timestamp ?? Date.distantPast,
                lastSuccessfulState: lastSuccess
            )
        }
        return profiles
    }

    static func weightForSafeFood(
        foodId: UUID,
        foodProfiles: [UUID: FoodProfile],
        today: Date,
        numExplored: Int,
        isSuperSafe: Bool,
        isRegularSafe: Bool
    ) -> Double {
        if let profile = foodProfiles[foodId] {
            return profile.weight(today: today, numExplored: numExplored, isSuperSafe: isSuperSafe, isRegularSafe: isRegularSafe)
        }
        return safeScaling(isSuperSafe: isSuperSafe, isRegularSafe: isRegularSafe, numExplored: numExplored) ?? 0
    }

    static func calculateWeightedBaseline(
        foodProfiles: [UUID: FoodProfile],
        superSafeFoods: Set<UUID>,
        regularSafeFoods: Set<UUID>,
        foodDB: [UUID: SensoryVector],
        today: Date,
        numTrulyExplored: Int
    ) -> SensoryVector {
        var totalWeight = 0.0
        var weighted = [Double](repeating: 0, count: 7)

        func accumulate(_ foodId: UUID, _ weight: Double) {
            guard let profile = foodDB[foodId], weight > 0 else { return }
            let vector = profile.toVector()
            for i in 0..<7 { weighted[i] += vector[i] * weight }
            totalWeight += weight
        }

        for foodId in superSafeFoods {
            accumulate(foodId, weightForSafeFood(foodId: foodId, foodProfiles: foodProfiles, today: today, numExplored: numTrulyExplored, isSuperSafe: true, isRegularSafe: false))
        }
        for foodId in regularSafeFoods where !superSafeFoods.contains(foodId) {
            accumulate(foodId, weightForSafeFood(foodId: foodId, foodProfiles: foodProfiles, today: today, numExplored: numTrulyExplored, isSuperSafe: false, isRegularSafe: true))
        }
        for (foodId, profile) in foodProfiles {
            if superSafeFoods.contains(foodId) || regularSafeFoods.contains(foodId) { continue }
            accumulate(foodId, profile.weight(today: today, numExplored: numTrulyExplored, isSuperSafe: false, isRegularSafe: false))
        }

        if totalWeight > 0 {
            weighted = weighted.map { $0 / totalWeight }
        }

        return SensoryVector(
            texture: weighted[0],
            flavorSweet: weighted[1],
            flavorSalty: weighted[2],
            flavorSavory: weighted[3],
            flavorSour: weighted[4],
            flavorBitter: weighted[5],
            temperature: weighted[6] * 10,
            color: "mixed",
            mouthfeel: "mixed",
            prepMethod: "mixed",
            foodGroup: "",
            allergens: []
        )
    }

    // MARK: - Trend / exclusion

    static func deduplicateLastNLogs(_ allLogs: [FoodLog], n: Int = 7) -> [UUID] {
        let recent = allLogs.sorted { $0.timestamp > $1.timestamp }.prefix(n)
        var seen: [UUID: UUID] = [:]
        var order: [UUID] = []
        for log in recent {
            if seen[log.foodId] == nil {
                seen[log.foodId] = log.foodId
                order.append(log.foodId)
            }
        }
        return order
    }

    static func getRecentUniqueFoods(_ allLogs: [FoodLog], n: Int = 7) -> [UUID] {
        var latest: [UUID: Date] = [:]
        for log in allLogs {
            if latest[log.foodId] == nil || log.timestamp > latest[log.foodId]! {
                latest[log.foodId] = log.timestamp
            }
        }
        return latest.sorted { $0.value > $1.value }.prefix(n).map(\.key)
    }

    static func catalogMedians(_ foodDB: [UUID: SensoryVector]) -> [String: Double] {
        let vectors = foodDB.values.map { $0.toVector() }
        guard !vectors.isEmpty else {
            return Dictionary(uniqueKeysWithValues: dimensionNames.map { ($0, 0.0) })
        }
        var medians: [String: Double] = [:]
        let n = vectors.count
        for (i, name) in dimensionNames.enumerated() {
            let vals = vectors.map { $0[i] }.sorted()
            if n % 2 == 1 {
                medians[name] = vals[n / 2]
            } else {
                medians[name] = (vals[n / 2 - 1] + vals[n / 2]) / 2.0
            }
        }
        return medians
    }

    static func detectTrend(uniqueRecentFoods: [UUID], foodDB: [UUID: SensoryVector]) -> [String: Double]? {
        let profiles = uniqueRecentFoods.compactMap { foodDB[$0] }
        guard profiles.count >= minFoodsForTrend else { return nil }
        let medians = catalogMedians(foodDB)
        let n = Double(profiles.count)
        var trend: [String: Double] = [:]
        for (i, name) in dimensionNames.enumerated() {
            let above = profiles.filter { $0.toVector()[i] > (medians[name] ?? 0) }.count
            let strength = Double(above) / n
            if strength >= trendStrengthThreshold {
                trend[name] = strength
            }
        }
        return trend.isEmpty ? nil : trend
    }

    // MARK: - Why copy

    static func textureKind(_ value: Double) -> String {
        if value <= 4.0 { return "soft" }
        if value >= 6.0 { return "crunch" }
        return "mid"
    }

    static func sameAxisCandidates(baseline: SensoryVector, profile: SensoryVector) -> [(Double, String)] {
        var out: [(Double, String)] = []
        let texDelta = abs(profile.texture - baseline.texture)
        let bk = textureKind(baseline.texture)
        let pk = textureKind(profile.texture)
        if texDelta < 1.2 && bk == pk {
            if pk == "crunch" { out.append((10.0 - texDelta, "Same crunch")) }
            else if pk == "soft" { out.append((10.0 - texDelta, "Same soft feel")) }
            else { out.append((6.0 - texDelta, "Similar texture")) }
        }

        let flavors: [(KeyPath<SensoryVector, Double>, String)] = [
            (\.flavorSalty, "salt"),
            (\.flavorSweet, "sweet"),
            (\.flavorSavory, "savory"),
            (\.flavorSour, "sour"),
            (\.flavorBitter, "bitter"),
        ]
        for (key, noun) in flavors {
            let bv = baseline[keyPath: key]
            let pv = profile[keyPath: key]
            let d = abs(pv - bv)
            if d < 0.8 && max(bv, pv) >= 2.5 {
                out.append((5.0 + max(bv, pv) - d, "Same \(noun)"))
            }
        }

        let tdelta = abs(profile.temperature - baseline.temperature) / 10.0
        if tdelta < 0.8 { out.append((3.0 - tdelta, "Same temperature")) }

        for (field, label) in [("color", "color"), ("mouthfeel", "mouthfeel"), ("prep_method", "prep")] {
            let bv = catNorm(field == "color" ? baseline.color : field == "mouthfeel" ? baseline.mouthfeel : baseline.prepMethod)
            let pv = catNorm(field == "color" ? profile.color : field == "mouthfeel" ? profile.mouthfeel : profile.prepMethod)
            if !isUnknownCat(bv) && !isUnknownCat(pv) && bv == pv {
                if field == "color" { out.append((4.5, "Same \(pv) color")) }
                else if field == "mouthfeel" { out.append((5.5, "Same \(pv) mouthfeel")) }
                else { out.append((4.0, "Same \(pv) prep")) }
            }
            _ = label
        }
        return out
    }

    static func diffAxisCandidates(baseline: SensoryVector, profile: SensoryVector) -> [(Double, String)] {
        var out: [(Double, String)] = []
        let texDelta = abs(profile.texture - baseline.texture)
        let pk = textureKind(profile.texture)
        if texDelta >= 1.2 {
            let phrase: String
            if profile.texture > baseline.texture {
                phrase = pk == "crunch" ? "more crunch" : "a firmer bite"
            } else {
                phrase = pk == "soft" ? "softer" : "a little softer"
            }
            out.append((texDelta, phrase))
        }

        let flavors: [(KeyPath<SensoryVector, Double>, String, String)] = [
            (\.flavorSalty, "saltier", "less salty"),
            (\.flavorSweet, "sweeter", "less sweet"),
            (\.flavorSavory, "more savory", "less savory"),
            (\.flavorSour, "more sour", "less sour"),
            (\.flavorBitter, "more bitter", "less bitter"),
        ]
        for (key, up, down) in flavors {
            let bv = baseline[keyPath: key]
            let pv = profile[keyPath: key]
            let d = abs(pv - bv)
            if d < 0.8 { continue }
            let qualifier = d < 2.0 ? "a little " : ""
            out.append((d, "\(qualifier)\(pv > bv ? up : down)"))
        }

        let tdelta = abs(profile.temperature - baseline.temperature) / 10.0
        if tdelta >= 0.8 {
            var phrase = profile.temperature > baseline.temperature ? "warmer" : "cooler"
            if tdelta < 2.0 { phrase = "a little \(phrase)" }
            out.append((tdelta, phrase))
        }

        for field in ["color", "mouthfeel", "prep_method"] {
            let bv = field == "color" ? baseline.color : field == "mouthfeel" ? baseline.mouthfeel : baseline.prepMethod
            let pv = field == "color" ? profile.color : field == "mouthfeel" ? profile.mouthfeel : profile.prepMethod
            if isUnknownCat(pv) { continue }
            let pvN = catNorm(pv)
            if !isUnknownCat(bv) && catNorm(bv) == pvN { continue }
            let penalty = categoricalPenalty(bv, pv)
            let phrase: String
            if field == "color" { phrase = "a \(pvN) color" }
            else if field == "mouthfeel" { phrase = "\(pvN) mouthfeel" }
            else { phrase = "\(pvN) this time" }
            out.append((penalty, phrase))
        }
        return out
    }

    static func explainBridge(baseline: SensoryVector, profile: SensoryVector, rank: String) -> String {
        _ = rank
        var same = sameAxisCandidates(baseline: baseline, profile: profile)
        var diff = diffAxisCandidates(baseline: baseline, profile: profile)
        same.sort { $0.0 > $1.0 }
        diff.sort { $0.0 > $1.0 }
        let samePhrase = same.first?.1
        let diffPhrase = diff.first?.1
        if let s = samePhrase, let d = diffPhrase { return "\(s), \(d)." }
        if let s = samePhrase { return "\(s)." }
        if let d = diffPhrase {
            let capitalized = d.prefix(1).uppercased() + d.dropFirst()
            return "\(capitalized)."
        }
        return "Close to the usual flavors and feel."
    }

    // MARK: - Picks

    static func numBigDimensionChanges(baseline: SensoryVector, profile: SensoryVector) -> Int {
        zip(baseline.toVector(), profile.toVector()).filter { abs($0.0 - $0.1) > bigDimDelta }.count
    }

    static func highOnTrendingDimension(profile: SensoryVector, trend: [String: Double]?, medians: [String: Double]) -> Bool {
        guard let trend, !trend.isEmpty else { return false }
        let vec = profile.toVector()
        for (i, name) in dimensionNames.enumerated() {
            if trend[name] != nil && vec[i] > (medians[name] ?? 0) { return true }
        }
        return false
    }

    static func findMissingGroups(
        foodDB: [UUID: SensoryVector],
        superSafeFoods: Set<UUID>,
        regularSafeFoods: Set<UUID>,
        loggedFoodIds: Set<UUID>
    ) -> [String] {
        let known = Set(foodDB.values.compactMap { $0.foodGroup.isEmpty ? nil : $0.foodGroup })
        var present: Set<String> = []
        for fid in superSafeFoods.union(regularSafeFoods).union(loggedFoodIds) {
            if let g = foodDB[fid]?.foodGroup, !g.isEmpty { present.insert(g) }
        }
        return known.subtracting(present).sorted()
    }

    static func findSafePick(baseline: SensoryVector, foodDB: [UUID: SensoryVector], exclude: Set<UUID>) -> (UUID, Double)? {
        var best: UUID?
        var bestD = Double.infinity
        for (fid, profile) in foodDB {
            if exclude.contains(fid) { continue }
            let d = calculateDistance(baseline, profile)
            if d <= safePickMax && d < bestD {
                best = fid
                bestD = d
            }
        }
        return best.map { ($0, bestD) }
    }

    static func findStretchPick(
        baseline: SensoryVector,
        foodDB: [UUID: SensoryVector],
        exclude: Set<UUID>,
        trend: [String: Double]?,
        medians: [String: Double]
    ) -> (UUID, Double)? {
        var best: UUID?
        var bestRaw: Double?
        var bestKey: (Double, Int)?
        for (fid, profile) in foodDB {
            if exclude.contains(fid) { continue }
            let d = calculateDistance(baseline, profile)
            guard d >= stretchPickMin && d <= stretchPickMax else { continue }
            var ranking = d
            if highOnTrendingDimension(profile: profile, trend: trend, medians: medians) {
                ranking = d - trendDistanceBonus
            }
            let nBig = numBigDimensionChanges(baseline: baseline, profile: profile)
            let key = (ranking, nBig)
            if bestKey == nil || key.0 < bestKey!.0 || (key.0 == bestKey!.0 && key.1 < bestKey!.1) {
                bestKey = key
                best = fid
                bestRaw = d
            }
        }
        guard let best, let bestRaw else { return nil }
        return (best, bestRaw)
    }

    static func findVarietyPick(
        baseline: SensoryVector,
        foodDB: [UUID: SensoryVector],
        exclude: Set<UUID>,
        missingGroups: [String]
    ) -> (UUID, Double)? {
        guard !missingGroups.isEmpty else { return nil }
        let missing = Set(missingGroups)
        var best: UUID?
        var bestD = Double.infinity
        for (fid, profile) in foodDB {
            if exclude.contains(fid) { continue }
            if !missing.contains(profile.foodGroup) { continue }
            let d = calculateDistance(baseline, profile)
            if d <= varietyPickMax && d < bestD {
                best = fid
                bestD = d
            }
        }
        return best.map { ($0, bestD) }
    }

    static func allergenBlockedIds(foodDB: [UUID: SensoryVector], kidAllergens: Set<String>) -> Set<UUID> {
        guard !kidAllergens.isEmpty else { return [] }
        var blocked: Set<UUID> = []
        for (fid, profile) in foodDB {
            if !kidAllergens.isDisjoint(with: profile.allergens) {
                blocked.insert(fid)
            }
        }
        return blocked
    }

    // MARK: - Public API

    static func generateRecommendations(
        logs: [FoodLog],
        superSafeFoods: Set<UUID>,
        regularSafeFoods: Set<UUID>,
        foods: [FoodItem],
        kidAllergens: Set<Allergen>,
        extraExclude: Set<UUID> = [],
        today: Date = Date()
    ) -> [Pick] {
        let foodDB = Dictionary(uniqueKeysWithValues: foods.map { ($0.id, SensoryVector.from(food: $0)) })
        let names = Dictionary(uniqueKeysWithValues: foods.map { ($0.id, $0.name) })
        let foodProfiles = aggregateFoodLogs(logs)

        let numTrulyExplored = foodProfiles.filter { fid, fp in
            !superSafeFoods.contains(fid)
                && !regularSafeFoods.contains(fid)
                && trulyExploredStates.contains(fp.highestState)
        }.count

        let baseline = calculateWeightedBaseline(
            foodProfiles: foodProfiles,
            superSafeFoods: superSafeFoods,
            regularSafeFoods: regularSafeFoods,
            foodDB: foodDB,
            today: today,
            numTrulyExplored: numTrulyExplored
        )

        let recentFoodIds = Set(deduplicateLastNLogs(logs))
        let kidTokens = allergenTokens(kidAllergens)
        var exclude = recentFoodIds
            .union(superSafeFoods)
            .union(regularSafeFoods)
            .union(allergenBlockedIds(foodDB: foodDB, kidAllergens: kidTokens))
            .union(extraExclude)

        let uniqueRecent = getRecentUniqueFoods(logs, n: 7)
        let trend = detectTrend(uniqueRecentFoods: uniqueRecent, foodDB: foodDB)
        let medians = catalogMedians(foodDB)

        var recs: [Pick] = []

        if let (fid, distance) = findSafePick(baseline: baseline, foodDB: foodDB, exclude: exclude),
           let profile = foodDB[fid] {
            recs.append(Pick(
                rank: .safe,
                foodId: fid,
                foodName: names[fid] ?? fid.uuidString,
                distance: distance,
                explanation: explainBridge(baseline: baseline, profile: profile, rank: Rank.safe.rawValue)
            ))
            exclude.insert(fid)
        }

        if let (fid, distance) = findStretchPick(baseline: baseline, foodDB: foodDB, exclude: exclude, trend: trend, medians: medians),
           let profile = foodDB[fid] {
            recs.append(Pick(
                rank: .stretch,
                foodId: fid,
                foodName: names[fid] ?? fid.uuidString,
                distance: distance,
                explanation: explainBridge(baseline: baseline, profile: profile, rank: Rank.stretch.rawValue)
            ))
            exclude.insert(fid)
        }

        let loggedIds = Set(foodProfiles.keys)
        let missing = findMissingGroups(
            foodDB: foodDB,
            superSafeFoods: superSafeFoods,
            regularSafeFoods: regularSafeFoods,
            loggedFoodIds: loggedIds
        )
        if let (fid, distance) = findVarietyPick(baseline: baseline, foodDB: foodDB, exclude: exclude, missingGroups: missing),
           let profile = foodDB[fid] {
            recs.append(Pick(
                rank: .variety,
                foodId: fid,
                foodName: names[fid] ?? fid.uuidString,
                distance: distance,
                explanation: explainBridge(baseline: baseline, profile: profile, rank: Rank.variety.rawValue)
            ))
        }

        return recs
    }
}
