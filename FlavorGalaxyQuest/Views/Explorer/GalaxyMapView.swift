import SwiftUI

struct GalaxyMapView: View {
    let viewModel: AppViewModel
    @State private var selectedFood: FoodItem?
    @State private var showParentGate: Bool = false
    @State private var parentGateProgress: CGFloat = 0
    @State private var appeared: Bool = false
    @State private var selectedCategory: FoodCategory? = nil

    private var displayedFoods: [FoodItem] {
        if let category = selectedCategory {
            return FoodDatabase.allFoods.filter { $0.category == category }
        }
        return FoodDatabase.allFoods
    }

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            VStack(spacing: 0) {
                header
                categoryFilter
                planetGrid
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
        .onAppear {
            withAnimation(.spring.delay(0.2)) { appeared = true }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Flavor Galaxy")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                HStack(spacing: 8) {
                    Text("Hi, \(viewModel.profile.name.isEmpty ? "Explorer" : viewModel.profile.name)!")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
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
                starJarBanner
                    .padding(.horizontal, 20)

                if let suggestion = viewModel.bridgeSuggestions.first {
                    bridgeSuggestionBanner(suggestion)
                        .padding(.horizontal, 20)
                }
            }

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
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(duration: 0.5).delay(Double(index) * 0.03), value: appeared)
                    .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedFood?.id == food.id)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
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

                    Image(systemName: viewModel.profile.starJar.rewardUnlocked ? "gift.fill" : "star.circle.fill")
                        .font(.title2)
                        .foregroundStyle(SpaceTheme.starGold)
                        .symbolEffect(.pulse)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.profile.starJar.rewardUnlocked ? "Reward Unlocked!" : "Star Jar")
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
                                        colors: viewModel.profile.starJar.rewardUnlocked
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

                Text("\(viewModel.profile.totalStarDust)/\(viewModel.profile.starJar.targetStarDust)")
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

                Text(viewModel.profile.starJar.rewardName)
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
