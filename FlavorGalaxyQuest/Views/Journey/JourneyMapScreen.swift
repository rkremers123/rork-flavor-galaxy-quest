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

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        explorerHeader
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 12)

                        statsRow
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        planetJourney
                            .padding(.horizontal, 20)

                        Spacer().frame(height: 120)
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

    // MARK: - Two-Planet Journey

    private var planetJourney: some View {
        VStack(spacing: 0) {
            ForEach(Array(JourneyPlanet.allCases.enumerated()), id: \.element) { index, planet in
                let isActive = planet == currentPlanet
                let isCompleted = viewModel.dynamicIsPlanetCompleted(planet)
                let isLocked = viewModel.dynamicIsPlanetLocked(planet)

                planetSegment(planet: planet, isActive: isActive, isCompleted: isCompleted, isLocked: isLocked)
                    .id(planet)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(.spring(duration: 0.6).delay(Double(index) * 0.08), value: appeared)

                if index < JourneyPlanet.allCases.count - 1 {
                    waveConnector(fromIndex: index)
                }
            }
        }
    }

    private func planetSegment(planet: JourneyPlanet, isActive: Bool, isCompleted: Bool, isLocked: Bool) -> some View {
        let completed = viewModel.dynamicFoodsCompleted(planet)
        let total = viewModel.dynamicFoodsForPlanet(planet)
        let planetColor = SpaceTheme.planetColor(hex: planet.accentColor)
        let planetSize: CGFloat = 220

        return Button {
            if !isLocked {
                selectedPlanet = planet
            }
        } label: {
            VStack(spacing: 0) {
                ZStack {
                    if isActive {
                        Circle()
                            .stroke(planetColor.opacity(0.4), lineWidth: 3)
                            .frame(width: planetSize + 20, height: planetSize + 20)
                            .modifier(PulseEffect())
                    }

                    if !isLocked && !isCompleted && total > 0 {
                        Circle()
                            .trim(from: 0, to: Double(completed) / Double(total))
                            .stroke(planetColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: planetSize + 10, height: planetSize + 10)
                            .rotationEffect(.degrees(-90))
                    }

                    Image(planet.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: planetSize, height: planetSize)
                        .clipShape(Circle())
                        .opacity(isLocked ? 0.35 : (isCompleted ? 0.6 : 1.0))
                        .saturation(isLocked ? 0.3 : 1.0)
                        .shadow(color: isLocked ? .clear : planetColor.opacity(0.5), radius: 16)

                    if isActive {
                        explorerOnCurrentPlanet
                    }

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(SpaceTheme.planetGreen)
                            .background(Circle().fill(SpaceTheme.deepNavy).padding(-4))
                            .offset(x: planetSize / 2 - 10, y: -(planetSize / 2 - 10))
                    }

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white.opacity(0.25))
                    }
                }

                Spacer().frame(height: 14)

                Text(planet.name)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(isLocked ? .white.opacity(0.25) : .white)
                    .lineLimit(1)

                Text(planet.subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(isLocked ? .white.opacity(0.15) : .white.opacity(0.5))

                if !isLocked {
                    Text("\(completed)/\(total) foods")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(isCompleted ? SpaceTheme.planetGreen : planetColor)
                        .padding(.top, 4)
                }
            }
            .padding(.vertical, 24)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    private var explorerOnCurrentPlanet: some View {
        let completed = viewModel.dynamicFoodsCompleted(currentPlanet)
        let total = viewModel.dynamicFoodsForPlanet(currentPlanet)
        let progress = total > 0 ? Double(completed) / Double(total) : 0
        let yOffset: CGFloat = -CGFloat(progress) * 30

        return ExplorerAvatarView(
            explorerType: viewModel.profile.explorerType,
            equippedCosmetics: viewModel.profile.equippedCosmetics,
            size: 90
        )
        .shadow(color: SpaceTheme.planetColor(hex: viewModel.profile.explorerType.accentHex).opacity(0.6), radius: 16)
        .offset(y: yOffset - 10)
        .animation(.spring(duration: 0.6), value: completed)
        .zIndex(20)
    }

    // MARK: - Wave Connector

    private func waveConnector(fromIndex index: Int) -> some View {
        let currentPlanetAtIndex = JourneyPlanet.allCases[index]
        let nextPlanet = JourneyPlanet.allCases[index + 1]
        let isCompleted = viewModel.dynamicIsPlanetCompleted(currentPlanetAtIndex)
        let isNextActive = !viewModel.dynamicIsPlanetLocked(nextPlanet)
        let isLocked = !isNextActive && !isCompleted

        return WaveConnectorView(
            isCompleted: isCompleted,
            isActive: isNextActive && !isCompleted,
            isLocked: isLocked
        )
        .frame(height: 120)
        .padding(.vertical, -8)
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

// MARK: - Wave Connector View

struct WaveConnectorView: View {
    let isCompleted: Bool
    let isActive: Bool
    let isLocked: Bool

    @State private var shimmer: Bool = false

    private var connectorOpacity: Double {
        if isLocked { return 0.15 }
        if isCompleted { return 0.5 }
        return 0.4
    }

    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2
            let amplitude: CGFloat = 30

            var path = Path()
            path.move(to: CGPoint(x: midX, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: midX, y: size.height * 0.5),
                control: CGPoint(x: midX - amplitude, y: size.height * 0.25)
            )
            path.addQuadCurve(
                to: CGPoint(x: midX, y: size.height),
                control: CGPoint(x: midX + amplitude, y: size.height * 0.75)
            )

            if isLocked {
                context.stroke(
                    path,
                    with: .color(.white.opacity(0.2)),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 6])
                )
            } else {
                let gradient = Gradient(colors: [
                    SpaceTheme.cosmicCyan,
                    SpaceTheme.starGold,
                    Color(red: 0.91, green: 0.12, blue: 0.39)
                ])
                let linearGradient = GraphicsContext.Shading.linearGradient(
                    gradient,
                    startPoint: CGPoint(x: midX, y: 0),
                    endPoint: CGPoint(x: midX, y: size.height)
                )

                context.addFilter(.shadow(color: SpaceTheme.cosmicCyan.opacity(0.3), radius: 6))
                context.stroke(
                    path,
                    with: linearGradient,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
            }

            if (isActive || isCompleted) && !isLocked {
                let dotPositions: [CGFloat] = [0.2, 0.5, 0.8]
                for t in dotPositions {
                    let y = size.height * t
                    let controlFactor = t < 0.5
                        ? -amplitude * (1 - abs(t - 0.25) / 0.25)
                        : amplitude * (1 - abs(t - 0.75) / 0.25)
                    let x = midX + controlFactor * 0.5

                    let dotSize: CGFloat = shimmer ? 4 : 3
                    let dotOpacity = shimmer ? 0.8 : 0.4
                    let rect = CGRect(x: x - dotSize / 2, y: y - dotSize / 2, width: dotSize, height: dotSize)
                    context.fill(
                        Circle().path(in: rect),
                        with: .color(SpaceTheme.starGold.opacity(dotOpacity))
                    )
                }
            }
        }
        .opacity(connectorOpacity)
        .onAppear {
            if isActive || isCompleted {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    shimmer = true
                }
            }
        }
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
