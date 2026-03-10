import SwiftUI

struct SmartRecommendationsView: View {
    let recommendations: [FoodRecommendation]
    let childName: String
    let onStartQuest: (FoodItem) -> Void
    let onRefresh: () -> Void

    @State private var filterByConfidence: Bool = false
    @State private var expandedId: UUID?
    @State private var showBridgeEducation: Bool = false
    @State private var sortMode: RecommendationSortMode = .tier

    private var filteredRecommendations: [FoodRecommendation] {
        if filterByConfidence {
            return recommendations.filter { $0.confidenceScore >= 40 }
        }
        return recommendations
    }

    private var groupedByTier: [(RecommendationTier, [FoodRecommendation])] {
        var grouped: [RecommendationTier: [FoodRecommendation]] = [:]
        for rec in filteredRecommendations {
            grouped[rec.tier, default: []].append(rec)
        }
        return RecommendationTier.allCases.compactMap { tier in
            guard let items = grouped[tier], !items.isEmpty else { return nil }
            return (tier, items)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                if recommendations.isEmpty {
                    emptyState
                } else {
                    bridgeFoodEducationBox
                    tryNextSection
                    filterToggle
                    sortPicker
                    switch sortMode {
                    case .tier:
                        ForEach(groupedByTier, id: \.0) { tier, items in
                            tierSection(tier: tier, items: items)
                        }
                    case .texture:
                        ForEach(groupedByTexture, id: \.0) { texture, items in
                            attributeSection(title: texture.label, icon: "hand.raised.fill", color: textureGroupColor(texture), items: items)
                        }
                    case .flavor:
                        ForEach(groupedByFlavor, id: \.0) { flavor, items in
                            attributeSection(title: flavor.label, icon: "drop.fill", color: flavorGroupColor(flavor), items: items)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private var bridgeFoodEducationBox: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    showBridgeEducation.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.callout)
                        .foregroundStyle(.blue)
                    Text("What are bridge foods?")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                    Spacer()
                    Image(systemName: showBridgeEducation ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.blue.opacity(0.6))
                }
                .padding(14)
            }

            if showBridgeEducation {
                Text("Bridge foods share similar textures and flavors to foods \(childName) already enjoys. They're designed to help expand their diet naturally, without overwhelming their sensory preferences.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.blue.opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Smart Recommendations", systemImage: "brain.head.profile.fill")
                    .font(.headline)
                Spacer()
                Button {
                    onRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.blue)
                }
            }
            Text("Personalized food suggestions based on \(childName)'s sensory profile")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var filterToggle: some View {
        HStack {
            Toggle(isOn: $filterByConfidence) {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.caption)
                    Text("High confidence only")
                        .font(.caption.weight(.medium))
                }
            }
            .toggleStyle(.switch)
            .tint(.blue)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
    }

    private func tierSection(tier: RecommendationTier, items: [FoodRecommendation]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: tier.icon)
                    .font(.callout)
                    .foregroundStyle(tierColor(tier))
                Text(tier.label)
                    .font(.subheadline.weight(.semibold))
                Text("(\(items.count))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(items.prefix(8)) { rec in
                    recommendationRow(rec, tier: tier)
                    if rec.id != items.prefix(8).last?.id {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private func recommendationRow(_ rec: FoodRecommendation, tier: RecommendationTier) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    expandedId = expandedId == rec.id ? nil : rec.id
                }
            } label: {
                HStack(spacing: 12) {
                    Text(rec.food.emoji)
                        .font(.title3)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(rec.food.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)

                            Text(rec.food.color.emoji)
                                .font(.caption2)

                            Text(rec.food.foodGroup.label)
                                .font(.system(.caption2, weight: .bold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(Capsule().fill(Color(.tertiarySystemFill)))
                        }

                        Text("\(rec.food.texture.label) · \(rec.food.flavor.label) · \(rec.food.temperature.label)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    riskBadge(for: rec)

                    Image(systemName: expandedId == rec.id ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }

            if expandedId == rec.id {
                VStack(alignment: .leading, spacing: 10) {
                    Text(rec.explanation)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !rec.matchingAttributes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(.green)
                            Text("Familiar: \(rec.matchingAttributes.joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if !rec.newAttributes.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("New: \(rec.newAttributes.joined(separator: ", "))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 12) {
                        ScorePill(label: "Match", value: rec.matchScore, color: .green)
                        ScorePill(label: "Bridge", value: rec.bridgeScore, color: .blue)
                        ScorePill(label: "Confidence", value: rec.confidenceScore, color: .orange)
                    }

                    Button {
                        onStartQuest(rec.food)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.fill")
                                .font(.caption)
                            Text("Start Quest")
                                .font(.caption.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(tierColor(tier).opacity(0.12))
                        .foregroundStyle(tierColor(tier))
                        .clipShape(.rect(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func riskBadge(for rec: FoodRecommendation) -> some View {
        let risk: (String, Color) = {
            switch rec.tier {
            case .perfectMatch: ("LOW", .green)
            case .greatMatch: ("LOW", .green)
            case .goodChallenge: ("MED", .orange)
            case .expertChallenge: ("HIGH", .red)
            }
        }()
        return Text(risk.0)
            .font(.system(.caption2, weight: .bold))
            .foregroundStyle(risk.1)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(risk.1.opacity(0.12)))
    }

    private var tryNextSection: some View {
        Group {
            let topRecs = Array(filteredRecommendations.prefix(3))
            if !topRecs.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.callout)
                            .foregroundStyle(.yellow)
                        Text("Try Next")
                            .font(.subheadline.weight(.bold))
                    }

                    VStack(spacing: 0) {
                        ForEach(Array(topRecs.enumerated()), id: \.element.id) { index, rec in
                            HStack(spacing: 12) {
                                Text("#\(index + 1)")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                    .frame(width: 24)

                                Text(rec.food.emoji)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 4) {
                                        Text(rec.food.name)
                                            .font(.subheadline.weight(.semibold))
                                        Text(rec.food.color.emoji)
                                            .font(.caption2)
                                        Text(rec.food.foodGroup.label)
                                            .font(.system(.caption2, weight: .medium))
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(rec.explanation)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer()

                                riskBadge(for: rec)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)

                            if index < topRecs.count - 1 {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 14))
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Complete a few food quests to unlock recommendations")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text("\(childName) needs to try at least 3 foods before we can generate personalized suggestions.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var sortPicker: some View {
        HStack(spacing: 6) {
            Text("Sort by")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            Picker("", selection: $sortMode) {
                ForEach(RecommendationSortMode.allCases, id: \.self) { mode in
                    Text(mode.label).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var groupedByTexture: [(FoodTexture, [FoodRecommendation])] {
        var grouped: [FoodTexture: [FoodRecommendation]] = [:]
        for rec in filteredRecommendations {
            grouped[rec.food.texture, default: []].append(rec)
        }
        return FoodTexture.allCases.compactMap { texture in
            guard let items = grouped[texture], !items.isEmpty else { return nil }
            return (texture, items)
        }
    }

    private var groupedByFlavor: [(FoodFlavor, [FoodRecommendation])] {
        var grouped: [FoodFlavor: [FoodRecommendation]] = [:]
        for rec in filteredRecommendations {
            grouped[rec.food.flavor, default: []].append(rec)
        }
        return FoodFlavor.allCases.compactMap { flavor in
            guard let items = grouped[flavor], !items.isEmpty else { return nil }
            return (flavor, items)
        }
    }

    private func attributeSection(title: String, icon: String, color: Color, items: [FoodRecommendation]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.callout)
                    .foregroundStyle(color)
                Text(title.uppercased())
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(color)
                Text("(\(items.count))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(items.prefix(8)) { rec in
                    let tier = rec.tier
                    recommendationRow(rec, tier: tier)
                    if rec.id != items.prefix(8).last?.id {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private func textureGroupColor(_ texture: FoodTexture) -> Color {
        switch texture {
        case .crunchy: .orange
        case .soft: .blue
        case .mushy: .purple
        case .liquid: .cyan
        case .mixedTexture: .indigo
        }
    }

    private func flavorGroupColor(_ flavor: FoodFlavor) -> Color {
        switch flavor {
        case .bland: .gray
        case .salty: .orange
        case .sweet: .pink
        case .sour: .yellow
        case .bitter: .green
        }
    }

    private func tierColor(_ tier: RecommendationTier) -> Color {
        switch tier {
        case .perfectMatch: .green
        case .greatMatch: .blue
        case .goodChallenge: .orange
        case .expertChallenge: .red
        }
    }
}

enum RecommendationSortMode: String, CaseIterable {
    case tier, texture, flavor

    var label: String {
        switch self {
        case .tier: "Tier"
        case .texture: "Texture"
        case .flavor: "Flavor"
        }
    }
}

struct ScorePill: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(Int(value))")
                .font(.caption2.bold())
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 8))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(color.opacity(0.06))
        .clipShape(.rect(cornerRadius: 6))
    }
}
