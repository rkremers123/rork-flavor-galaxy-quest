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
    private var distribution: [Int] { viewModel.planetDistribution }

    private let nodeSize: CGFloat = 140
    private let spaceNodeSize: CGFloat = 36
    private let pathSpacing: CGFloat = 56

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
                        .padding(.bottom, 16)

                    currentProgressCard
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)

                    duolingoPath
                        .padding(.horizontal, 20)

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

    private var currentProgressCard: some View {
        let planet = currentPlanet
        let completed = viewModel.dynamicFoodsCompleted(planet)
        let total = viewModel.dynamicFoodsForPlanet(planet)
        let planetColor = SpaceTheme.planetColor(hex: planet.accentColor)
        let progress = total > 0 ? Double(completed) / Double(total) : 0

        return HStack(spacing: 16) {
            Image(planet.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                .shadow(color: planetColor.opacity(0.4), radius: 8)

            VStack(alignment: .leading, spacing: 6) {
                Text(planet.name)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.1))
                                .frame(height: 6)
                            Capsule()
                                .fill(planetColor)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("\(completed)/\(total)")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(planetColor)
                        .frame(width: 36, alignment: .trailing)
                }

                Text("\(total - completed) food\(total - completed == 1 ? "" : "s") to next planet")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(SpaceTheme.planetColor(hex: viewModel.profile.explorerType.accentHex).opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(viewModel.profile.explorerType.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(planetColor.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Duolingo Path

    private var duolingoPath: some View {
        VStack(spacing: 0) {
            ForEach(Array(JourneyPlanet.allCases.enumerated()), id: \.element) { index, planet in
                let isCompleted = viewModel.dynamicIsPlanetCompleted(planet)
                let isLocked = viewModel.dynamicIsPlanetLocked(planet)
                let isActive = planet == currentPlanet
                let planetFoods = viewModel.dynamicFoodsForPlanet(planet)
                let completed = viewModel.dynamicFoodsCompleted(planet)
                let planetColor = SpaceTheme.planetColor(hex: planet.accentColor)

                planetRow(
                    planet: planet,
                    planetColor: planetColor,
                    isCompleted: isCompleted,
                    isLocked: isLocked,
                    isActive: isActive,
                    planetFoods: planetFoods,
                    completed: completed,
                    index: index
                )

                if isActive || (isCompleted && index < JourneyPlanet.allCases.count - 1) {
                    spacesRow(
                        planet: planet,
                        planetColor: planetColor,
                        completed: completed,
                        total: planetFoods,
                        isActive: isActive,
                        isCompleted: isCompleted
                    )
                }

                if index < JourneyPlanet.allCases.count - 1 {
                    connectorLine(isLit: !viewModel.dynamicIsPlanetLocked(JourneyPlanet.allCases[index + 1]))
                }
            }
        }
    }

    private func planetRow(
        planet: JourneyPlanet,
        planetColor: Color,
        isCompleted: Bool,
        isLocked: Bool,
        isActive: Bool,
        planetFoods: Int,
        completed: Int,
        index: Int
    ) -> some View {
        Button { selectedPlanet = planet } label: {
            HStack(spacing: 16) {
                ZStack {
                    if isActive {
                        Circle()
                            .stroke(planetColor.opacity(0.4), lineWidth: 2.5)
                            .frame(width: 76, height: 76)
                            .modifier(PulseEffect())
                    }

                    Image(planet.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 68, height: 68)
                        .clipShape(Circle())
                        .opacity(isLocked ? 0.2 : 1.0)
                        .shadow(color: isLocked ? .clear : planetColor.opacity(0.35), radius: 10)

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(SpaceTheme.planetGreen)
                            .background(Circle().fill(SpaceTheme.deepNavy).padding(-2))
                            .offset(x: 26, y: -26)
                    }

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.25))
                    }
                }
                .frame(width: 80, height: 80)

                VStack(alignment: .leading, spacing: 4) {
                    Text(planet.name)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(isLocked ? .white.opacity(0.2) : .white)

                    Text(planet.subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(isLocked ? .white.opacity(0.1) : .white.opacity(0.4))

                    if !isLocked {
                        HStack(spacing: 6) {
                            Text("\(completed)/\(planetFoods) foods")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(isCompleted ? SpaceTheme.planetGreen : planetColor)

                            if isActive {
                                Text("ACTIVE")
                                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                                    .foregroundStyle(SpaceTheme.deepNavy)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(planetColor))
                            }
                        }
                    }
                }

                Spacer()

                if !isLocked {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isActive ? planetColor.opacity(0.06) : .white.opacity(0.02))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isActive ? planetColor.opacity(0.2) : .clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(duration: 0.5).delay(Double(index) * 0.06), value: appeared)
    }

    private func spacesRow(
        planet: JourneyPlanet,
        planetColor: Color,
        completed: Int,
        total: Int,
        isActive: Bool,
        isCompleted: Bool
    ) -> some View {
        HStack(spacing: 6) {
            Spacer().frame(width: 22)

            ForEach(0..<total, id: \.self) { i in
                let isFilled = i < completed
                let isExplorerHere = isActive && i == completed && !isCompleted

                ZStack {
                    if isExplorerHere {
                        Circle()
                            .fill(SpaceTheme.planetColor(hex: viewModel.profile.explorerType.accentHex).opacity(0.3))
                            .frame(width: spaceNodeSize + 8, height: spaceNodeSize + 8)

                        Image(viewModel.profile.explorerType.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: spaceNodeSize, height: spaceNodeSize)
                            .modifier(FloatEffect())
                    } else if isFilled {
                        Image("cosmic_connector_star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: spaceNodeSize - 4, height: spaceNodeSize - 4)
                            .opacity(0.8)
                    } else {
                        Circle()
                            .fill(.white.opacity(0.06))
                            .frame(width: spaceNodeSize - 8, height: spaceNodeSize - 8)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                }
                .frame(width: spaceNodeSize, height: spaceNodeSize)
                .animation(.spring(duration: 0.5), value: completed)
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.leading, 14)
    }

    private func connectorLine(isLit: Bool) -> some View {
        HStack {
            Spacer().frame(width: 54)
            Rectangle()
                .fill(isLit ? .white.opacity(0.1) : .white.opacity(0.03))
                .frame(width: 2, height: 16)
            Spacer()
        }
    }

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

struct CurveConnector: Shape {
    let from: CGPoint
    let to: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        let midY = (from.y + to.y) / 2
        path.addCurve(
            to: to,
            control1: CGPoint(x: from.x, y: midY),
            control2: CGPoint(x: to.x, y: midY)
        )
        return path
    }
}

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

struct FloatEffect: ViewModifier {
    @State private var floating = false

    func body(content: Content) -> some View {
        content
            .offset(y: floating ? -5 : 5)
            .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: floating)
            .onAppear { floating = true }
    }
}
