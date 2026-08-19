import SwiftUI

struct SensoryProfileDashboardView: View {
    let sensoryProfile: SensoryProfile
    let insights: [String]
    let onExportPDF: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileSummaryCard
                insightsAndSuccessSection
                foodGroupDistributionCard
                colorVarietyCard
                textureChartSection
                flavorChartSection
                temperatureChartSection
                successZoneBadges
                avoidanceZoneCard
                exportButton
            }
            .padding(16)
        }
    }

    private var insightsAndSuccessSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Strengths & Growth Areas", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)

            if sensoryProfile.totalFoodsConsumed == 0 {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.secondary)
                    Text("Complete a few food quests to see personalized insights here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))
            } else {
                VStack(spacing: 10) {
                    if let strongest = sensoryProfile.textureAggregates.max(by: { $0.value.count < $1.value.count }) {
                        insightCard(
                            type: .strength,
                            title: "Strength: \(strongest.key.label) Textures",
                            text: "\(sensoryProfile.childName) has explored \(strongest.value.count) \(strongest.key.label.lowercased()) foods. This is a strong foundation — \(strongest.key.label.lowercased()) textures are a reliable comfort zone."
                        )
                    }

                    let unexploredFlavors = FoodFlavor.allCases.filter { (sensoryProfile.flavorAggregates[$0]?.count ?? 0) == 0 }
                    if !unexploredFlavors.isEmpty {
                        insightCard(
                            type: .growth,
                            title: "Growth Area: \(unexploredFlavors.map(\.label).joined(separator: " & "))",
                            text: "\(sensoryProfile.childName) hasn't explored \(unexploredFlavors.map(\.label).joined(separator: " or ").lowercased()) flavors yet. These are typically later-stage in SOS therapy. No rush — they'll come naturally as confidence builds."
                        )
                    }

                    if let challengeInsight = readyForInsight {
                        insightCard(
                            type: .challenge,
                            title: challengeInsight.title,
                            text: challengeInsight.text
                        )
                    }

                    progressionNote
                }
            }
        }
    }

    private enum InsightType {
        case strength, growth, challenge

        var color: Color {
            switch self {
            case .strength: .green
            case .growth: Color(red: 0.83, green: 0.69, blue: 0.22)
            case .challenge: .blue
            }
        }

        var icon: String {
            switch self {
            case .strength: "checkmark.seal.fill"
            case .growth: "leaf.fill"
            case .challenge: "flame.fill"
            }
        }
    }

    private func insightCard(type: InsightType, title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.caption)
                    .foregroundStyle(type.color)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(type.color)
            }
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var progressionNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.caption)
                .foregroundStyle(.blue)
            Text("\(sensoryProfile.childName) has tried \(sensoryProfile.totalFoodsConsumed) food\(sensoryProfile.totalFoodsConsumed == 1 ? "" : "s") in \(sensoryProfile.daysActive) day\(sensoryProfile.daysActive == 1 ? "" : "s"). Keep the momentum going!")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var profileSummaryCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    Text("🧬")
                        .font(.title)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(sensoryProfile.archetype)
                        .font(.headline)
                    Text("\(sensoryProfile.childName) has tried \(sensoryProfile.totalFoodsConsumed) foods over \(sensoryProfile.daysActive) days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if sensoryProfile.totalFoodsConsumed > 0 {
                HStack(spacing: 0) {
                    profileStat("Foods", "\(sensoryProfile.totalFoodsConsumed)", .green)
                    Divider().frame(height: 32)
                    profileStat("Days", "\(sensoryProfile.daysActive)", .blue)
                    Divider().frame(height: 32)
                    let confidence = Int(sensoryProfile.confidenceScore * 100)
                    profileStat("Confidence", "\(confidence)%", .orange)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func profileStat(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var foodGroupDistributionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Food Group Distribution", systemImage: "chart.bar.fill")
                .font(.headline)

            if sensoryProfile.totalFoodsConsumed == 0 {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.secondary)
                    Text("Start exploring foods to see group distribution.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))
            } else {
                let groupCounts = foodGroupCounts
                let total = max(groupCounts.values.reduce(0, +), 1)

                VStack(spacing: 10) {
                    ForEach(FoodGroup.allCases, id: \.self) { group in
                        let count = groupCounts[group] ?? 0
                        let pct = Double(count) / Double(total) * 100
                        HStack(spacing: 10) {
                            HStack(spacing: 4) {
                                Image(systemName: group.icon)
                                    .font(.caption2)
                                    .foregroundStyle(foodGroupColor(group))
                                Text(group.label)
                                    .font(.caption.weight(.medium))
                            }
                            .frame(width: 90, alignment: .leading)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.tertiarySystemFill))
                                        .frame(height: 10)
                                    Capsule()
                                        .fill(foodGroupColor(group))
                                        .frame(width: max(geo.size.width * pct / 100.0, count > 0 ? 4 : 0), height: 10)
                                }
                            }
                            .frame(height: 10)

                            Text("\(count)")
                                .font(.caption.bold())
                                .foregroundStyle(count > 0 ? foodGroupColor(group) : .secondary)
                                .frame(width: 24, alignment: .trailing)
                        }
                    }

                    let missingGroups = FoodGroup.allCases.filter { group in
                        group != .other && group != .mixed && (groupCounts[group] ?? 0) == 0
                    }
                    if !missingGroups.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text("Missing: \(missingGroups.map(\.label).joined(separator: ", "))")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.orange.opacity(0.06))
                        .clipShape(.rect(cornerRadius: 8))
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private var colorVarietyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Color Variety", systemImage: "paintpalette.fill")
                    .font(.headline)
                Spacer()
                let unlocked = colorUnlockedCount
                Text("\(unlocked)/\(FoodColor.allCases.count) colors")
                    .font(.caption.bold())
                    .foregroundStyle(unlocked >= 9 ? .green : .secondary)
            }

            let colorCounts = foodColorCounts
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 8)], spacing: 8) {
                ForEach(FoodColor.allCases, id: \.self) { color in
                    let count = colorCounts[color] ?? 0
                    let isUnlocked = count > 0
                    VStack(spacing: 4) {
                        Text(color.emoji)
                            .font(.title3)
                            .opacity(isUnlocked ? 1.0 : 0.25)
                        Text(color.label)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(isUnlocked ? .primary : .secondary)
                        if isUnlocked {
                            Text("\(count)")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.green)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isUnlocked ? Color.green.opacity(0.06) : Color(.tertiarySystemFill))
                    )
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))

            if colorUnlockedCount >= 7 {
                HStack(spacing: 8) {
                    Text("🌈")
                    Text(colorUnlockedCount >= 9 ? "Rainbow Master! All colors explored!" : "Almost a Rainbow Week! Keep going!")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.green)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.06))
                .clipShape(.rect(cornerRadius: 8))
            }
        }
    }

    private var readyForInsight: (title: String, text: String)? {
        guard sensoryProfile.totalFoodsConsumed > 0 else { return nil }
        let triedFoodIds = Set(sensoryProfile.successfulFoodIds)
        let allFoods = FoodDatabase.allFoods
        let candidates = allFoods.filter { !triedFoodIds.contains($0.id) }
        guard !candidates.isEmpty else { return nil }

        let topFlavor = sensoryProfile.flavorAggregates.max(by: { $0.value.count < $1.value.count })
        let nextTexture = FoodTexture.allCases.first(where: { (sensoryProfile.textureAggregates[$0]?.count ?? 0) == 0 })
            ?? sensoryProfile.textureAggregates.min(by: { $0.value.count < $1.value.count })?.key

        guard let flavor = topFlavor?.key, let texture = nextTexture else { return nil }

        let matchingFoods = candidates.filter { $0.texture == texture && $0.flavor == flavor }
        if !matchingFoods.isEmpty {
            let examples = matchingFoods.prefix(3).map(\.name).joined(separator: ", ")
            return (
                title: "Ready for: \(texture.label) + \(flavor.label)",
                text: "\(sensoryProfile.childName) is comfortable with \(flavor.label.lowercased()) flavors. Combining that with \(texture.label.lowercased()) textures could be a natural next step. Try: \(examples)"
            )
        }

        let partialMatches = candidates.filter { $0.texture == texture || $0.flavor == flavor }
        if let best = partialMatches.first {
            let attr = best.texture == texture ? texture.label : flavor.label
            return (
                title: "Ready for: \(best.texture.label) + \(best.flavor.label)",
                text: "\(sensoryProfile.childName) is familiar with \(attr.lowercased()). \(best.name) could be a great next step."
            )
        }

        return nil
    }

    private var foodGroupCounts: [FoodGroup: Int] {
        let allFoods = FoodDatabase.allFoods
        var counts: [FoodGroup: Int] = [:]
        for foodId in sensoryProfile.successfulFoodIds {
            if let food = allFoods.first(where: { $0.id == foodId }) {
                counts[food.foodGroup, default: 0] += 1
            }
        }
        return counts
    }

    private var foodColorCounts: [FoodColor: Int] {
        let allFoods = FoodDatabase.allFoods
        var counts: [FoodColor: Int] = [:]
        for foodId in sensoryProfile.successfulFoodIds {
            if let food = allFoods.first(where: { $0.id == foodId }) {
                counts[food.color, default: 0] += 1
            }
        }
        return counts
    }

    private var colorUnlockedCount: Int {
        foodColorCounts.filter { $0.value > 0 }.count
    }

    private func foodGroupColor(_ group: FoodGroup) -> Color {
        switch group {
        case .fruit: .pink
        case .vegetable: .green
        case .protein: .red
        case .grain: .orange
        case .dairy: .blue
        case .mixed: .purple
        case .other: .gray
        }
    }

    private var textureChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Texture Profile", systemImage: "hand.raised.fill")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(FoodTexture.allCases, id: \.self) { texture in
                    let agg = sensoryProfile.textureAggregates[texture]
                    SensoryBarRow(
                        label: texture.label,
                        count: agg?.count ?? 0,
                        percentage: agg?.percentage ?? 0,
                        isInSuccessZone: agg?.isInSuccessZone ?? false,
                        color: textureColor(texture)
                    )
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var flavorChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Flavor Profile", systemImage: "drop.fill")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(FoodFlavor.allCases, id: \.self) { flavor in
                    let agg = sensoryProfile.flavorAggregates[flavor]
                    SensoryBarRow(
                        label: flavor.label,
                        count: agg?.count ?? 0,
                        percentage: agg?.percentage ?? 0,
                        isInSuccessZone: agg?.isInSuccessZone ?? false,
                        color: flavorColor(flavor)
                    )
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var temperatureChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Temperature Profile", systemImage: "thermometer.medium")
                .font(.headline)

            VStack(spacing: 10) {
                ForEach(FoodTemperature.allCases, id: \.self) { temp in
                    let agg = sensoryProfile.temperatureAggregates[temp]
                    SensoryBarRow(
                        label: temp.label,
                        count: agg?.count ?? 0,
                        percentage: agg?.percentage ?? 0,
                        isInSuccessZone: agg?.isInSuccessZone ?? false,
                        color: tempColor(temp)
                    )
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var successZoneBadges: some View {
        Group {
            if !sensoryProfile.successZoneTextures.isEmpty || !sensoryProfile.successZoneFlavors.isEmpty || !sensoryProfile.successZoneTemperatures.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Success Zones", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundStyle(.green)

                    Text("Attributes where \(sensoryProfile.childName) is comfortable (3+ foods)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                        ForEach(sensoryProfile.successZoneTextures, id: \.self) { texture in
                            SuccessZonePill(label: texture.label, emoji: "🔴", color: textureColor(texture))
                        }
                        ForEach(sensoryProfile.successZoneFlavors, id: \.self) { flavor in
                            SuccessZonePill(label: flavor.label, emoji: "🟢", color: flavorColor(flavor))
                        }
                        ForEach(sensoryProfile.successZoneTemperatures, id: \.self) { temp in
                            SuccessZonePill(label: temp.label, emoji: "🌡", color: tempColor(temp))
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private var avoidanceZoneCard: some View {
        Group {
            if !sensoryProfile.avoidanceZoneTextures.isEmpty || !sensoryProfile.avoidanceZoneFlavors.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Challenge Zones", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(sensoryProfile.avoidanceZoneTextures, id: \.self) { texture in
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Text("\(texture.label) textures are challenging right now")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        ForEach(sensoryProfile.avoidanceZoneFlavors, id: \.self) { flavor in
                            HStack(spacing: 8) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Text("\(flavor.label) flavors need more time")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Text("Avoidance doesn't mean forever — sensory preferences develop with time and gentle exposure.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .italic()
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private var exportButton: some View {
        Button {
            onExportPDF()
        } label: {
            Label("Share progress summary", systemImage: "square.and.arrow.up")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue.opacity(0.12))
                .foregroundStyle(.blue)
                .clipShape(.rect(cornerRadius: 12))
        }
    }

    private func textureColor(_ texture: FoodTexture) -> Color {
        switch texture {
        case .crunchy: .orange
        case .soft: .blue
        case .mushy: .purple
        case .liquid: .cyan
        case .mixedTexture: .indigo
        }
    }

    private func flavorColor(_ flavor: FoodFlavor) -> Color {
        switch flavor {
        case .bland: .gray
        case .salty: .orange
        case .sweet: .pink
        case .sour: .yellow
        case .bitter: .green
        }
    }

    private func tempColor(_ temp: FoodTemperature) -> Color {
        switch temp {
        case .hot: .red
        case .roomTemp: .gray
        case .cold: .cyan
        }
    }
}

struct SensoryBarRow: View {
    let label: String
    let count: Int
    let percentage: Double
    let isInSuccessZone: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.caption.weight(.medium))
                .frame(width: 56, alignment: .leading)
                .foregroundStyle(isInSuccessZone ? .primary : .secondary)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 10)

                    Capsule()
                        .fill(isInSuccessZone ? color : color.opacity(0.3))
                        .frame(width: max(geo.size.width * percentage / 100.0, 4), height: 10)
                }
            }
            .frame(height: 10)

            Text("\(count)")
                .font(.caption.bold())
                .foregroundStyle(isInSuccessZone ? color : .secondary)
                .frame(width: 24, alignment: .trailing)
        }
    }
}

struct SuccessZonePill: View {
    let label: String
    let emoji: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.caption2)
            Text(label)
                .font(.caption2.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
}
