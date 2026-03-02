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

                    if let topFlavor = sensoryProfile.flavorAggregates.max(by: { $0.value.count < $1.value.count }),
                       let nextTexture = FoodTexture.allCases.first(where: { (sensoryProfile.textureAggregates[$0]?.count ?? 0) == 0 }) ?? sensoryProfile.textureAggregates.min(by: { $0.value.count < $1.value.count })?.key {
                        insightCard(
                            type: .challenge,
                            title: "Ready for: \(nextTexture.label) + \(topFlavor.key.label)",
                            text: "\(sensoryProfile.childName) is comfortable with \(topFlavor.key.label.lowercased()) flavors. Combining that with \(nextTexture.label.lowercased()) textures could be a natural next step."
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
            Label("Share with Therapist", systemImage: "square.and.arrow.up")
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
