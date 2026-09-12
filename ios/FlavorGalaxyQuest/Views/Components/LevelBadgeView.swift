import SwiftUI
import UIKit

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

                if UIImage(named: "level_gem") != nil {
                    Image("level_gem")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .opacity(0.9)
                }

                Text("\(level.rawValue)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Text(level.title)
                .font(.system(size: 9, weight: .semibold, design: .rounded))
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
