import SwiftUI

struct JourneyMapScreen: View {
    let viewModel: AppViewModel
    @State private var appeared = false
    @State private var showCosmetics = false
    @State private var selectedPlanet: JourneyPlanet?

    private var foodsExplored: Int { viewModel.exploredFoodsCount }
    private var currentPlanet: JourneyPlanet { JourneyPlanet.current(for: foodsExplored) }

    private static let xFractions: [CGFloat] = [0.30, 0.72, 0.25, 0.75, 0.28, 0.68, 0.32, 0.50]
    private let verticalSpacing: CGFloat = 150
    private let nodeSize: CGFloat = 130

    private var mapHeight: CGFloat {
        CGFloat(JourneyPlanet.allCases.count - 1) * verticalSpacing + nodeSize + 80
    }

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

                    boardgameMap
                        .frame(height: mapHeight)

                    Spacer().frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
            .onAppear {
                withAnimation(.spring.delay(0.2)) { appeared = true }
            }

            if viewModel.showRewardUnlocked {
                rewardOverlay
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
    }

    // MARK: - Header

    private var explorerHeader: some View {
        HStack(spacing: 12) {
            Button { showCosmetics = true } label: {
                ExplorerAvatarView(
                    explorerType: viewModel.profile.explorerType,
                    equippedCosmetics: viewModel.profile.equippedCosmetics,
                    size: 48
                )
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

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            journeyStat(icon: "globe.americas.fill", value: "\(foodsExplored)", label: "Explored", color: SpaceTheme.cosmicCyan)
            journeyStat(icon: "checkmark.seal.fill", value: "\(viewModel.completedQuestsCount)", label: "Mastered", color: SpaceTheme.planetGreen)
            if viewModel.profile.currentStreak > 0 {
                journeyStat(icon: "flame.fill", value: "\(viewModel.profile.currentStreak)", label: "Streak", color: .orange)
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

    // MARK: - Boardgame Map

    private var boardgameMap: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let positions = Self.planetPositions(width: width, spacing: verticalSpacing)

            ZStack {
                ForEach(0..<(JourneyPlanet.allCases.count - 1), id: \.self) { i in
                    let from = positions[i]
                    let to = positions[i + 1]
                    let toPlanet = JourneyPlanet.allCases[i + 1]
                    let isLit = !toPlanet.isLocked(totalExplored: foodsExplored)
                    let segmentColor = isLit
                        ? SpaceTheme.planetColor(hex: JourneyPlanet.allCases[i].accentColor)
                        : Color.white

                    CurveConnector(from: from, to: to)
                        .stroke(
                            segmentColor.opacity(isLit ? 0.4 : 0.06),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 8])
                        )
                }

                ForEach(Array(JourneyPlanet.allCases.enumerated()), id: \.element) { index, planet in
                    let pos = positions[index]
                    planetNode(planet)
                        .position(pos)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(duration: 0.5).delay(Double(index) * 0.07), value: appeared)
                }

                let activePos = positions[currentPlanet.rawValue]
                explorerMarker
                    .position(x: activePos.x - 80, y: activePos.y - 20)
                    .animation(.spring(duration: 0.8, bounce: 0.3), value: currentPlanet)
            }
        }
    }

    private static func planetPositions(width: CGFloat, spacing: CGFloat) -> [CGPoint] {
        JourneyPlanet.allCases.map { planet in
            CGPoint(
                x: width * xFractions[planet.rawValue],
                y: 40 + CGFloat(planet.rawValue) * spacing
            )
        }
    }

    // MARK: - Planet Node

    private func planetNode(_ planet: JourneyPlanet) -> some View {
        let isActive = planet == currentPlanet
        let isCompleted = planet.isCompleted(totalExplored: foodsExplored)
        let isLocked = planet.isLocked(totalExplored: foodsExplored)
        let completed = planet.foodsCompleted(totalExplored: foodsExplored)
        let planetColor = SpaceTheme.planetColor(hex: planet.accentColor)

        return Button {
            selectedPlanet = planet
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    if isActive {
                        Circle()
                            .stroke(planetColor.opacity(0.5), lineWidth: 3)
                            .frame(width: nodeSize + 16, height: nodeSize + 16)
                            .modifier(PulseEffect())
                    }

                    Circle()
                        .fill(
                            RadialGradient(
                                colors: isLocked
                                    ? [.gray.opacity(0.2), .gray.opacity(0.05)]
                                    : [planetColor.opacity(0.85), planetColor.opacity(0.25)],
                                center: UnitPoint(x: 0.35, y: 0.35),
                                startRadius: 5,
                                endRadius: nodeSize / 2
                            )
                        )
                        .frame(width: nodeSize, height: nodeSize)
                        .overlay {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(isLocked ? 0.05 : 0.2), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .shadow(color: isLocked ? .clear : planetColor.opacity(0.3), radius: 10)

                    Text(planet.emoji)
                        .font(.system(size: 56))
                        .opacity(isLocked ? 0.2 : 1.0)

                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(SpaceTheme.planetGreen)
                            .background(Circle().fill(SpaceTheme.deepNavy).padding(-2))
                            .offset(x: nodeSize / 2 - 2, y: -(nodeSize / 2 - 2))
                    }

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.2))
                            .offset(x: nodeSize / 2 - 2, y: -(nodeSize / 2 - 2))
                    }

                    if !isLocked && !isCompleted {
                        Circle()
                            .trim(from: 0, to: Double(completed) / Double(JourneyPlanet.foodsPerPlanet))
                            .stroke(planetColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: nodeSize + 4, height: nodeSize + 4)
                            .rotationEffect(.degrees(-90))
                    }
                }

                Text(planet.name)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(isLocked ? .white.opacity(0.2) : .white.opacity(0.85))
                    .lineLimit(1)

                if !isLocked {
                    Text("\(completed)/\(JourneyPlanet.foodsPerPlanet)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(isCompleted ? SpaceTheme.planetGreen : planetColor)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Explorer Marker

    private var explorerMarker: some View {
        ZStack {
            Circle()
                .fill(SpaceTheme.planetColor(hex: viewModel.profile.explorerType.accentHex).opacity(0.25))
                .frame(width: 56, height: 56)

            Image(viewModel.profile.explorerType.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
        }
        .modifier(FloatEffect())
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

// MARK: - Curve Connector Shape

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

// MARK: - Planet Detail Sheet

struct PlanetDetailSheet: View {
    let planet: JourneyPlanet
    let viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    private var foodsExplored: Int { viewModel.exploredFoodsCount }
    private var completed: Int { planet.foodsCompleted(totalExplored: foodsExplored) }
    private var isCompleted: Bool { planet.isCompleted(totalExplored: foodsExplored) }
    private var isLocked: Bool { planet.isLocked(totalExplored: foodsExplored) }
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
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [planetColor.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Text(planet.emoji)
                    .font(.system(size: 56))
                    .opacity(isLocked ? 0.3 : 1.0)
            }

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
                Text("\(completed)/\(JourneyPlanet.foodsPerPlanet) foods")
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
                        .frame(width: geo.size.width * (Double(completed) / Double(JourneyPlanet.foodsPerPlanet)), height: 8)
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

            let remaining = planet.foodsRequired - foodsExplored
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

            if completed < JourneyPlanet.foodsPerPlanet && !isLocked {
                let remaining = JourneyPlanet.foodsPerPlanet - completed
                Text("\(remaining) more food\(remaining == 1 ? "" : "s") to complete this planet!")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(planetColor.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Effects

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
