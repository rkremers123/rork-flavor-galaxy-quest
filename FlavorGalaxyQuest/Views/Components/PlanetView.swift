import SwiftUI

struct PlanetView: View {
    let food: FoodItem
    let progress: QuestProgress
    @State private var rotate: Bool = false

    private var planetColor: Color {
        progress.completedSteps.isEmpty
            ? Color.gray.opacity(0.4)
            : SpaceTheme.planetColor(hex: food.planetColorHex)
    }

    private var glowOpacity: Double {
        progress.isComplete ? 0.6 : progress.progressFraction * 0.4
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [planetColor.opacity(glowOpacity), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 50
                        )
                    )
                    .frame(width: 90, height: 90)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                planetColor.opacity(0.9),
                                planetColor,
                                planetColor.opacity(0.6)
                            ],
                            center: UnitPoint(x: 0.35, y: 0.35),
                            startRadius: 2,
                            endRadius: 35
                        )
                    )
                    .frame(width: 64, height: 64)
                    .overlay {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        Text(food.emoji)
                            .font(.title)
                            .opacity(progress.completedSteps.isEmpty ? 0.3 : 1.0)
                    }
                    .shadow(color: planetColor.opacity(glowOpacity), radius: 8)

                if progress.isComplete {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption)
                        .foregroundStyle(SpaceTheme.starGold)
                        .offset(x: 24, y: -24)
                        .transition(.scale.combined(with: .opacity))
                }

                if !progress.completedSteps.isEmpty && !progress.isComplete {
                    ProgressRing(progress: progress.progressFraction)
                        .frame(width: 72, height: 72)
                }
            }

            Text(food.name)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(progress.completedSteps.isEmpty ? .white.opacity(0.5) : .white)
                .lineLimit(1)
        }
    }
}

struct ProgressRing: View {
    let progress: Double

    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                SpaceTheme.cosmicCyan,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
    }
}
