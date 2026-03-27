import SwiftUI

struct LevelUpCelebrationView: View {
    let level: ExplorerLevel
    let explorerType: ExplorerType
    let onDismiss: () -> Void
    @State private var showContent: Bool = false
    @State private var confettiTrigger: Int = 0
    @State private var particlePositions: [(x: CGFloat, y: CGFloat, size: CGFloat, color: Color, rotation: Double)] = []

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            Canvas { context, size in
                for particle in particlePositions {
                    let rect = CGRect(
                        x: particle.x * size.width,
                        y: particle.y * size.height,
                        width: particle.size,
                        height: particle.size
                    )
                    context.fill(
                        RoundedRectangle(cornerRadius: 2).path(in: rect),
                        with: .color(particle.color)
                    )
                }
            }
            .opacity(showContent ? 1 : 0)
            .allowsHitTesting(false)

            VStack(spacing: 24) {
                Image(explorerType.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .scaleEffect(showContent ? 1.0 : 0.3)

                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [SpaceTheme.starGold, SpaceTheme.warningOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("Level \(level.rawValue)")
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

                    Text(level.title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }
                .scaleEffect(showContent ? 1.0 : 0.5)
                .opacity(showContent ? 1 : 0)

                let newCosmetics = Cosmetic.allCases.filter {
                    if case .level(let req) = $0.unlockCondition, req == level { return true }
                    return false
                }
                if !newCosmetics.isEmpty {
                    VStack(spacing: 8) {
                        Text("New Cosmetics Unlocked!")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.6))

                        HStack(spacing: 16) {
                            ForEach(newCosmetics, id: \.self) { cosmetic in
                                VStack(spacing: 4) {
                                    Text(cosmetic.emoji)
                                        .font(.title)
                                    Text(cosmetic.name)
                                        .font(.system(.caption2, design: .rounded, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.08))
                    )
                    .opacity(showContent ? 1 : 0)
                }

                Button {
                    onDismiss()
                } label: {
                    Text("Awesome!")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(SpaceTheme.deepNavy)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(SpaceTheme.starGold)
                        )
                }
                .opacity(showContent ? 1 : 0)
            }
        }
        .sensoryFeedback(.success, trigger: confettiTrigger)
        .onAppear {
            generateConfetti()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showContent = true
            }
            confettiTrigger += 1
        }
    }

    private func generateConfetti() {
        let colors: [Color] = [SpaceTheme.starGold, SpaceTheme.cosmicCyan, SpaceTheme.planetGreen, SpaceTheme.nebulaPink, SpaceTheme.warningOrange]
        particlePositions = (0..<60).map { _ in
            (
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 4...10),
                color: colors.randomElement() ?? .white,
                rotation: Double.random(in: 0...360)
            )
        }
    }
}
