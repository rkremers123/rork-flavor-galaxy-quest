import SwiftUI

struct JourneyMapScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var appeared = false
    @State private var showCosmetics = false
    @State private var selectedPlanet: JourneyPlanet?
    @State private var showStreakBanner = false
    @State private var showExplorerDetail = false

    private var foodsExplored: Int { viewModel.exploredFoodsCount }
    private var currentPlanet: JourneyPlanet { viewModel.dynamicCurrentPlanet }

    private let nodeSize: CGFloat = 160
    private let columns = 2

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            ScrollView {
                VStack(spacing: 0) {
                    explorerHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    statsRow
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    boardgameGrid
                        .padding(.horizontal, 12)

                    Spacer().frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
            .onAppear {
                withAnimation(.spring.delay(0.2)) { appeared = true }
                if viewModel.showStreakBroken {
                    withAnimation(.spring.delay(0.6)) { showStreakBanner = true }
                    viewModel.showStreakBroken = false
                }
            }

            if viewModel.showRewardUnlocked {
                rewardOverlay
            }

            if showStreakBanner {
                streakBrokenBanner
            }
        }
        .sheet(item: $selectedPlanet) { planet in
            PlanetDetailSheet(planet: planet, viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(SpaceTheme.deepNavy)
                .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $showCosmetics) {
            CosmeticsView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showExplorerDetail) {
            ExplorerDetailModal(viewModel: viewModel, showCosmetics: $showCosmetics)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationBackground(SpaceTheme.deepNavy)
        }
    }

    // MARK: - Header

    private var explorerHeader: some View {
        HStack(spacing: 14) {
            Button { showExplorerDetail = true } label: {
                ExplorerAvatarView(
                    explorerType: viewModel.profile.explorerType,
                    equippedCosmetics: viewModel.profile.equippedCosmetics,
                    size: 64
                )
                .overlay {
                    Circle()
                        .stroke(
                            SpaceTheme.planetColor(hex: viewModel.profile.explorerType.accentHex),
                            lineWidth: 2
                        )
                        .frame(width: 68, height: 68)
                }
            }
            .scaleEffect(1.0)

            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.profile.explorerDisplayName)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                LevelBadgeView(
                    level: viewModel.profile.currentLevel,
                    progress: viewModel.profile.levelProgress
                )
            }

            Spacer()

            StarDustCounter(amount: viewModel.profile.totalStarDust)
        }
    }

    private var streakBrokenBanner: some View {
        VStack {
            HStack(spacing: 12) {
                Text("💔")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Streak broken")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Start a new one today!")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Button {
                    withAnimation(.spring) { showStreakBanner = false }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.top, 60)

            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(10)
        .onAppear {
            Task {
                try? await Task.sleep(for: .seconds(4))
                withAnimation(.spring) { showStreakBanner = false }
            }
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            journeyStat(icon: "globe.americas.fill", value: "\(foodsExplored)", label: "Explored", color: SpaceTheme.cosmicCyan)
            journeyStat(icon: "checkmark.seal.fill", value: "\(viewModel.completedQuestsCount)", label: "Mastered", color: SpaceTheme.planetGreen)
            streakStat
        }
    }

    private var streakStat: some View {
        Group {
            if viewModel.profile.currentStreak > 0 {
                journeyStat(icon: "flame.fill", value: "\(viewModel.profile.currentStreak)", label: "Streak", color: .orange)
            } else if viewModel.profile.longestStreak > 0 {
                journeyStat(icon: "flame", value: "\(viewModel.profile.longestStreak)", label: "Best", color: .orange.opacity(0.5))
            }
        }
    }

    private func journeyStat(icon: String, value: String, label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(.white.opacity(0.06)))
    }

    // MARK: - Boardgame Grid

    private var boardgameGrid: some View {
        VStack(spacing: 24) {
            ForEach(Array(JourneyPlanet.allCases.enumerated()), id: \.element) { index, planet in
                let isEvenRow = index % 2 == 0

                HStack {
                    if !isEvenRow { Spacer() }

                    planetNode(planet)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(duration: 0.5).delay(Double(index) * 0.08), value: appeared)

                    if isEvenRow { Spacer() }
                }

                if index < JourneyPlanet.allCases.count - 1 {
                    connectorDots(from: index)
                }
            }
        }
    }

    private func planetNode(_ planet: JourneyPlanet) -> some View {
        let isActive = planet == currentPlanet
        let isCompleted = viewModel.dynamicIsPlanetCompleted(planet)
        let isLocked = viewModel.dynamicIsPlanetLocked(planet)
        let completed = viewModel.dynamicFoodsCompleted(planet)
        let total = viewModel.dynamicFoodsForPlanet(planet)
        let planetColor = SpaceTheme.planetColor(hex: planet.accentColor)

        return Button {
            selectedPlanet = planet
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    if isActive {
                        Circle()
                            .stroke(planetColor.opacity(0.5), lineWidth: 3)
                            .frame(width: nodeSize + 16, height: nodeSize + 16)
                            .modifier(PulseEffect())
                    }

                    Image(planet.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: nodeSize, height: nodeSize)
                        .clipShape(Circle())
                        .opacity(isLocked ? 0.25 : 1.0)
                        .shadow(color: isLocked ? .clear : planetColor.opacity(0.4), radius: 12)

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(SpaceTheme.planetGreen)
                            .background(Circle().fill(SpaceTheme.deepNavy).padding(-3))
                            .offset(x: nodeSize / 2 - 6, y: -(nodeSize / 2 - 6))
                    }

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.3))
                    }

                    if !isLocked && !isCompleted && total > 0 {
                        Circle()
                            .trim(from: 0, to: Double(completed) / Double(total))
                            .stroke(planetColor, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                            .frame(width: nodeSize + 6, height: nodeSize + 6)
                            .rotationEffect(.degrees(-90))
                    }
                }

                Text(planet.name)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(isLocked ? .white.opacity(0.2) : .white.opacity(0.9))
                    .lineLimit(1)

                if !isLocked {
                    Text("\(completed)/\(total)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(isCompleted ? SpaceTheme.planetGreen : planetColor)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func connectorDots(from index: Int) -> some View {
        let nextPlanet = JourneyPlanet.allCases[index + 1]
        let isLit = !viewModel.dynamicIsPlanetLocked(nextPlanet)

        return HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { dot in
                Circle()
                    .fill(isLit ? .white.opacity(0.25) : .white.opacity(0.06))
                    .frame(width: 6, height: 6)
            }
        }
    }

    // MARK: - Reward Overlay

    private var rewardOverlay: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring) { viewModel.showRewardUnlocked = false }
                }

            VStack(spacing: 24) {
                Text("📡").font(.system(size: 60))

                Text("Transmission from Earth!")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                Text("You earned your reward:")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                Text(viewModel.profile.starJarRewardName)
                    .font(.system(.title, design: .rounded, weight: .heavy))
                    .foregroundStyle(SpaceTheme.starGold)

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

// MARK: - Planet Detail Sheet

struct PlanetDetailSheet: View {
    let planet: JourneyPlanet
    let viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    private var completed: Int { viewModel.dynamicFoodsCompleted(planet) }
    private var totalFoods: Int { viewModel.dynamicFoodsForPlanet(planet) }
    private var isCompleted: Bool { viewModel.dynamicIsPlanetCompleted(planet) }
    private var isLocked: Bool { viewModel.dynamicIsPlanetLocked(planet) }
    private var planetColor: Color { SpaceTheme.planetColor(hex: planet.accentColor) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    planetHeader
                    progressSection

                    if isLocked {
                        lockedMessage
                    } else {
                        conqueredFoodsList
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }
            }
        }
    }

    private var planetHeader: some View {
        VStack(spacing: 12) {
            Image(planet.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .opacity(isLocked ? 0.3 : 1.0)
                .shadow(color: planetColor.opacity(0.4), radius: 12)

            Text(planet.name)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text(planet.subtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))

            if isCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(SpaceTheme.planetGreen)
                    Text("Complete!")
                        .foregroundStyle(SpaceTheme.planetGreen)
                }
                .font(.system(.subheadline, design: .rounded, weight: .bold))
            }
        }
    }

    private var progressSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Progress")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Text("\(completed)/\(totalFoods) foods")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(isCompleted ? SpaceTheme.planetGreen : planetColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.08))
                        .frame(height: 8)
                    Capsule()
                        .fill(isCompleted ? SpaceTheme.planetGreen : planetColor)
                        .frame(width: geo.size.width * (totalFoods > 0 ? Double(completed) / Double(totalFoods) : 0), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.04))
        )
    }

    private var lockedMessage: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.15))

            let required = DynamicDifficultyService.foodsRequiredForPlanet(planet, distribution: viewModel.planetDistribution)
            let remaining = required - viewModel.exploredFoodsCount
            Text("Explore \(remaining) more food\(remaining == 1 ? "" : "s") to unlock!")
                .font(.system(.callout, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Text("Keep going, Explorer!")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(SpaceTheme.cosmicCyan.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.03))
        )
    }

    private var conqueredFoodsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Conquered Foods")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white.opacity(0.6))

            let foods = viewModel.foodsForPlanet(planet)
            if foods.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "sparkle")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.15))
                    Text("Start exploring to conquer foods!")
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(foods, id: \.id) { food in
                    let progress = viewModel.questProgress(for: food.id)
                    HStack(spacing: 14) {
                        Text(food.emoji)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle().fill(SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.15))
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(food.name)
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(.white)

                            let stepsCompleted = progress?.completedSteps.count ?? 0
                            let totalSteps = SensoryStep.allCases.count
                            Text("\(stepsCompleted)/\(totalSteps) phases")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.4))
                        }

                        Spacer()

                        if progress?.isComplete ?? false {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(SpaceTheme.planetGreen)
                        } else {
                            ProgressRing(progress: progress?.progressFraction ?? 0)
                                .frame(width: 28, height: 28)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white.opacity(0.04))
                    )
                }
            }

            if completed < totalFoods && !isLocked {
                let remaining = totalFoods - completed
                Text("\(remaining) more food\(remaining == 1 ? "" : "s") to complete this planet!")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(planetColor.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
        }
    }
}

struct PulseEffect: ViewModifier {
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(pulse ? 1.06 : 1.0)
            .opacity(pulse ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)
            .onAppear { pulse = true }
    }
}
