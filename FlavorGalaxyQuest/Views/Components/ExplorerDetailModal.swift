import SwiftUI

struct ExplorerDetailModal: View {
    let viewModel: AppViewModel
    @Binding var showCosmetics: Bool
    @Environment(\.dismiss) private var dismiss

    private var profile: ChildProfileModel { viewModel.profile }
    private var explorer: ExplorerType { profile.explorerType }
    private var accentColor: Color { SpaceTheme.planetColor(hex: explorer.accentHex) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [accentColor.opacity(0.3), .clear],
                                center: .center,
                                startRadius: 40,
                                endRadius: 120
                            )
                        )
                        .frame(width: 200, height: 200)

                    ExplorerAvatarView(
                        explorerType: explorer,
                        equippedCosmetics: profile.equippedCosmetics,
                        size: 140
                    )
                }

                VStack(spacing: 6) {
                    Text(profile.explorerDisplayName)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

                    Text(explorer.title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(accentColor)

                    Text(explorer.tagline)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 20) {
                    statPill(
                        icon: "star.fill",
                        value: "Level \(profile.currentLevel.rawValue)",
                        label: profile.currentLevel.title,
                        color: SpaceTheme.starGold
                    )

                    if profile.currentStreak > 0 {
                        statPill(
                            icon: "flame.fill",
                            value: "\(profile.currentStreak)",
                            label: "Day Streak",
                            color: .orange
                        )
                    }

                    statPill(
                        icon: "sparkles",
                        value: "\(profile.totalStarDust)",
                        label: "Star Dust",
                        color: SpaceTheme.cosmicCyan
                    )
                }

                Button {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showCosmetics = true
                    }
                } label: {
                    Label("Customize Explorer", systemImage: "paintbrush.fill")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(SpaceTheme.deepNavy)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(accentColor))
                }

                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }
            }
        }
    }

    private func statPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.06))
        )
    }
}
