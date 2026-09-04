import SwiftUI
import UIKit

struct WarpTransitionView: View {
    @State private var phase: CGFloat = 0
    @State private var streaks: [(angle: Double, length: CGFloat, offset: CGFloat)] = []

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                for streak in streaks {
                    let angle = streak.angle * .pi / 180
                    let startDist = streak.offset * phase * 0.5
                    let endDist = startDist + streak.length * phase

                    let start = CGPoint(
                        x: center.x + cos(angle) * startDist,
                        y: center.y + sin(angle) * startDist
                    )
                    let end = CGPoint(
                        x: center.x + cos(angle) * endDist,
                        y: center.y + sin(angle) * endDist
                    )

                    var path = Path()
                    path.move(to: start)
                    path.addLine(to: end)

                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [.clear, SpaceTheme.cosmicCyan, .white, SpaceTheme.cosmicCyan, .clear]),
                            startPoint: start,
                            endPoint: end
                        ),
                        lineWidth: 2
                    )
                }
            }

            VStack(spacing: 16) {
                Group {
                    if UIImage(named: "explorer_nova") != nil {
                        Image("explorer_nova")
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                    } else if UIImage(named: "default_avatar") != nil {
                        Image("default_avatar")
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                    } else {
                        Text("🚀")
                            .font(.system(size: 60))
                    }
                }
                .scaleEffect(phase > 0.5 ? 1.2 : 0.8)

                Text("Warp Speed!")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(phase > 0.3 ? 1 : 0)
            }
        }
        .onAppear {
            streaks = (0..<60).map { _ in
                (
                    angle: Double.random(in: 0...360),
                    length: CGFloat.random(in: 50...200),
                    offset: CGFloat.random(in: 100...500)
                )
            }
            withAnimation(.easeIn(duration: 1.2)) {
                phase = 1.0
            }
        }
    }
}
