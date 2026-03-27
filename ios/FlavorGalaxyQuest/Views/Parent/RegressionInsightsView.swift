import SwiftUI

struct RegressionInsightsView: View {
    let viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryCard
                
                if !viewModel.regressionPatterns.isEmpty {
                    patternsSection
                }

                if !viewModel.activeRegressions.isEmpty {
                    activeRegressionsSection
                }

                if viewModel.activeRegressions.isEmpty && viewModel.regressionPatterns.isEmpty {
                    emptyState
                }

                recentHistorySection
            }
            .padding(16)
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("\(viewModel.activeRegressionCount)")
                    .font(.title.bold())
                    .foregroundStyle(.orange)
                Text("Active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack(spacing: 4) {
                Text("\(viewModel.regressionPatterns.count)")
                    .font(.title.bold())
                    .foregroundStyle(.red)
                Text("Patterns")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)

            Divider().frame(height: 40)

            VStack(spacing: 4) {
                let resolved = viewModel.profile.regressions.filter { $0.status == .resolved }.count
                Text("\(resolved)")
                    .font(.title.bold())
                    .foregroundStyle(.green)
                Text("Resolved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                Text("Active Patterns")
                    .font(.headline)
            }

            ForEach(viewModel.regressionPatterns) { pattern in
                patternCard(pattern)
            }
        }
    }

    private func patternCard(_ pattern: RegressionPattern) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: patternIcon(pattern.patternType))
                    .foregroundStyle(patternColor(pattern.patternType))
                    .font(.callout)

                Text("\(pattern.attributeLabel) \(pattern.patternType == .flavor ? "Flavor" : pattern.patternType == .texture ? "Texture" : "Temperature") Pattern")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("\(pattern.count) foods")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(.tertiarySystemFill)))
            }

            Text(pattern.message)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption)
                Text(pattern.suggestion)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.yellow.opacity(0.06))
            .clipShape(.rect(cornerRadius: 8))

            HStack(spacing: 6) {
                ForEach(pattern.foods, id: \.self) { foodName in
                    Text(foodName)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(patternColor(pattern.patternType).opacity(0.1)))
                        .foregroundStyle(patternColor(pattern.patternType))
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var activeRegressionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Regressed Foods")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(viewModel.activeRegressions, id: \.id) { regression in
                    regressionRow(regression)
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private func regressionRow(_ regression: RegressionModel) -> some View {
        let allFoods = FoodDatabase.allFoods + viewModel.customFoodItems
        let food = allFoods.first { $0.id == regression.foodId }

        return HStack(spacing: 12) {
            Text(food?.emoji ?? "🍽")
                .font(.title3)

            VStack(alignment: .leading, spacing: 3) {
                Text(regression.foodName)
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("Used to eat · \(regression.regressionDate.formatted(.dateTime.month(.abbreviated).day()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !regression.parentNotes.isEmpty {
                    Text(regression.parentNotes)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text("\(regression.daysSinceRegression)d ago")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var recentHistorySection: some View {
        Group {
            let resolvedRegressions = viewModel.profile.regressions
                .filter { $0.status == .resolved }
                .sorted { ($0.resolvedDate ?? .distantPast) > ($1.resolvedDate ?? .distantPast) }
                .prefix(5)

            if !resolvedRegressions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recovery History")
                        .font(.headline)

                    VStack(spacing: 0) {
                        ForEach(Array(resolvedRegressions), id: \.id) { regression in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(regression.foodName)
                                        .font(.subheadline.weight(.medium))
                                    if let resolved = regression.resolvedDate {
                                        Text("Re-mastered \(resolved.formatted(.dateTime.month(.abbreviated).day()))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
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
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No Active Regressions")
                .font(.subheadline.weight(.semibold))
            Text("If your child stops eating a mastered food, long-press the food card to mark it as \"Used to Eat\" for tracking.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func patternIcon(_ type: RegressionPatternType) -> String {
        switch type {
        case .texture: "hand.raised.fill"
        case .flavor: "mouth.fill"
        case .temperature: "thermometer.medium"
        }
    }

    private func patternColor(_ type: RegressionPatternType) -> Color {
        switch type {
        case .texture: .purple
        case .flavor: .red
        case .temperature: .orange
        }
    }
}
