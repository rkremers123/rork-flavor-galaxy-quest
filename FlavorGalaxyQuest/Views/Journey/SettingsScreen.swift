import SwiftUI

struct SettingsScreen: View {
    let viewModel: AppViewModel
    @State private var parentUnlocked = false
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding = false
    @State private var showParentDashboard = false
    @State private var showResetConfirmation = false
    @State private var showPaywall = false
    @State private var showCosmetics = false

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    explorerCard
                    cosmeticsButton
                    starJarCard

                    if parentUnlocked {
                        parentSection
                    } else {
                        parentGate
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $showParentDashboard) {
            ParentDashboardView(viewModel: viewModel)
        }
        .sheet(isPresented: $showCosmetics) {
            CosmeticsView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(subscription: viewModel.subscription) {
                viewModel.subscription.startFreeTrial()
            }
        }
        .alert("Reset All Data?", isPresented: $showResetConfirmation) {
            Button("Reset", role: .destructive) { viewModel.resetApp() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase all progress, profiles, and settings. This cannot be undone.")
        }
    }

    private var explorerCard: some View {
        HStack(spacing: 16) {
            ExplorerAvatarView(
                explorerType: viewModel.profile.explorerType,
                equippedCosmetics: viewModel.profile.equippedCosmetics,
                size: 60
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.profile.explorerDisplayName)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                Text(viewModel.profile.explorerType.title)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))

                LevelBadgeView(
                    level: viewModel.profile.currentLevel,
                    progress: viewModel.profile.levelProgress
                )
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text("\(viewModel.profile.totalStarDust)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(SpaceTheme.starGold)

                if viewModel.profile.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                        Text("\(viewModel.profile.currentStreak) day streak")
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                    }
                    .foregroundStyle(.orange)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var cosmeticsButton: some View {
        Button { showCosmetics = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SpaceTheme.starGold.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "crown.fill")
                        .font(.callout)
                        .foregroundStyle(SpaceTheme.starGold)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Cosmetics & Gear")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("\(viewModel.profile.unlockedCosmetics.count) unlocked")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.06), lineWidth: 1)
                    )
            )
        }
    }

    private var starJarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: viewModel.profile.starJarRewardUnlocked ? "gift.fill" : "star.circle.fill")
                    .font(.callout)
                    .foregroundStyle(SpaceTheme.starGold)
                Text("Star Jar")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text(viewModel.profile.starJarRewardUnlocked ? "UNLOCKED!" : "\(viewModel.profile.totalStarDust)/\(viewModel.profile.starJarTargetStarDust)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(viewModel.profile.starJarRewardUnlocked ? SpaceTheme.planetGreen : SpaceTheme.starGold)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.1))
                        .frame(height: 6)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: viewModel.profile.starJarRewardUnlocked
                                    ? [SpaceTheme.planetGreen, SpaceTheme.cosmicCyan]
                                    : [SpaceTheme.starGold, SpaceTheme.warningOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * viewModel.starJarProgress, height: 6)
                }
            }
            .frame(height: 6)

            Text("Reward: \(viewModel.profile.starJarRewardName)")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(SpaceTheme.starGold.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private var parentGate: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.3))

            Text("Parent Zone")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text("Hold for 3 seconds to access\nparent settings and dashboard")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 5)
                    .frame(width: 70, height: 70)

                Circle()
                    .trim(from: 0, to: holdProgress)
                    .stroke(SpaceTheme.cosmicCyan, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "hand.tap.fill")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .gesture(
                LongPressGesture(minimumDuration: 3)
                    .onChanged { _ in
                        isHolding = true
                        withAnimation(.linear(duration: 3)) {
                            holdProgress = 1.0
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring) {
                            parentUnlocked = true
                        }
                    }
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        if !parentUnlocked {
                            withAnimation { holdProgress = 0 }
                            isHolding = false
                        }
                    }
            )
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var parentSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(SpaceTheme.planetGreen)
                Text("Parent Mode Active")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(SpaceTheme.planetGreen)
            }
            .padding(.bottom, 4)

            parentDashboardButton
            starJarSettingsCard
            allergenCard
            subscriptionCard
            profileCard

            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                    Text("Reset All Data")
                }
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(.red.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.red.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.red.opacity(0.15), lineWidth: 1)
                        )
                )
            }
        }
    }

    private var parentDashboardButton: some View {
        Button { showParentDashboard = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SpaceTheme.cosmicCyan.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: "chart.bar.fill")
                        .font(.callout)
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Parent Dashboard")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Analytics, food timeline, therapist export")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(SpaceTheme.cosmicCyan.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(SpaceTheme.cosmicCyan.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    private var starJarSettingsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Star Jar Settings")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
            }

            HStack {
                Text("Reward")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                TextField("Reward name", text: Binding(
                    get: { viewModel.profile.starJarRewardName },
                    set: {
                        viewModel.profile.starJarRewardName = $0
                        viewModel.saveProfile()
                    }
                ))
                .multilineTextAlignment(.trailing)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white)
            }

            HStack {
                Text("Target Star Dust")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                Stepper(
                    "\(viewModel.profile.starJarTargetStarDust)",
                    value: Binding(
                        get: { viewModel.profile.starJarTargetStarDust },
                        set: {
                            viewModel.profile.starJarTargetStarDust = $0
                            viewModel.profile.starJarRewardUnlocked = false
                            viewModel.saveProfile()
                        }
                    ),
                    in: 50...2000,
                    step: 50
                )
                .font(.system(.caption, design: .rounded))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var allergenCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Allergen Filters")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 6)], spacing: 6) {
                ForEach(Allergen.allCases, id: \.self) { allergen in
                    let isExcluded = viewModel.profile.excludedAllergens.contains(allergen)
                    Button {
                        if isExcluded {
                            viewModel.profile.excludedAllergens.remove(allergen)
                        } else {
                            viewModel.profile.excludedAllergens.insert(allergen)
                        }
                        viewModel.refreshBridgeSuggestions()
                        viewModel.saveProfile()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isExcluded ? "xmark.circle.fill" : "circle")
                                .font(.caption2)
                                .foregroundStyle(isExcluded ? .red : .white.opacity(0.3))
                            Text(allergen.label)
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(isExcluded ? .red : .white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isExcluded ? .red.opacity(0.08) : .white.opacity(0.04))
                        )
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var subscriptionCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Subscription")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Text(viewModel.subscription.hasAccess ? "Premium" : "Free")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(viewModel.subscription.hasAccess ? SpaceTheme.planetGreen : .white.opacity(0.4))
            }

            if !viewModel.subscription.hasAccess {
                Button { showPaywall = true } label: {
                    Text("Upgrade to Premium")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(SpaceTheme.cosmicCyan.opacity(0.1))
                        )
                }
            }

            Button {
                viewModel.subscription.restorePurchases()
            } label: {
                Text("Restore Purchases")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var profileCard: some View {
        VStack(spacing: 0) {
            profileRow("Name", value: viewModel.profile.name)
            profileRow("Age", value: "\(viewModel.profile.age)")
            profileRow("Target Food", value: viewModel.profile.targetFoodName.isEmpty ? "Not set" : viewModel.profile.targetFoodName)
            profileRow("Safe Foods", value: "\(viewModel.profile.safeFoodIds.count)")
            profileRow("Days Active", value: "\(daysActive)")
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func profileRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var daysActive: Int {
        let days = Calendar.current.dateComponents([.day], from: viewModel.profile.createdDate, to: Date()).day ?? 0
        return max(days + 1, 1)
    }
}
