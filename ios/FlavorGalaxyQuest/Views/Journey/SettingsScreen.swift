import SwiftUI
import UIKit

struct SettingsScreen: View {
    let viewModel: AppViewModel
    private enum PINPhase {
        case create
        case confirm
        case enter
    }

    @State private var parentUnlocked = false
    @State private var showParentDashboard = false
    @State private var showResetConfirmation = false
    @State private var showPaywall = false
    @State private var showCosmetics = false
    @State private var pinPhase: PINPhase = PersistenceService.hasParentPIN ? .enter : .create
    @State private var pinEntry = ""
    @State private var pendingCreatePIN = ""
    @State private var pinError: String?
    @State private var showNeverOfferPicker = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Button("Done") { dismiss() }
                            .font(SGFont.caption())
                            .foregroundStyle(SGColor.glow)
                            .accessibilityLabel("Close parent settings")
                    }

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
            PaywallView(subscription: viewModel.subscription)
        }
        .sheet(isPresented: $showNeverOfferPicker) {
            NeverOfferPickerSheet(viewModel: viewModel)
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
            Group {
                if UIImage(named: "empty_state_pin") != nil {
                    Image("empty_state_pin")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(maxWidth: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.3))
                }
            }

            Text("Parent Zone")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text(pinPrompt)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < pinEntry.count ? SpaceTheme.cosmicCyan : Color.white.opacity(0.12))
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                }
            }

            if let pinError {
                Text(pinError)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.red.opacity(0.85))
            }

            pinKeypad
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
                Spacer()
                Button("Lock") {
                    lockParentZone()
                }
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.bottom, 4)

            parentDashboardButton
            streakCard
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
                        viewModel.refreshRecommendations()
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

            Text("Do not give")
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.top, 6)

            Text("These foods will never be recommended or started as a quest.")
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))

            ForEach(viewModel.neverOfferFoods) { food in
                HStack(spacing: 8) {
                    FoodIcon(food: food, size: 16)
                    Text(food.name)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Remove") {
                        viewModel.toggleNeverOffer(food: food)
                    }
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.red)
                }
            }

            Button {
                showNeverOfferPicker = true
            } label: {
                Text("Add a food")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(SpaceTheme.cosmicCyan)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(SpaceTheme.cosmicCyan.opacity(0.1))
                    )
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
                Task { await viewModel.subscription.restorePurchases() }
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

    private var streakCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Streak Stats")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
            }

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.title3)
                            .foregroundStyle(.orange)
                        Text("\(viewModel.profile.currentStreak)")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Text("Current")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 1, height: 36)

                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.title3)
                            .foregroundStyle(SpaceTheme.starGold)
                        Text("\(viewModel.profile.longestStreak)")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Text("Best")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
            }

            if viewModel.canResumeStreak {
                Button {
                    viewModel.resumeStreak()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Resume Streak (1x/month)")
                    }
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

            if let lastDate = viewModel.profile.lastActivityDate {
                HStack {
                    Text("Last activity")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                    Text(lastDate, style: .relative)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.orange.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private var daysActive: Int {
        let days = Calendar.current.dateComponents([.day], from: viewModel.profile.createdDate, to: Date()).day ?? 0
        return max(days + 1, 1)
    }

    private var pinPrompt: String {
        switch pinPhase {
        case .create:
            return "Create a 4-digit PIN to lock\nparent settings and Reset All Data"
        case .confirm:
            return "Enter the same PIN again to confirm"
        case .enter:
            return "Enter your 4-digit PIN to open\nparent settings and dashboard"
        }
    }

    private var pinKeypad: some View {
        let keys = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]
        return VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            handlePINKey(key)
                        } label: {
                            Text(key)
                                .font(.system(.title2, design: .rounded, weight: .semibold))
                                .foregroundStyle(key.isEmpty ? .clear : .white)
                                .frame(width: 64, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(key.isEmpty ? .clear : .white.opacity(0.06))
                                )
                        }
                        .disabled(key.isEmpty)
                    }
                }
            }
        }
    }

    private func handlePINKey(_ key: String) {
        pinError = nil
        if key == "⌫" {
            if !pinEntry.isEmpty {
                pinEntry.removeLast()
            }
            return
        }
        guard key.count == 1, key.first?.isNumber == true, pinEntry.count < 4 else { return }
        pinEntry.append(key)
        if pinEntry.count == 4 {
            submitPIN()
        }
    }

    private func submitPIN() {
        switch pinPhase {
        case .create:
            pendingCreatePIN = pinEntry
            pinEntry = ""
            pinPhase = .confirm
        case .confirm:
            if pinEntry == pendingCreatePIN {
                PersistenceService.setParentPIN(pinEntry)
                pendingCreatePIN = ""
                pinEntry = ""
                withAnimation(.spring) {
                    parentUnlocked = true
                }
            } else {
                pinError = "PINs did not match. Try again."
                pendingCreatePIN = ""
                pinEntry = ""
                pinPhase = .create
            }
        case .enter:
            if PersistenceService.verifyParentPIN(pinEntry) {
                pinEntry = ""
                withAnimation(.spring) {
                    parentUnlocked = true
                }
            } else {
                pinError = "Incorrect PIN"
                pinEntry = ""
            }
        }
    }

    private func lockParentZone() {
        parentUnlocked = false
        pinEntry = ""
        pinError = nil
        pendingCreatePIN = ""
        pinPhase = PersistenceService.hasParentPIN ? .enter : .create
    }

}
