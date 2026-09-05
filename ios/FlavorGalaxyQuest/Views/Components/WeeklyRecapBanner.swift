import SwiftUI

struct WeeklyRecapBanner: View {
    let viewModel: AppViewModel
    @Binding var isVisible: Bool

    private var weeklyStats: WeeklyStats {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(byAdding: .day, value: -7, to: now) else {
            return WeeklyStats(foodsLogged: 0, phasesProgressed: 0, currentStreak: 0, longestStreak: 0)
        }

        let weekInteractions = viewModel.profile.interactions.filter {
            $0.timestamp >= weekStart && $0.completed
        }

        let foodsLogged = Set(weekInteractions.map { $0.foodId }).count
        let phasesProgressed = weekInteractions.count

        return WeeklyStats(
            foodsLogged: foodsLogged,
            phasesProgressed: phasesProgressed,
            currentStreak: viewModel.profile.currentStreak,
            longestStreak: viewModel.profile.longestStreak
        )
    }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.callout)
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                    Text("Weekly Recap")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                }

                Spacer()

                Button {
                    withAnimation(.spring(duration: 0.3)) { isVisible = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }

            HStack(spacing: 16) {
                recapStat(value: "\(weeklyStats.foodsLogged)", label: "Foods", icon: "fork.knife", color: SpaceTheme.cosmicCyan)
                recapStat(value: "\(weeklyStats.phasesProgressed)", label: "Steps", icon: "stairs", color: SpaceTheme.planetGreen)
                recapStat(value: "\(weeklyStats.currentStreak)", label: "Streak", icon: "flame.fill", color: .orange)
            }

            if weeklyStats.foodsLogged > 0 {
                Text("Great week, \(viewModel.profile.explorerDisplayName)! Keep exploring!")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            } else {
                Text("Start exploring foods to build your streak!")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(SpaceTheme.cosmicCyan.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func recapStat(value: String, label: String, icon: String?, color: Color) -> some View {
        VStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }
}

nonisolated struct WeeklyStats: Sendable {
    let foodsLogged: Int
    let phasesProgressed: Int
    let currentStreak: Int
    let longestStreak: Int
}
