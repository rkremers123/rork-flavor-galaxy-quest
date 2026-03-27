import SwiftUI

struct SpaceBackgroundView: View {
    @State private var starPositions: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = []
    @State private var twinkle: Bool = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                MeshGradient(
                    width: 3, height: 3,
                    points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [0.5, 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ],
                    colors: [
                        SpaceTheme.deepNavy, SpaceTheme.spacePurple, SpaceTheme.deepNavy,
                        SpaceTheme.spacePurple, Color(red: 0.08, green: 0.02, blue: 0.2), SpaceTheme.nebulaPink.opacity(0.3),
                        SpaceTheme.deepNavy, SpaceTheme.spacePurple, SpaceTheme.deepNavy
                    ]
                )
                .ignoresSafeArea()

                Canvas { context, size in
                    for star in starPositions {
                        let rect = CGRect(
                            x: star.x * size.width,
                            y: star.y * size.height,
                            width: star.size,
                            height: star.size
                        )
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(.white.opacity(star.opacity))
                        )
                    }
                }
                .opacity(twinkle ? 1.0 : 0.7)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: twinkle)
            }
            .onAppear {
                generateStars(in: geo.size)
                twinkle = true
            }
        }
        .ignoresSafeArea()
    }

    private func generateStars(in size: CGSize) {
        starPositions = (0..<80).map { _ in
            (
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...0.9)
            )
        }
    }
}
