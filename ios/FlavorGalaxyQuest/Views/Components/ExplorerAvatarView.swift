import SwiftUI
import UIKit

struct ExplorerAvatarView: View {
    let explorerType: ExplorerType
    let equippedCosmetics: Set<Cosmetic>
    var size: CGFloat = 60
    @State private var float: Bool = false
    @State private var auraRotation: Double = 0
    @State private var particlePhase: CGFloat = 0

    var body: some View {
        ZStack {
            if let aura = equippedCosmetics.first(where: { $0.category == .aura }) {
                auraLayer(aura)
            }

            if let particle = equippedCosmetics.first(where: { $0.category == .particle }) {
                particleLayer(particle)
            }

            if let backpack = equippedCosmetics.first(where: { $0.category == .backpack }) {
                CosmeticArt(cosmetic: backpack, size: size * 0.3)
                    .offset(x: -size * 0.05, y: size * 0.05)
                    .opacity(0.9)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            SpaceTheme.planetColor(hex: explorerType.accentHex).opacity(0.3),
                            .clear
                        ],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.6
                    )
                )
                .frame(width: size, height: size)

            explorerArt
                .frame(width: size * 0.75, height: size * 0.75)
                .offset(y: float ? -3 : 3)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: float)

            if let handheld = equippedCosmetics.first(where: { $0.category == .handheld }) {
                CosmeticArt(cosmetic: handheld, size: size * 0.22)
                    .offset(x: size * 0.3, y: size * 0.1)
            }

            if let badge = equippedCosmetics.first(where: { $0.category == .achievementBadge }) {
                CosmeticArt(cosmetic: badge, size: size * 0.18)
                    .offset(x: size * 0.25, y: -size * 0.15)
            }

            if let milestone = equippedCosmetics.first(where: { $0.category == .milestoneBadge }) {
                CosmeticArt(cosmetic: milestone, size: size * 0.18)
                    .offset(x: -size * 0.28, y: -size * 0.15)
            }
        }
        .frame(width: size * 1.4, height: size * 1.4)
        .onAppear {
            float = true
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                auraRotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                particlePhase = 1
            }
        }
    }

    /// Board portrait when the avatar is large enough to show face detail; kit art otherwise.
    /// Quiet Saturn default_avatar if both are missing.
    private var explorerArt: some View {
        Group {
            if size >= 72, UIImage(named: explorerType.boardImageName) != nil {
                Image(explorerType.boardImageName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else if UIImage(named: explorerType.imageName) != nil {
                Image(explorerType.imageName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else if UIImage(named: "default_avatar") != nil {
                Image("default_avatar")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(size * 0.12)
            }
        }
    }

    private func auraLayer(_ aura: Cosmetic) -> some View {
        let primary = SpaceTheme.planetColor(hex: aura.primaryColorHex)
        let secondary = SpaceTheme.planetColor(hex: aura.secondaryColorHex)

        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [primary.opacity(0.35), secondary.opacity(0.15), .clear],
                        center: .center,
                        startRadius: size * 0.2,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.35, height: size * 1.35)
                .rotationEffect(.degrees(auraRotation))

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [primary.opacity(0.4), secondary.opacity(0.2), .clear, primary.opacity(0.3)],
                        center: .center
                    ),
                    lineWidth: size * 0.04
                )
                .frame(width: size * 1.2, height: size * 1.2)
                .rotationEffect(.degrees(-auraRotation * 0.5))
        }
    }

    private func particleLayer(_ particle: Cosmetic) -> some View {
        let primary = SpaceTheme.planetColor(hex: particle.primaryColorHex)
        let secondary = SpaceTheme.planetColor(hex: particle.secondaryColorHex)
        let dustAsset = particle.imageName
        let useDust = dustAsset.flatMap { UIImage(named: $0) } != nil

        return ZStack {
            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) * 60 + Double(particlePhase) * 30
                let radius = size * (0.45 + particlePhase * 0.15)
                let x = cos(angle * .pi / 180) * radius
                let y = sin(angle * .pi / 180) * radius

                Group {
                    if useDust, let dustAsset {
                        Image(dustAsset)
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: size * 0.1, height: size * 0.1)
                            .opacity(0.55 + Double(particlePhase) * 0.35)
                    } else {
                        Circle()
                            .fill(i % 2 == 0 ? primary : secondary)
                            .frame(width: size * 0.06, height: size * 0.06)
                            .opacity(0.6 + Double(particlePhase) * 0.3)
                    }
                }
                .offset(x: x, y: y)
            }
        }
    }
}

/// Illustrated cosmetic art when `imageName` is set.
/// Auras (no asset) get a mini procedural glow — same idea as `ExplorerAvatarView`.
/// Missing badges/bags/handhelds fall back to the category SF Symbol, never emoji.
struct CosmeticArt: View {
    let cosmetic: Cosmetic
    var size: CGFloat = 24

    var body: some View {
        Group {
            if let name = cosmetic.imageName, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else if cosmetic.category == .aura {
                auraFallback
            } else {
                Image(systemName: cosmetic.category.icon)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.12)
                    .foregroundStyle(SpaceTheme.planetColor(hex: cosmetic.primaryColorHex).opacity(0.9))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var auraFallback: some View {
        let primary = SpaceTheme.planetColor(hex: cosmetic.primaryColorHex)
        let secondary = SpaceTheme.planetColor(hex: cosmetic.secondaryColorHex)
        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [primary.opacity(0.55), secondary.opacity(0.25), .clear],
                        center: .center,
                        startRadius: size * 0.05,
                        endRadius: size * 0.5
                    )
                )
            Circle()
                .stroke(primary.opacity(0.45), lineWidth: max(1, size * 0.06))
                .frame(width: size * 0.72, height: size * 0.72)
        }
    }
}
