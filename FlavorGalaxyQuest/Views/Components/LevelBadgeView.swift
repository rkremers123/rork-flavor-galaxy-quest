import SwiftUI

struct LevelBadgeView: View {
    let level: ExplorerLevel
    let progress: Double

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 2.5)
                    .frame(width: 32, height: 32)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        SpaceTheme.cosmicCyan,
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                    )
                    .frame(width: 32, height: 32)
                    .rotationEffect(.degrees(-90))

                Text("Lv")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("Level \(level.rawValue)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text(level.title)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(SpaceTheme.deepNavy.opacity(0.8))
                .overlay(
                    Capsule()
                        .stroke(SpaceTheme.cosmicCyan.opacity(0.3), lineWidth: 1)
                )
        )
    }
}
