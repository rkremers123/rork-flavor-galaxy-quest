import SwiftUI

struct ExplorerAvatarView: View {
    let explorerType: ExplorerType
    let equippedCosmetics: Set<Cosmetic>
    var size: CGFloat = 60
    @State private var float: Bool = false

    var body: some View {
        ZStack {
            if equippedCosmetics.contains(where: { $0.category == .effect }) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [effectColor.opacity(0.3), .clear],
                            center: .center,
                            startRadius: size * 0.3,
                            endRadius: size * 0.7
                        )
                    )
                    .frame(width: size * 1.4, height: size * 1.4)
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

            Image(explorerType.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.75, height: size * 0.75)
                .offset(y: float ? -3 : 3)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: float)

            if let hat = equippedCosmetics.first(where: { $0.category == .hat }) {
                Text(hat.emoji)
                    .font(.system(size: size * 0.25))
                    .offset(x: size * 0.2, y: -size * 0.3)
            }

            if let badge = equippedCosmetics.first(where: { $0.category == .badge }) {
                Text(badge.emoji)
                    .font(.system(size: size * 0.2))
                    .offset(x: -size * 0.25, y: size * 0.2)
            }
        }
        .frame(width: size, height: size)
        .onAppear { float = true }
    }

    private var effectColor: Color {
        guard let effect = equippedCosmetics.first(where: { $0.category == .effect }) else {
            return .clear
        }
        switch effect {
        case .glowAura: return SpaceTheme.cosmicCyan
        case .sparkleTrail: return SpaceTheme.starGold
        case .rainbowAura: return SpaceTheme.nebulaPink
        case .powerGlow: return SpaceTheme.warningOrange
        default: return .clear
        }
    }
}
