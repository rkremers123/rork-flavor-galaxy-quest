import SwiftUI

struct SmartRecommendationsView: View {
    let recommendations: [FoodRecommendation]
    let childName: String
    let onStartQuest: (FoodItem) -> Void
    let onRefresh: () -> Void

    @State private var filterByConfidence: Bool = false
    @State private var expandedId: UUID?

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
                    filterToggle
                    ForEach(groupedByTier, id: \.0) { tier, items in
                        tierSection(tier: tier, items: items)
                    }
                }
            }
            .padding(16)
        }
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

                            Text(tier.label)
                                .font(.system(.caption2, weight: .bold))
                                .foregroundStyle(tierColor(tier))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(tierColor(tier).opacity(0.12)))
                        }

                        Text("\(rec.food.texture.label) · \(rec.food.flavor.label) · \(rec.food.temperature.label)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(Int(rec.score))%")
                        .font(.caption.bold())
                        .foregroundStyle(tierColor(tier))

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

    private func tierColor(_ tier: RecommendationTier) -> Color {
        switch tier {
        case .perfectMatch: .green
        case .greatMatch: .blue
        case .goodChallenge: .orange
        case .expertChallenge: .red
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
