import SwiftUI

struct GalaxyMapView: View {
    let viewModel: AppViewModel
    @State private var selectedFood: FoodItem?
    @State private var showParentGate: Bool = false
    @State private var parentGateProgress: CGFloat = 0
    @State private var appeared: Bool = false
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showCosmetics: Bool = false
    @State private var showFoodSearch: Bool = false
    @State private var searchText: String = ""
    @State private var showCreateFood: Bool = false
    @State private var foodToReset: FoodItem?
    @State private var showResetConfirmation: Bool = false
    @FocusState private var isSearchFocused: Bool

    private var allFoodsForCategory: [FoodItem] {
        viewModel.allDisplayFoods(for: selectedCategory)
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var displayedFoods: [FoodItem] {
        if isSearching {
            return FoodDatabase.search(searchText, in: allFoodsForCategory)
        }
        return allFoodsForCategory
    }

    private var customFoodIds: Set<UUID> {
        Set(viewModel.customFoodItems.map(\.id))
    }

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            VStack(spacing: 0) {
                header
                categoryFilter
                planetGrid
            }
            .onTapGesture {
                isSearchFocused = false
            }

            if viewModel.showRewardUnlocked {
                rewardUnlockedOverlay
            }
        }
        .sheet(item: $selectedFood) { food in
            PlanetQuestView(food: food, viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(SpaceTheme.deepNavy)
        }
        .sheet(isPresented: $showParentGate) {
            ParentGateSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCosmetics) {
            CosmeticsView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showFoodSearch) {
            FoodSearchView(viewModel: viewModel, selectedFood: $selectedFood)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .alert("Reset \(foodToReset?.name ?? "Food") to Learn Phase?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {
                foodToReset = nil
            }
            Button("Reset", role: .destructive) {
                if let food = foodToReset {
                    viewModel.resetFoodProgress(foodId: food.id)
                }
                foodToReset = nil
            }
        } message: {
            Text("This will remove all logged progress and reset this food to the Look phase (Day 1). This action cannot be undone.")
        }
        .sheet(isPresented: $showCreateFood) {
            CustomFoodCreationModal(
                initialName: searchText,
                viewModel: viewModel,
                onFoodCreated: { food in
                    searchText = ""
                    isSearchFocused = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        selectedFood = food
                    }
                }
            )
        }
        .onAppear {
            withAnimation(.spring.delay(0.2)) { appeared = true }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                showCosmetics = true
            } label: {
                ExplorerAvatarView(
                    explorerType: viewModel.profile.explorerType,
                    equippedCosmetics: viewModel.profile.equippedCosmetics,
                    size: 44
                )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.profile.explorerDisplayName)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                HStack(spacing: 8) {
                    LevelBadgeView(
                        level: viewModel.profile.currentLevel,
                        progress: viewModel.profile.levelProgress
                    )
                    if viewModel.profile.currentStreak > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                            Text("\(viewModel.profile.currentStreak)")
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }

            Spacer()

            StarDustCounter(amount: viewModel.profile.totalStarDust)

            Button {
                showFoodSearch = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 44, height: 44)
            }

            Button {
                showParentGate = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                categoryChip(nil, label: "All", icon: "globe.americas.fill")
                ForEach(FoodCategory.allCases, id: \.self) { category in
                    categoryChip(category, label: category.label, icon: category.icon)
                }
            }
        }
        .contentMargins(.horizontal, 20)
        .scrollIndicators(.hidden)
        .padding(.vertical, 8)
    }

    private func categoryChip(_ category: FoodCategory?, label: String, icon: String) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(label)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(isSelected ? SpaceTheme.deepNavy : .white.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected ? SpaceTheme.cosmicCyan : .white.opacity(0.08))
            )
        }
    }

    private var planetGrid: some View {
        ScrollView {
            VStack(spacing: 12) {
                JourneyMapView(
                    currentPlanet: viewModel.profile.currentJourneyPlanet,
                    progress: viewModel.profile.journeyProgress,
                    explorerType: viewModel.profile.explorerType,
                    foodsExplored: viewModel.exploredFoodsCount
                )
                .padding(.horizontal, 20)

                starJarBanner
                    .padding(.horizontal, 20)

                inlineSearchBar
                    .padding(.horizontal, 16)

                if isSearching && displayedFoods.count >= 3 {
                    HStack {
                        Text("Showing \(displayedFoods.count) results")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(.white.opacity(0.4))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }

                if let suggestion = viewModel.bridgeSuggestions.first, !isSearching {
                    bridgeSuggestionBanner(suggestion)
                        .padding(.horizontal, 20)
                }
            }

            if isSearching && displayedFoods.isEmpty {
                searchEmptyState
                    .padding(.horizontal, 20)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 20
                ) {
                    ForEach(Array(displayedFoods.enumerated()), id: \.element.id) { index, food in
                        let progress = viewModel.questProgress(for: food.id)
                        Button {
                            selectedFood = food
                        } label: {
                            PlanetView(food: food, progress: progress)
                                .overlay(alignment: .topTrailing) {
                                    if customFoodIds.contains(food.id) {
                                        Text("✦")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(SpaceTheme.cosmicCyan)
                                            .padding(4)
                                    }
                                }
                        }
                        .contextMenu {
                            if progress?.isPreCompleted ?? false {
                                Button(role: .destructive) {
                                    foodToReset = food
                                    showResetConfirmation = true
                                } label: {
                                    Label("Reset to Learn Phase", systemImage: "arrow.counterclockwise")
                                }
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(duration: 0.5).delay(Double(index) * 0.03), value: appeared)
                        .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedFood?.id == food.id)
                    }
                }
                .padding(.horizontal, 20)

                if isSearching {
                    inlineCreateFoodButton
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
            }

            Spacer().frame(height: 100)
        }
        .scrollIndicators(.hidden)
    }

    private var inlineSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6))

            TextField("", text: $searchText, prompt: Text("Search").foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.6)))
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isSearchFocused)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(red: 0.8, green: 0.8, blue: 0.8))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(red: 0.96, green: 0.96, blue: 0.96).opacity(0.12))
        )
    }

    private var searchEmptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 30)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.2))

            Text("No foods found for \"\(searchText)\"")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))

            Button {
                showCreateFood = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Create \"\(searchText)\"")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                        Text("Add as a custom food")
                            .font(.system(.caption, design: .rounded))
                            .opacity(0.7)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .opacity(0.5)
                }
                .foregroundStyle(SpaceTheme.deepNavy)
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(SpaceTheme.cosmicCyan)
                )
            }
        }
    }

    private var inlineCreateFoodButton: some View {
        Button {
            showCreateFood = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SpaceTheme.cosmicCyan.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "plus")
                        .font(.subheadline.bold())
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Create \"\(searchText)\"")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                    Text("Add as a custom food")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(SpaceTheme.cosmicCyan.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(SpaceTheme.cosmicCyan.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    private func bridgeSuggestionBanner(_ suggestion: BridgeSuggestion) -> some View {
        Button {
            selectedFood = suggestion.bridgeFood
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SpaceTheme.cosmicCyan.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "arrow.triangle.branch")
                        .font(.title3)
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Try Next: \(suggestion.bridgeFood.emoji) \(suggestion.bridgeFood.name)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

                    Text(suggestion.reason)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(SpaceTheme.cosmicCyan.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(SpaceTheme.cosmicCyan.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    private var starJarBanner: some View {
        Button {
            showParentGate = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SpaceTheme.starGold.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: viewModel.profile.starJarRewardUnlocked ? "gift.fill" : "star.circle.fill")
                        .font(.title2)
                        .foregroundStyle(SpaceTheme.starGold)
                        .symbolEffect(.pulse)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.profile.starJarRewardUnlocked ? "Reward Unlocked!" : "Star Jar")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

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
                }

                Text("\(viewModel.profile.totalStarDust)/\(viewModel.profile.starJarTargetStarDust)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(SpaceTheme.starGold)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(SpaceTheme.starGold.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }

    private var rewardUnlockedOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring) { viewModel.showRewardUnlocked = false }
                }

            VStack(spacing: 24) {
                Text("📡")
                    .font(.system(size: 60))

                Text("Transmission from Earth!")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                Text("You earned your reward:")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                Text(viewModel.profile.starJarRewardName)
                    .font(.system(.title, design: .rounded, weight: .heavy))
                    .foregroundStyle(SpaceTheme.starGold)

                Text("Show this to your parent!")
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))

                Button {
                    withAnimation(.spring) { viewModel.showRewardUnlocked = false }
                } label: {
                    Text("Amazing!")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(SpaceTheme.deepNavy)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(SpaceTheme.starGold))
                }
                .sensoryFeedback(.success, trigger: viewModel.showRewardUnlocked)
            }
            .padding(32)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

struct ParentGateSheet: View {
    let viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var holdProgress: CGFloat = 0
    @State private var isHolding: Bool = false
    @State private var gateUnlocked: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if gateUnlocked {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.green)

                        Text("Parent Mode Unlocked")
                            .font(.headline)

                        Button("Open Command Center") {
                            dismiss()
                            viewModel.switchToParentMode()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)

                        Text("Parent Zone")
                            .font(.title3.bold())

                        Text("Hold the button for 3 seconds\nto access the parent dashboard.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        ZStack {
                            Circle()
                                .stroke(.quaternary, lineWidth: 6)
                                .frame(width: 80, height: 80)

                            Circle()
                                .trim(from: 0, to: holdProgress)
                                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(-90))

                            Image(systemName: "hand.tap.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
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
                                        gateUnlocked = true
                                    }
                                }
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { _ in
                                    if !gateUnlocked {
                                        withAnimation { holdProgress = 0 }
                                        isHolding = false
                                    }
                                }
                        )
                    }
                }
            }
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
