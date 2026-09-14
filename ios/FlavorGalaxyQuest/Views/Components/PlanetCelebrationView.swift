import SwiftUI
import UIKit

struct PlanetCelebrationView: View {
    let planet: JourneyPlanet
    let explorerType: ExplorerType
    let onComplete: () -> Void

    @State private var appeared = false
    @State private var sparklePhase = 0

    private var planetColor: Color {
        SpaceTheme.planetColor(hex: planet.accentColor)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.88).ignoresSafeArea()

            VStack(spacing: 24) {
                sparkleRing

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [planetColor.opacity(0.4), planetColor.opacity(0.05)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(appeared ? 1.0 : 0.3)

                    Group {
                        if UIImage(named: planet.imageName) != nil {
                            Image(planet.imageName)
                                .resizable()
                                .interpolation(.high)
                                .scaledToFit()
                        } else if UIImage(named: "planet_base_camp") != nil {
                            Image("planet_base_camp")
                                .resizable()
                                .interpolation(.high)
                                .scaledToFit()
                        } else {
                            Image(systemName: "globe.americas.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.white.opacity(0.85))
                                .padding(28)
                        }
                    }
                        .frame(width: 140, height: 140)
                        .clipShape(Circle())
                        .scaleEffect(appeared ? 1.0 : 0.2)
                }

                VStack(spacing: 8) {
                    Text(planet.name)
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Unlocked!")
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .foregroundStyle(planetColor)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

                Group {
                    if UIImage(named: explorerType.boardImageName) != nil {
                        Image(explorerType.boardImageName)
                            .resizable()
                            .interpolation(.high)
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else if UIImage(named: explorerType.imageName) != nil {
                        Image(explorerType.imageName)
                            .resizable()
                            .scaledToFit()
                    } else if UIImage(named: "default_avatar") != nil {
                        Image("default_avatar")
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: "sparkles")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white.opacity(0.85))
                            .padding(8)
                    }
                }
                    .frame(width: 64, height: 64)
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .rotationEffect(.degrees(appeared ? 0 : -15))
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.65), value: appeared)
        }
        .allowsHitTesting(false)
        .sensoryFeedback(.success, trigger: appeared)
        .onAppear {
            withAnimation { appeared = true }
            Task {
                try? await Task.sleep(for: .seconds(3.5))
                onComplete()
            }
        }
    }

    private var sparkleRing: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                let angle = Double(i) * 45
                let delay = Double(i) * 0.08
                Group {
                    if UIImage(named: "star_dust_particle") != nil {
                        Image("star_dust_particle")
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .opacity(0.75)
                    } else {
                        Image(systemName: "sparkle")
                            .font(.caption)
                            .foregroundStyle(planetColor.opacity(0.6))
                    }
                }
                .offset(y: -90)
                .rotationEffect(.degrees(angle))
                .scaleEffect(appeared ? 1.0 : 0.0)
                .opacity(appeared ? 1.0 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.3 + delay), value: appeared)
            }
        }
        .frame(width: 200, height: 200)
    }
}
