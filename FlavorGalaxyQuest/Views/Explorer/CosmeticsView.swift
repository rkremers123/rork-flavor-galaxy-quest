import SwiftUI

struct CosmeticsView: View {
    let viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: CosmeticCategory = .achievementBadge

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    avatarPreview

                    categoryPicker

                    cosmeticGrid
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

            let equipped = viewModel.profile.equippedCosmetics
            if !equipped.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(equipped).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { cosmetic in
                        Text(cosmetic.emoji)
                            .font(.caption)
                            .padding(4)
                            .background(.white.opacity(0.1))
                            .clipShape(.rect(cornerRadius: 6))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CosmeticCategory.allCases, id: \.self) { category in
                    let isSelected = selectedCategory == category
                    let unlockedCount = Cosmetic.allCases.filter { $0.category == category && viewModel.profile.unlockedCosmetics.contains($0) }.count
                    let totalCount = Cosmetic.allCases.filter { $0.category == category }.count

                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedCategory = category
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.system(size: 16, weight: .semibold))

                            Text(category.label)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .lineLimit(1)

                            Text("\(unlockedCount)/\(totalCount)")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(isSelected ? .white.opacity(0.8) : .white.opacity(0.4))
                        }
                        .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(isSelected ? SpaceTheme.cosmicCyan.opacity(0.25) : .white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(isSelected ? SpaceTheme.cosmicCyan.opacity(0.5) : .clear, lineWidth: 1.5)
                                )
                        )
                    }
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private var cosmeticGrid: some View {
        let items = Cosmetic.allCases.filter { $0.category == selectedCategory }
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: selectedCategory.icon)
                    .foregroundStyle(SpaceTheme.cosmicCyan)
                Text(selectedCategory.label)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                ForEach(items, id: \.self) { cosmetic in
                    cosmeticCard(cosmetic)
                }
            }
        }
    }

    private func cosmeticCard(_ cosmetic: Cosmetic) -> some View {
        let isUnlocked = viewModel.profile.unlockedCosmetics.contains(cosmetic)
        let isEquipped = viewModel.profile.equippedCosmetics.contains(cosmetic)
        let primary = SpaceTheme.planetColor(hex: cosmetic.primaryColorHex)

        return Button {
            if isUnlocked {
                withAnimation(.spring(duration: 0.3)) {
                    viewModel.toggleCosmetic(cosmetic)
                }
            }
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            isEquipped
                            ? primary.opacity(0.2)
                            : .white.opacity(0.05)
                        )
                        .frame(width: 48, height: 48)

                    if isEquipped {
                        Circle()
                            .stroke(primary.opacity(0.6), lineWidth: 2)
                            .frame(width: 48, height: 48)
                    }

                    Text(cosmetic.emoji)
                        .font(.title2)
                        .opacity(isUnlocked ? 1.0 : 0.3)

                    if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(3)
                            .background(.black.opacity(0.5))
                            .clipShape(Circle())
                            .offset(x: 16, y: 16)
                    }

                    if isEquipped {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.green)
                            .offset(x: -16, y: -16)
                    }
                }

                Text(cosmetic.name)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(isUnlocked ? .white : .white.opacity(0.4))
                    .lineLimit(1)

                Text(cosmetic.unlockDescription)
                    .font(.system(size: 8, weight: .medium, design: .rounded))
                    .foregroundStyle(isUnlocked ? primary.opacity(0.8) : .white.opacity(0.3))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isEquipped ? primary.opacity(0.1) : .white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isEquipped ? primary.opacity(0.5) : .white.opacity(0.08),
                                lineWidth: isEquipped ? 2 : 1
                            )
                    )
            )
        }
        .disabled(!isUnlocked)
        .sensoryFeedback(.impact(flexibility: .soft), trigger: isEquipped)
    }
}
