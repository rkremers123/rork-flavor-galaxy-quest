import SwiftUI

struct CosmeticsView: View {
    let viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    avatarPreview

                    ForEach(CosmeticCategory.allCases, id: \.self) { category in
                        cosmeticSection(category)
                    }
                }
                .padding(20)
            }
            .background(SpaceTheme.deepNavy.ignoresSafeArea())
            .navigationTitle("Cosmetics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var avatarPreview: some View {
        VStack(spacing: 12) {
            ExplorerAvatarView(
                explorerType: viewModel.profile.explorerType,
                equippedCosmetics: viewModel.profile.equippedCosmetics,
                size: 100
            )

            Text(viewModel.profile.explorerDisplayName)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            LevelBadgeView(
                level: viewModel.profile.currentLevel,
                progress: viewModel.profile.levelProgress
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private func cosmeticSection(_ category: CosmeticCategory) -> some View {
        let items = Cosmetic.allCases.filter { $0.category == category }
        return VStack(alignment: .leading, spacing: 12) {
            Text(category.label)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], spacing: 12) {
                ForEach(items, id: \.self) { cosmetic in
                    cosmeticCard(cosmetic)
                }
            }
        }
    }

    private func cosmeticCard(_ cosmetic: Cosmetic) -> some View {
        let isUnlocked = viewModel.profile.unlockedCosmetics.contains(cosmetic)
        let isEquipped = viewModel.profile.equippedCosmetics.contains(cosmetic)
        let bgColor: Color = isEquipped ? SpaceTheme.cosmicCyan.opacity(0.2) : .white.opacity(0.05)
        let borderColor: Color = isEquipped ? SpaceTheme.cosmicCyan.opacity(0.6) : .white.opacity(0.1)
        let borderWidth: CGFloat = isEquipped ? 2 : 1

        return Button {
            if isUnlocked {
                viewModel.toggleCosmetic(cosmetic)
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Text(cosmetic.emoji)
                        .font(.title)
                        .opacity(isUnlocked ? 1.0 : 0.3)

                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                            .offset(x: 14, y: 14)
                    }
                }

                Text(cosmetic.name)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.4))
                    .lineLimit(1)

                if !isUnlocked {
                    Text("Lv\(cosmetic.requiredLevel.rawValue)")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(bgColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
        }
        .disabled(!isUnlocked)
    }
}
