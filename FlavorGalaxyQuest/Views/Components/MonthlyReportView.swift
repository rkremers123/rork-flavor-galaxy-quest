import SwiftUI

struct MonthlyReportView: View {
    let viewModel: AppViewModel

    private let calendar = Calendar.current

    private var monthStats: MonthlyStats {
        let now = Date()
        guard let monthStart = calendar.date(byAdding: .month, value: -1, to: now) else {
            return MonthlyStats.empty
        }

        let monthInteractions = viewModel.profile.interactions.filter {
            $0.timestamp >= monthStart && $0.completed
        }

        let foodsLogged = Set(monthInteractions.map { $0.foodId }).count

        let activeDays = Set(monthInteractions.map { calendar.startOfDay(for: $0.timestamp) }).count

        let allFoods = FoodDatabase.allFoods + viewModel.customFoodItems
        let foodIds = Set(monthInteractions.map { $0.foodId })
        let foods = foodIds.compactMap { id in allFoods.first { $0.id == id } }

        var textureCounts: [FoodTexture: Int] = [:]
        var flavorCounts: [FoodFlavor: Int] = [:]
        var tempCounts: [FoodTemperature: Int] = [:]

        for food in foods {
            textureCounts[food.texture, default: 0] += 1
            flavorCounts[food.flavor, default: 0] += 1
            tempCounts[food.temperature, default: 0] += 1
        }

        let topTextures = textureCounts.sorted { $0.value > $1.value }.prefix(3).map { "\($0.key.label) (\($0.value))" }
        let topFlavors = flavorCounts.sorted { $0.value > $1.value }.prefix(3).map { "\($0.key.label) (\($0.value))" }
        let topTemps = tempCounts.sorted { $0.value > $1.value }.prefix(3).map { "\($0.key.label) (\($0.value))" }

        let activeRegressions = viewModel.profile.regressions.filter {
            $0.regressionDate >= monthStart && $0.status == .active
        }

        return MonthlyStats(
            foodsLogged: foodsLogged,
            daysActive: activeDays,
            longestStreak: viewModel.profile.longestStreak,
            topTextures: topTextures,
            topFlavors: topFlavors,
            topTemperatures: topTemps,
            regressionCount: activeRegressions.count,
            regressedFoods: activeRegressions.map(\.foodName)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: "doc.text.fill")
                    .font(.title3)
                    .foregroundStyle(SpaceTheme.cosmicCyan)
                Text("Monthly Report")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }

            engagementSection

            if !monthStats.topTextures.isEmpty {
                sensoryProfileSection
            }

            regressionSection
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var engagementSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ENGAGEMENT")
                .font(.system(.caption2, design: .rounded, weight: .heavy))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(1)

            HStack(spacing: 12) {
                reportMetric(value: "\(monthStats.foodsLogged)", label: "Foods Logged", color: SpaceTheme.cosmicCyan)
                reportMetric(value: "\(monthStats.daysActive)/30", label: "Days Active", color: SpaceTheme.planetGreen)
                reportMetric(value: "🔥 \(monthStats.longestStreak)", label: "Best Streak", color: .orange)
            }
        }
    }

    private var sensoryProfileSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SENSORY PROFILE")
                .font(.system(.caption2, design: .rounded, weight: .heavy))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(1)

            if !monthStats.topTextures.isEmpty {
                reportRow(icon: "waveform", label: "Textures", value: monthStats.topTextures.joined(separator: ", "))
            }
            if !monthStats.topFlavors.isEmpty {
                reportRow(icon: "drop.fill", label: "Flavors", value: monthStats.topFlavors.joined(separator: ", "))
            }
            if !monthStats.topTemperatures.isEmpty {
                reportRow(icon: "thermometer.medium", label: "Temperature", value: monthStats.topTemperatures.joined(separator: ", "))
            }
        }
    }

    private var regressionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("REGRESSION STATUS")
                .font(.system(.caption2, design: .rounded, weight: .heavy))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(1)

            if monthStats.regressionCount == 0 {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(SpaceTheme.planetGreen)
                    Text("No regressions detected this month")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(SpaceTheme.planetGreen.opacity(0.08))
                )
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(monthStats.regressionCount) food\(monthStats.regressionCount == 1 ? "" : "s") regressed")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("This is normal — continued exploration helps restore acceptance.")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.orange.opacity(0.08))
                )
            }
        }
    }

    private func reportMetric(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.opacity(0.06))
        )
    }

    private func reportRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(SpaceTheme.cosmicCyan)
                .frame(width: 16)
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(2)
        }
    }
}

nonisolated struct MonthlyStats: Sendable {
    let foodsLogged: Int
    let daysActive: Int
    let longestStreak: Int
    let topTextures: [String]
    let topFlavors: [String]
    let topTemperatures: [String]
    let regressionCount: Int
    let regressedFoods: [String]

    static let empty = MonthlyStats(
        foodsLogged: 0, daysActive: 0, longestStreak: 0,
        topTextures: [], topFlavors: [], topTemperatures: [],
        regressionCount: 0, regressedFoods: []
    )
}
