import SwiftUI

struct ParentDashboardView: View {
    let viewModel: AppViewModel
    @State private var selectedTab: ParentTab = .overview
    @State private var showResetConfirmation: Bool = false
    @State private var showEducationSection: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabSelector
                    .padding(.top, 8)

                TabView(selection: $selectedTab) {
                    overviewTab.tag(ParentTab.overview)
                    foodLibraryTab.tag(ParentTab.foodLibrary)
                    analyticsTab.tag(ParentTab.analytics)
                    settingsTab.tag(ParentTab.settings)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Command Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Back to Explorer") {
                        viewModel.switchToExplorerMode()
                    }
                }
            }
            .alert("Reset All Data?", isPresented: $showResetConfirmation) {
                Button("Reset", role: .destructive) { viewModel.resetApp() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will erase all progress, profiles, and settings. This cannot be undone.")
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
                targetFoodProgressSection
                streakSection
                statsGrid
                whyThisWorksSection
                starJarSection
                bridgeSuggestionsSection
                recentActivitySection
            }
            .padding(16)
        }
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
                        if let food = FoodDatabase.food(byId: quest.foodId) {
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

    private var analyticsTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                braveryMapSection
                comfortInsightsSection
                bridgeHistorySection
            }
            .padding(16)
        }
    }

    private var braveryMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bravery Map")
                .font(.headline)

            Text("Comfort level across sensory zones")
                .font(.caption)
                .foregroundStyle(.secondary)

            let levels = viewModel.sensoryComfortLevels()
            let maxLevel = max(levels.values.max() ?? 1, 1)

            VStack(spacing: 12) {
                ForEach(SensoryStep.allCases, id: \.self) { step in
                    let level = levels[step] ?? 0
                    HStack(spacing: 12) {
                        Image(systemName: step.icon)
                            .font(.callout)
                            .frame(width: 24)
                            .foregroundStyle(SpaceTheme.planetColor(hex: step.color))

                        Text(step.label)
                            .font(.subheadline)
                            .frame(width: 50, alignment: .leading)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color(.tertiarySystemFill))
                                    .frame(height: 8)

                                Capsule()
                                    .fill(SpaceTheme.planetColor(hex: step.color))
                                    .frame(
                                        width: geo.size.width * CGFloat(level) / CGFloat(maxLevel),
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)

                        Text("\(level)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var comfortInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sensory Insights")
                .font(.headline)

            let percentages = viewModel.comfortPercentages()
            let sorted = percentages.sorted { $0.value > $1.value }

            if let easiest = sorted.first, let hardest = sorted.last, easiest.key != hardest.key {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundStyle(.green)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Easiest: \(easiest.key.label)")
                                .font(.subheadline.weight(.medium))
                            Text("\(Int(easiest.value))% comfort")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hardest: \(hardest.key.label)")
                                .font(.subheadline.weight(.medium))
                            Text("\(Int(hardest.value))% comfort")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if hardest.key == .taste || hardest.key == .lick {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                            Text("Focus on touch & smell to build confidence before \(hardest.key.label.lowercased()).")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Complete more quests to unlock insights")
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

    private var bridgeHistorySection: some View {
        Group {
            if !viewModel.profile.bridgeRecords.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Bridge History")
                        .font(.headline)

                    VStack(spacing: 0) {
                        ForEach(viewModel.profile.bridgeRecords) { record in
                            if let food = FoodDatabase.food(byId: record.bridgeFoodId) {
                                HStack(spacing: 12) {
                                    Text(food.emoji)
                                        .font(.title3)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(food.name)
                                            .font(.subheadline.weight(.medium))
                                        Text("\(record.bridgeType.label) · \(record.exposureCount) exposures")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    statusBadge(record.status)
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
    }

    private func statusBadge(_ status: BridgeStatus) -> some View {
        Text(status.rawValue.capitalized)
            .font(.system(.caption2, weight: .bold))
            .foregroundStyle(statusColor(status))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(statusColor(status).opacity(0.12)))
    }

    private func statusColor(_ status: BridgeStatus) -> Color {
        switch status {
        case .active: .blue
        case .completed: .green
        case .failed: .orange
        case .skipped: .secondary
        }
    }

    private var settingsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                starJarSettingsSection
                allergenSection
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

            Text("Excluded allergens won't appear in bridge suggestions")
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
    case overview, foodLibrary, analytics, settings

    var label: String {
        switch self {
        case .overview: "Overview"
        case .foodLibrary: "Food Library"
        case .analytics: "Analytics"
        case .settings: "Settings"
        }
    }

    var icon: String {
        switch self {
        case .overview: "chart.bar.fill"
        case .foodLibrary: "books.vertical.fill"
        case .analytics: "brain.head.profile.fill"
        case .settings: "gearshape.fill"
        }
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
