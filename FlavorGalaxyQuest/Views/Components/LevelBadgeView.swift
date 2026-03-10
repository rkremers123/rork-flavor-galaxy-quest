import SwiftUI

struct LevelBadgeView: View {
    let level: ExplorerLevel
    let progress: Double

    var body: some View {
        HStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 2)
                    .frame(width: 26, height: 26)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        SpaceTheme.cosmicCyan,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 26, height: 26)
                    .rotationEffect(.degrees(-90))

                Text("\(level.rawValue)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text(level.title)
                .font(.system(size: 9, design: .rounded, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(SpaceTheme.deepNavy.opacity(0.8))
                .overlay(
                    Capsule()
                        .stroke(SpaceTheme.cosmicCyan.opacity(0.3), lineWidth: 1)
                )
        )
        .fixedSize()
    }
}
