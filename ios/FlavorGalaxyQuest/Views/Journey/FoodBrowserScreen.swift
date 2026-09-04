import SwiftUI
import UIKit

enum FoodBrowserTab: String, CaseIterable {
    case recommended, allFoods, search

    var label: String {
        switch self {
        case .recommended: "Recommended"
        case .allFoods: "All Foods"
        case .search: "Search"
        }
    }

    var icon: String {
        switch self {
        case .recommended: "sparkles"
        case .allFoods: "globe.americas.fill"
        case .search: "magnifyingglass"
        }
    }
}

enum FoodSortMode: String, CaseIterable {
    case dateAdded, phase, texture, flavor

    var label: String {
        switch self {
        case .dateAdded: "Date"
        case .phase: "Phase"
        case .texture: "Texture"
        case .flavor: "Flavor"
        }
    }

    var icon: String {
        switch self {
        case .dateAdded: "calendar"
        case .phase: "stairs"
        case .texture: "waveform"
        case .flavor: "drop.fill"
        }
    }
}

struct FoodBrowserScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var browserTab: FoodBrowserTab = .allFoods
    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showCreateFood = false
    @State private var sortMode: FoodSortMode = .dateAdded
    @State private var fabScale: CGFloat = 1.0
    @FocusState private var isSearchFocused: Bool

    private var allFoods: [FoodItem] {
        var combined = (FoodDatabase.allFoods + viewModel.customFoodItems).filter { !viewModel.isHardExcluded($0) }
        if let category = selectedCategory {
            combined = combined.filter { $0.category == category }
        }
        switch sortMode {
        case .texture:
            combined.sort { $0.texture.scaleRank < $1.texture.scaleRank }
        case .flavor:
            combined.sort { $0.flavor.rawValue < $1.flavor.rawValue }
        case .phase:
            combined.sort { food1, food2 in
                let p1 = viewModel.questProgress(for: food1.id)?.completedStepValues.count ?? 0
                let p2 = viewModel.questProgress(for: food2.id)?.completedStepValues.count ?? 0
                return p1 > p2
            }
        case .dateAdded:
            break
        }
        return combined
    }

    private var searchResults: [FoodItem] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        let pool = (FoodDatabase.allFoods + viewModel.customFoodItems).filter { !viewModel.isHardExcluded($0) }
        return FoodDatabase.search(searchText, in: pool)
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var customFoodIds: Set<UUID> {
        Set(viewModel.customFoodItems.map(\.id))
    }

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            VStack(spacing: 0) {
                tabPicker
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                switch browserTab {
                case .recommended:
                    recommendedContent
                case .allFoods:
                    allFoodsContent
                case .search:
                    searchContent
                }
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.spring(duration: 0.15)) { fabScale = 1.1 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(duration: 0.15)) { fabScale = 1.0 }
                            showCreateFood = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [SpaceTheme.cosmicCyan, SpaceTheme.planetColor(hex: "667eea")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: SpaceTheme.cosmicCyan.opacity(0.4), radius: 10, y: 4)
                            )
                    }
                    .scaleEffect(fabScale)
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
                }
            }
        }
        .sheet(isPresented: $showCreateFood) {
            CustomFoodCreationModal(
                initialName: searchText,
                viewModel: viewModel,
                onFoodCreated: { food in
                    viewModel.setActiveQuest(food: food)
                }
            )
        }
        .sheet(isPresented: $viewModel.showRegressionModal) {
            if let food = viewModel.regressionTargetFood {
                RegressionModal(
                    food: food,
                    viewModel: viewModel,
                    onDismiss: {
                        viewModel.showRegressionModal = false
                        viewModel.regressionTargetFood = nil
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private var tabPicker: some View {
        HStack(spacing: 6) {
            ForEach(FoodBrowserTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(duration: 0.3)) { browserTab = tab }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.caption2)
                        Text(tab.label)
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                    }
                    .foregroundStyle(browserTab == tab ? SpaceTheme.deepNavy : .white.opacity(0.6))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(browserTab == tab ? SpaceTheme.cosmicCyan : .white.opacity(0.06))
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var recommendedContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                if !viewModel.bridgeSuggestions.isEmpty {
                    bridgeSuggestionsSection
                }

                if viewModel.subscription.hasAccess {
                    if viewModel.foodRecommendations.isEmpty {
                        recommendationEmptyState
                    } else {
                        SmartRecommendationsView(
                            recommendations: viewModel.foodRecommendations,
                            childName: viewModel.profile.explorerDisplayName,
                            onStartQuest: { food in
                                viewModel.setActiveQuest(food: food)
                            },
                            onRefresh: { viewModel.refreshRecommendations() }
                        )
                    }
                } else {
                    upgradeCard
                }
            }
            .padding(16)
            .padding(.bottom, 80)
        }
        .scrollIndicators(.hidden)
    }

    private var bridgeSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.callout)
                    .foregroundStyle(SpaceTheme.cosmicCyan)
                Text("Bridge Suggestions")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }

            ForEach(viewModel.bridgeSuggestions) { suggestion in
                Button {
                    viewModel.setActiveQuest(food: suggestion.bridgeFood)
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(SpaceTheme.planetColor(hex: suggestion.bridgeFood.planetColorHex).opacity(0.2))
                                .frame(width: 44, height: 44)
                            FoodIcon(food: suggestion.bridgeFood, size: 22)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(suggestion.bridgeFood.name)
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text(suggestion.bridgeType.label)
                                    .font(.system(.caption2, design: .rounded, weight: .bold))
                                    .foregroundStyle(SpaceTheme.cosmicCyan)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(SpaceTheme.cosmicCyan.opacity(0.15)))
                            }
                            Text(suggestion.reason)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.4))
                                .lineLimit(1)
                        }

                        Spacer()

                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                            .foregroundStyle(SpaceTheme.cosmicCyan)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(SpaceTheme.cosmicCyan.opacity(0.12), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }

    private var recommendationEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.white.opacity(0.2))
            Text("Complete a few food quests to unlock recommendations")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.03))
        )
    }

    private var upgradeCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile.fill")
                .font(.largeTitle)
                .foregroundStyle(SpaceTheme.nebulaPink)

            Text("Smart Recommendations")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text("Get personalized food suggestions based on your child's sensory profile.")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(SpaceTheme.nebulaPink.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var sortPicker: some View {
        HStack(spacing: 6) {
            ForEach(FoodSortMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.spring(duration: 0.3)) { sortMode = mode }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 9))
                        Text(mode.label)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(sortMode == mode ? SpaceTheme.deepNavy : .white.opacity(0.5))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule().fill(sortMode == mode ? SpaceTheme.starGold : .white.opacity(0.06))
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }

    private var allFoodsContent: some View {
        VStack(spacing: 0) {
            categoryChips
                .padding(.bottom, 4)

            sortPicker
                .padding(.bottom, 8)

            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 20
                ) {
                    ForEach(allFoods) { food in
                        foodGridItem(food)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var categoryChips: some View {
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
    }

    private func categoryChip(_ category: FoodCategory?, label: String, icon: String) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.spring(duration: 0.3)) { selectedCategory = category }
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
                Capsule().fill(isSelected ? SpaceTheme.cosmicCyan : .white.opacity(0.08))
            )
        }
    }

    private func foodGridItem(_ food: FoodItem) -> some View {
        let progress = viewModel.questProgress(for: food.id)
        let isPreCompleted = progress?.isPreCompleted ?? false
        let isEaten = progress.map { viewModel.isEatenProgress($0) } ?? false
        let isInProgress = !isPreCompleted && !isEaten && !(progress?.completedStepValues.isEmpty ?? true)
        let isMastered = isEaten
        let isRegressed = viewModel.isRegressed(foodId: food.id)

        return Button {
            viewModel.setActiveQuest(food: food)
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    PlanetView(food: food, progress: progress)

                    if customFoodIds.contains(food.id) {
                        Text("✦")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(SpaceTheme.cosmicCyan)
                            .offset(x: 28, y: -28)
                    }
                }

                if isRegressed {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.down.right")
                            .font(.system(size: 6, weight: .bold))
                        Text("USED TO EAT")
                            .font(.system(size: 7, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.orange.opacity(0.15)))
                } else if isInProgress {
                    Text("IN PROGRESS")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(SpaceTheme.cosmicCyan.opacity(0.15)))
                } else if isMastered {
                    Text("MASTERED")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundStyle(SpaceTheme.planetGreen)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(SpaceTheme.planetGreen.opacity(0.15)))
                }
            }
        }
        .contextMenu {
            if isMastered && !isRegressed {
                Button {
                    viewModel.beginRegressionFlow(food: food)
                } label: {
                    Label("Used to Eat It", systemImage: "arrow.down.right")
                }

                Button(role: .destructive) {
                    viewModel.resetFoodProgress(foodId: food.id)
                } label: {
                    Label("Reset Progress", systemImage: "arrow.counterclockwise")
                }
            }

            if isRegressed {
                Button {
                    viewModel.reMasterFood(foodId: food.id)
                } label: {
                    Label("Eating It Again!", systemImage: "checkmark.circle.fill")
                }
            }
        }
    }

    private var searchContent: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            ScrollView {
                LazyVStack(spacing: 0) {
                    if isSearching {
                        if searchResults.count >= 3 {
                            HStack {
                                Text("Showing \(searchResults.count) results")
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.4))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                        }

                        if searchResults.isEmpty {
                            searchEmptyState
                        } else {
                            ForEach(searchResults) { food in
                                searchFoodRow(food)
                            }
                            createCustomRow
                                .padding(.top, 4)
                        }
                    } else {
                        ForEach(FoodDatabase.allFoods + viewModel.customFoodItems) { food in
                            searchFoodRow(food)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.4))

            TextField("", text: $searchText, prompt: Text("Search foods...").foregroundStyle(.white.opacity(0.3)))
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
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white.opacity(0.08))
        )
    }

    private func searchFoodRow(_ food: FoodItem) -> some View {
        let progress = viewModel.questProgress(for: food.id)
        let isPreCompleted = progress?.isPreCompleted ?? false
        let isEaten = progress.map { viewModel.isEatenProgress($0) } ?? false
        let isInProgress = !isPreCompleted && !isEaten && !(progress?.completedStepValues.isEmpty ?? true)
        let isMastered = isEaten
        let isRegressed = viewModel.isRegressed(foodId: food.id)

        return Button {
            viewModel.setActiveQuest(food: food)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.2))
                        .frame(width: 44, height: 44)
                    FoodIcon(food: food, size: 22)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(food.name)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white)

                        if customFoodIds.contains(food.id) {
                            Text("CUSTOM")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(SpaceTheme.cosmicCyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(SpaceTheme.cosmicCyan.opacity(0.15)))
                        }
                    }

                    HStack(spacing: 6) {
                        Text(food.color.emoji)
                            .font(.system(size: 10))
                        Text(food.foodGroup.label)
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("·")
                            .foregroundStyle(.white.opacity(0.2))
                        Text("\(food.texture.label) · \(food.flavor.label)")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }

                Spacer()

                if isRegressed {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.down.right")
                            .font(.system(size: 8, weight: .bold))
                        Text("USED TO EAT")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                    }
                    .foregroundStyle(.orange)
                } else if isMastered {
                    Text("MASTERED")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(SpaceTheme.planetGreen)
                } else if isInProgress {
                    Text("\(Int((progress?.progressFraction ?? 0) * 100))%")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .contextMenu {
            if isMastered && !isRegressed {
                Button {
                    viewModel.beginRegressionFlow(food: food)
                } label: {
                    Label("Used to Eat It", systemImage: "arrow.down.right")
                }
            }

            if isRegressed {
                Button {
                    viewModel.reMasterFood(foodId: food.id)
                } label: {
                    Label("Eating It Again!", systemImage: "checkmark.circle.fill")
                }
            }
        }
    }

    private var searchEmptyState: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 30)

            Group {
                if !viewModel.profile.excludedAllergens.isEmpty,
                   UIImage(named: "empty_state_allergen") != nil {
                    Image("empty_state_allergen")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(maxWidth: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else if UIImage(named: "empty_state_pantry") != nil {
                    Image("empty_state_pantry")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(maxWidth: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }

            Text(
                !viewModel.profile.excludedAllergens.isEmpty
                    ? "No safe matches for \"\(searchText)\" with your allergen filters"
                    : "No foods found for \"\(searchText)\""
            )
                
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
            .padding(.horizontal, 20)
        }
    }

    private var createCustomRow: some View {
        Button {
            showCreateFood = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SpaceTheme.cosmicCyan.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Create \"\(searchText)\"")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                    Text("Add as a custom food")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(SpaceTheme.cosmicCyan.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.white.opacity(0.03))
        }
    }
}
