import SwiftUI

struct ParentDashboardView: View {
    let viewModel: AppViewModel
    @State private var selectedTab: ParentTab = .overview
    @State private var showResetConfirmation: Bool = false

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
                statsGrid
                starJarSection
                recentActivitySection
            }
            .padding(16)
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
                title: "Days Active",
                value: "\(daysActive)",
                icon: "calendar",
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
                    Text(viewModel.profile.starJar.rewardName)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(Int(viewModel.starJarProgress * 100))%")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: viewModel.starJarProgress)
                    .tint(.yellow)

                Text("\(viewModel.profile.totalStarDust) / \(viewModel.profile.starJar.targetStarDust) Star Dust")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)

            let recentQuests = viewModel.profile.questProgress.values
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
                    ForEach(Array(recentQuests), id: \.foodId) { quest in
                        if let food = FoodDatabase.food(byId: quest.foodId) {
                            HStack(spacing: 12) {
                                Text(food.emoji)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(food.name)
                                        .font(.subheadline.weight(.medium))
                                    Text("\(quest.completedSteps.count)/\(SensoryStep.allCases.count) steps")
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
                                        Text("\(food.texture.label) \u{00B7} \(food.flavor.label) \u{00B7} \(food.aroma.label)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if progress.isComplete {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    } else if !progress.completedSteps.isEmpty {
                                        Text("\(progress.completedSteps.count)/5")
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
                bridgeFoodsSection
            }
            .padding(16)
        }
    }

    private var braveryMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bravery Map")
                .font(.headline)

            Text("Shows comfort level across sensory zones")
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

    private var bridgeFoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Suggested Bridge Foods")
                .font(.headline)

            Text("Based on safe foods, these are the next best foods to try")
                .font(.caption)
                .foregroundStyle(.secondary)

            let safeFoods = viewModel.profile.safeFoodIds.compactMap { FoodDatabase.food(byId: $0) }
            let bridges = safeFoods.flatMap { FoodDatabase.bridgeFoods(from: $0) }
            let uniqueBridges = Array(Set(bridges.map(\.id)))
                .compactMap { id in bridges.first { $0.id == id } }
                .prefix(8)

            if uniqueBridges.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Add safe foods to get bridge suggestions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(uniqueBridges), id: \.id) { food in
                        HStack(spacing: 12) {
                            Text(food.emoji)
                                .font(.title3)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(food.name)
                                    .font(.subheadline.weight(.medium))
                                Text("Similar: \(food.texture.label), \(food.flavor.label)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
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

    private var settingsTab: some View {
        ScrollView {
            VStack(spacing: 16) {
                starJarSettingsSection
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
                        get: { viewModel.profile.starJar.rewardName },
                        set: {
                            viewModel.profile.starJar.rewardName = $0
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
                        "\(viewModel.profile.starJar.targetStarDust)",
                        value: Binding(
                            get: { viewModel.profile.starJar.targetStarDust },
                            set: {
                                viewModel.profile.starJar.targetStarDust = $0
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

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Explorer Profile")
                .font(.headline)

            VStack(spacing: 0) {
                profileRow("Name", value: viewModel.profile.name)
                profileRow("Age", value: "\(viewModel.profile.age)")
                profileRow("Target Food", value: viewModel.profile.targetFoodName.isEmpty ? "Not set" : viewModel.profile.targetFoodName)
                profileRow("Safe Foods", value: "\(viewModel.profile.safeFoodIds.count) foods")
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
