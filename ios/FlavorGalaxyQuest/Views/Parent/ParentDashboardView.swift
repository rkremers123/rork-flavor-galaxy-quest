import SwiftUI
import UIKit

struct ParentDashboardView: View {
    let viewModel: AppViewModel
    @State private var selectedTab: ParentTab = .overview
    @State private var showResetConfirmation: Bool = false
    @State private var showEducationSection: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var pdfData: Data?
    @State private var showUpgradePrompt: Bool = false
    @State private var showNeverOfferPicker: Bool = false

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabSelector
                    .padding(.top, 8)

                Group {
                    switch selectedTab {
                    case .overview: overviewTab
                    case .progress: progressTab
                    case .foodLibrary: foodLibraryTab
                    case .regressions: regressionsTab
                    case .analytics: analyticsTab
                    case .recommendations: recommendationsTab
                    case .settings: settingsTab
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Command Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.caption.weight(.semibold))
                            Text("\(viewModel.profile.explorerDisplayName)'s Journey")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .alert("Reset All Data?", isPresented: $showResetConfirmation) {
                Button("Reset", role: .destructive) { viewModel.resetApp() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will erase all progress, profiles, and settings. This cannot be undone.")
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(subscription: viewModel.subscription)
            }
            .sheet(isPresented: $showShareSheet) {
                if let data = pdfData {
                    ShareSheetView(activityItems: [data])
                }
            }
            .sheet(isPresented: $showNeverOfferPicker) {
                NeverOfferPickerSheet(viewModel: viewModel)
            }
            .onChange(of: selectedTab) { _, newTab in
                if (newTab == .analytics || newTab == .recommendations) && !viewModel.subscription.hasAccess {
                    if viewModel.sensoryProfile.totalFoodsConsumed >= 5 {
                        showUpgradePrompt = true
                    }
                }
            }
        }
    }

    private var tabSelector: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(ParentTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(duration: 0.3)) { selectedTab = tab }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: tab.icon)
                                .font(.caption)
                            Text(tab.label)
                                .font(.subheadline.weight(.medium))
                            if tab.isPremium && !viewModel.subscription.hasAccess {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 8))
                            }
                        }
                        .foregroundStyle(selectedTab == tab ? .white : .secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color.accentColor : Color(.tertiarySystemFill))
                        )
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
    }

    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.activeRegressionCount > 0 {
                    regressionBanner
                }

                targetFoodProgressSection
                streakSection
                statsGrid
                whyThisWorksSection
                starJarSection
                bridgeSuggestionsSection

                if !viewModel.subscription.hasAccess && viewModel.sensoryProfile.totalFoodsConsumed >= 5 {
                    upgradePromptCard
                }

                recentActivitySection
            }
            .padding(16)
        }
    }

    private var progressTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                CalendarProgressView(viewModel: viewModel)
                MonthlyReportView(viewModel: viewModel)
            }
            .padding(16)
        }
    }

    private var regressionBanner: some View {
        Button {
            withAnimation(.spring(duration: 0.3)) { selectedTab = .regressions }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.activeRegressionCount) Regression\(viewModel.activeRegressionCount == 1 ? "" : "s") Detected")
                        .font(.subheadline.weight(.semibold))
                    if !viewModel.regressionPatterns.isEmpty {
                        Text("\(viewModel.regressionPatterns.count) sensory pattern\(viewModel.regressionPatterns.count == 1 ? "" : "s") found")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color.orange.opacity(0.08))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var upgradePromptCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "brain.head.profile.fill")
                    .font(.title3)
                    .foregroundStyle(.purple)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(viewModel.profile.explorerDisplayName)'s sensory profile is ready!")
                        .font(.subheadline.weight(.semibold))
                    Text("Unlock personalized recommendations & analytics")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Button {
                showPaywall = true
            } label: {
                Text("Start 7-Day Free Trial")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var targetFoodProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target Food Progress")
                .font(.headline)

            if let target = viewModel.targetFood {
                let progress = viewModel.questProgress(for: target.id)

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Text(target.emoji)
                            .font(.largeTitle)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(target.name)
                                .font(.headline)
                            Text("\(Int((progress?.progressFraction ?? 0) * 100))% Complete")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    HStack(spacing: 8) {
                        ForEach(SensoryStep.allCases, id: \.self) { step in
                            let completed = progress?.completedSteps.contains(step) ?? false
                            let skipped = progress?.skippedSteps.contains(step) ?? false

                            VStack(spacing: 4) {
                                Image(systemName: completed ? "checkmark.circle.fill" : skipped ? "arrow.uturn.right.circle" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(completed ? .green : skipped ? .orange : .secondary)
                                Text(step.label)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    if !viewModel.bridgeSuggestions.isEmpty {
                        let suggestion = viewModel.bridgeSuggestions[0]
                        HStack(spacing: 8) {
                            Image(systemName: suggestion.bridgeType.icon)
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Next: \(suggestion.bridgeFood.name)")
                                    .font(.caption.weight(.semibold))
                                Text(suggestion.reason)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(10)
                        .background(Color.blue.opacity(0.08))
                        .clipShape(.rect(cornerRadius: 8))
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No target food set")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Streak")
                    .font(.headline)
                Spacer()
                if viewModel.canResumeStreak {
                    Button("Extend Streak") {
                        viewModel.resumeStreak()
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.blue)
                }
            }

            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(viewModel.profile.currentStreak)")
                            .font(.title.bold())
                    }
                    Text("Current")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text("\(viewModel.profile.longestStreak)")
                        .font(.title.bold())
                    Text("Longest")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)

                VStack(spacing: 4) {
                    Text("\(viewModel.profile.todayInteractionCount)")
                        .font(.title.bold())
                    Text("Today")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            StatCard(
                title: "Foods Explored",
                value: "\(viewModel.exploredFoodsCount)",
                icon: "globe.americas.fill",
                color: .cyan
            )
            StatCard(
                title: "Quests Complete",
                value: "\(viewModel.completedQuestsCount)",
                icon: "checkmark.seal.fill",
                color: .green
            )
            StatCard(
                title: "Star Dust",
                value: "\(viewModel.profile.totalStarDust)",
                icon: "sparkles",
                color: .yellow
            )
            StatCard(
                title: "Total Actions",
                value: "\(viewModel.profile.totalInteractions)",
                icon: "hand.tap.fill",
                color: .orange
            )
        }
    }

    private var starJarSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Star Jar Progress")
                .font(.headline)

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(viewModel.profile.starJarRewardName)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    if viewModel.profile.starJarRewardUnlocked {
                        Text("UNLOCKED!")
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    } else {
                        Text("\(Int(viewModel.starJarProgress * 100))%")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                }

                ProgressView(value: viewModel.starJarProgress)
                    .tint(viewModel.profile.starJarRewardUnlocked ? .green : .yellow)

                Text("\(viewModel.profile.totalStarDust) / \(viewModel.profile.starJarTargetStarDust) Star Dust")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var bridgeSuggestionsSection: some View {
        Group {
            if !viewModel.bridgeSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bridge Food Suggestions")
                        .font(.headline)

                    Text("Stepping stones from safe foods toward \(viewModel.profile.targetFoodName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 0) {
                        ForEach(viewModel.bridgeSuggestions) { suggestion in
                            HStack(spacing: 12) {
                                Text(suggestion.bridgeFood.emoji)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(suggestion.bridgeFood.name)
                                            .font(.subheadline.weight(.medium))
                                        Text(suggestion.bridgeType.label)
                                            .font(.system(.caption2, weight: .bold))
                                            .foregroundStyle(.blue)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Capsule().fill(.blue.opacity(0.12)))
                                    }
                                    Text(suggestion.reason)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                Image(systemName: "arrow.right.circle")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                    }
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 14))
                }
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)

            let recentQuests = viewModel.profile.questProgressItems
                .filter { $0.lastAttemptDate != nil }
                .sorted { ($0.lastAttemptDate ?? .distantPast) > ($1.lastAttemptDate ?? .distantPast) }
                .prefix(5)

            if recentQuests.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No activity yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recentQuests)) { quest in
                        let food = FoodDatabase.food(byId: quest.foodId) ?? viewModel.customFoodItems.first { $0.id == quest.foodId }
                        if let food {
                            HStack(spacing: 12) {
                                Text(food.emoji)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(food.name)
                                        .font(.subheadline.weight(.medium))
                                    Text("\(quest.completedStepValues.count)/\(SensoryStep.allCases.count) steps")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if quest.isComplete {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else {
                                    ProgressView(value: quest.progressFraction)
                                        .frame(width: 40)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private var foodLibraryTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(FoodCategory.allCases, id: \.self) { category in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .foregroundStyle(.secondary)
                            Text(category.label)
                                .font(.headline)
                        }
                        .padding(.horizontal, 16)

                        VStack(spacing: 0) {
                            ForEach(FoodDatabase.foods(for: category)) { food in
                                let progress = viewModel.questProgress(for: food.id)
                                let isSafe = viewModel.profile.safeFoodIds.contains(food.id)

                                HStack(spacing: 12) {
                                    Text(food.emoji)
                                        .font(.title3)

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text(food.name)
                                                .font(.subheadline.weight(.medium))
                                            if isSafe {
                                                Text("SAFE")
                                                    .font(.system(.caption2, weight: .bold))
                                                    .foregroundStyle(.green)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(
                                                        Capsule().fill(.green.opacity(0.15))
                                                    )
                                            }
                                        }
                                        Text("\(food.texture.label) · \(food.flavor.label) · \(food.aroma.label)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if progress?.isComplete ?? false {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    } else if !(progress?.completedStepValues.isEmpty ?? true) {
                                        Text("\(progress?.completedStepValues.count ?? 0)/5")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 14))
                    }
                }
            }
            .padding(16)
        }
    }

    private var regressionsTab: some View {
        RegressionInsightsView(viewModel: viewModel)
    }

    private var analyticsTab: some View {
        Group {
            if viewModel.subscription.hasAccess {
                SensoryProfileDashboardView(
                    sensoryProfile: viewModel.sensoryProfile,
                    insights: viewModel.sensoryInsights,
                    onExportPDF: {
                        pdfData = viewModel.exportTherapistPDF()
                        showShareSheet = true
                    }
                )
            } else {
                paywallGateView(
                    icon: "chart.bar.fill",
                    title: "Sensory Analytics",
                    description: "See \(viewModel.profile.explorerDisplayName)'s texture, flavor & temperature profile with visual charts, success zones, and personalized insights."
                )
            }
        }
    }

    private var recommendationsTab: some View {
        Group {
            if viewModel.subscription.hasAccess {
                SmartRecommendationsView(
                    recommendations: viewModel.foodRecommendations,
                    childName: viewModel.profile.explorerDisplayName,
                    onStartQuest: { food in
                        viewModel.setActiveQuest(food: food)
                        viewModel.switchToExplorerMode()
                    },
                    onRefresh: { viewModel.refreshRecommendations() }
                )
            } else {
                paywallGateView(
                    icon: "sparkles",
                    title: "Smart Recommendations",
                    description: "Get personalized food suggestions scored by match quality, bridge potential, and confidence level."
                )
            }
        }
    }

    private func paywallGateView(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    Image(systemName: icon)
                        .font(.largeTitle)
                        .foregroundStyle(.purple)
                }

                Text(title)
                    .font(.title3.bold())

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                showPaywall = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "lock.open.fill")
                        .font(.subheadline)
                    Text("Unlock with Free Trial")
                        .font(.subheadline.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 14))
                .padding(.horizontal, 40)
            }

            if viewModel.sensoryProfile.totalFoodsConsumed < 3 {
                Text("Complete at least 3 food quests to generate your profile")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
    }

    private var settingsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                starJarSettingsSection
                allergenSection
                subscriptionSection
                profileSection
                dangerZoneSection
            }
            .padding(16)
        }
    }

    private var starJarSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Star Jar Settings")
                .font(.headline)

            VStack(spacing: 12) {
                HStack {
                    Text("Reward")
                        .font(.subheadline)
                    Spacer()
                    TextField("Reward name", text: Binding(
                        get: { viewModel.profile.starJarRewardName },
                        set: {
                            viewModel.profile.starJarRewardName = $0
                            viewModel.saveProfile()
                        }
                    ))
                    .multilineTextAlignment(.trailing)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Target Star Dust")
                        .font(.subheadline)
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
                    .font(.subheadline)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var allergenSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Allergen Filters")
                .font(.headline)

            Text("Excluded allergens and Do not give foods will not appear in recommendations, bridges, or Start Quest.")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
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
                                .font(.caption)
                                .foregroundStyle(isExcluded ? .red : .secondary)
                            Text(allergen.label)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(isExcluded ? .red : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(isExcluded ? Color.red.opacity(0.08) : Color(.tertiarySystemFill))
                        )
                    }
                }
            }

            Text("Do not give")
                .font(.headline)
                .padding(.top, 8)

            Text("These foods will never be recommended or started as a quest.")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(viewModel.neverOfferFoods) { food in
                HStack(spacing: 8) {
                    Text(food.emoji)
                    Text(food.name)
                        .font(.subheadline)
                    Spacer()
                    Button("Remove") {
                        viewModel.toggleNeverOffer(food: food)
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
                }
            }

            Button {
                showNeverOfferPicker = true
            } label: {
                Text("Add a food")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(.tertiarySystemFill))
                    )
            }
        }
    }

    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Subscription")
                .font(.headline)

            VStack(spacing: 12) {
                HStack {
                    Text("Plan")
                        .font(.subheadline)
                    Spacer()
                    Text(viewModel.subscription.hasAccess ? "Premium" : "Free")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(viewModel.subscription.hasAccess ? .green : .secondary)
                }

                if !viewModel.subscription.hasAccess {
                    Button {
                        showPaywall = true
                    } label: {
                        Text("Upgrade to Premium")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.12))
                            .foregroundStyle(.blue)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }

                Button("Restore Purchases") {
                    Task { await viewModel.subscription.restorePurchases() }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explorer Profile")
                .font(.headline)

            VStack(spacing: 0) {
                profileRow("Name", value: viewModel.profile.name)
                profileRow("Age", value: "\(viewModel.profile.age)")
                profileRow("Target Food", value: viewModel.profile.targetFoodName.isEmpty ? "Not set" : viewModel.profile.targetFoodName)
                profileRow("Safe Foods", value: "\(viewModel.profile.safeFoodIds.count) foods")
                profileRow("Days Active", value: "\(daysActive)")
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private func profileRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private var whyThisWorksSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(duration: 0.3)) {
                    showEducationSection.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "book.fill")
                        .font(.callout)
                        .foregroundStyle(.blue)
                    Text("Why This Works")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: showEducationSection ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(16)
            }

            if showEducationSection {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Why We Don't Ask Them to Eat Yet")
                            .font(.subheadline.weight(.semibold))
                        Text("Your child's nervous system needs time to adjust. Forcing eating creates shame, which makes progress harder.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Instead, we celebrate every sensory win:")
                            .font(.caption.weight(.medium))

                        VStack(alignment: .leading, spacing: 8) {
                            educationTimelineRow("eye.fill", .cyan, "LOOK", "Day 1–3", "\"I can see it without fear\"")
                            educationTimelineRow("hand.raised.fill", .blue, "TOUCH", "Day 3–7", "\"I can handle the texture\"")
                            educationTimelineRow("nose.fill", .purple, "SMELL", "Day 5–10", "\"I'm getting used to the aroma\"")
                            educationTimelineRow("mouth.fill", .orange, "LICK", "Day 7–14", "\"My mouth says it's safe\"")
                            educationTimelineRow("fork.knife", .green, "TASTE", "Day 10–21", "\"I tried it!\"")
                            educationTimelineRow("checkmark.circle.fill", .green, "SWALLOW", "Day 14+", "\"I can eat it\"")
                        }
                    }

                    VStack(spacing: 4) {
                        Text("This usually takes 3–4 weeks. Not days.")
                            .font(.caption.weight(.semibold))
                        Text("Your patience = their progress.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color.green.opacity(0.08))
                    .clipShape(.rect(cornerRadius: 8))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func educationTimelineRow(_ icon: String, _ color: Color, _ step: String, _ timeline: String, _ description: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 20)

            Text(step)
                .font(.caption.weight(.bold))
                .frame(width: 56, alignment: .leading)

            Text(timeline)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .leading)

            Text(description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Data")
                .font(.headline)

            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Reset All Data")
                }
                .font(.subheadline.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private var daysActive: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: viewModel.profile.createdDate, to: Date()).day ?? 0
        return max(days + 1, 1)
    }
}

enum ParentTab: CaseIterable {
    case overview, progress, foodLibrary, regressions, analytics, recommendations, settings

    var label: String {
        switch self {
        case .overview: "Overview"
        case .progress: "Progress"
        case .foodLibrary: "Foods"
        case .regressions: "Regressions"
        case .analytics: "Analytics"
        case .recommendations: "Suggest"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .overview: "chart.bar.fill"
        case .progress: "calendar"
        case .foodLibrary: "books.vertical.fill"
        case .regressions: "arrow.down.right.circle.fill"
        case .analytics: "brain.head.profile.fill"
        case .recommendations: "sparkles"
        case .settings: "gearshape.fill"
        }
    }

    var isPremium: Bool {
        self == .analytics || self == .recommendations
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.callout)
                    .foregroundStyle(color)
                Spacer()
            }
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


struct NeverOfferPickerSheet: View {
    let viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var foods: [FoodItem] {
        let pool = FoodDatabase.allFoods + viewModel.customFoodItems
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return pool
        }
        return FoodDatabase.search(searchText, in: pool)
    }

    var body: some View {
        NavigationStack {
            List(foods) { food in
                Button {
                    viewModel.toggleNeverOffer(food: food)
                } label: {
                    HStack(spacing: 10) {
                        Text(food.emoji)
                        Text(food.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if viewModel.profile.neverOfferFoodIds.contains(food.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search foods")
            .navigationTitle("Do not give")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
