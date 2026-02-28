import SwiftUI

struct JourneyMapScreen: View {
    let viewModel: AppViewModel
    @State private var appeared = false
    @State private var showCosmetics = false

    private var foodsExplored: Int { viewModel.exploredFoodsCount }
    private var currentPlanet: JourneyPlanet { JourneyPlanet.current(for: foodsExplored) }

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        explorerHeader
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 16)

                        statsRow
                            .padding(.horizontal, 20)
                            .padding(.bottom, 28)

                        ForEach(JourneyPlanet.allCases, id: \.self) { planet in
                            VStack(spacing: 0) {
                                planetNode(planet)
                                    .id(planet)

                                if planet != .harvestFestival {
                                    pathConnector(from: planet)
                                }
                            }
                        }

                        Spacer().frame(height: 100)
                    }
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    withAnimation(.spring.delay(0.2)) { appeared = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(duration: 0.8)) {
                            proxy.scrollTo(currentPlanet, anchor: .center)
                        }
                    }
                }
            }

            if viewModel.showRewardUnlocked {
                rewardOverlay
            }
        }
        .sheet(isPresented: $showCosmetics) {
            CosmeticsView(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

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

    private func planetNode(_ planet: JourneyPlanet) -> some View {
        let isActive = planet == currentPlanet
        let isCompleted = planet.isCompleted(totalExplored: foodsExplored)
        let isLocked = planet.isLocked(totalExplored: foodsExplored)
        let completed = planet.foodsCompleted(totalExplored: foodsExplored)
        let planetColor = SpaceTheme.planetColor(hex: planet.accentColor)
        let xOffset: CGFloat = {
            switch planet.rawValue {
            case 1, 3: return 28
            case 2: return -28
            default: return 0
            }
        }()

        return VStack(spacing: 14) {
            ZStack {
                if isActive {
                    Circle()
                        .fill(planetColor.opacity(0.1))
                        .frame(width: 150, height: 150)

                    Circle()
                        .stroke(planetColor.opacity(0.4), lineWidth: 3)
                        .frame(width: 140, height: 140)
                        .modifier(PulseEffect())
                }

                Circle()
                    .fill(
                        RadialGradient(
                            colors: isLocked
                                ? [.gray.opacity(0.25), .gray.opacity(0.08)]
                                : [planetColor.opacity(0.85), planetColor.opacity(0.3)],
                            center: UnitPoint(x: 0.35, y: 0.35),
                            startRadius: 5,
                            endRadius: 55
                        )
                    )
                    .frame(width: 110, height: 110)
                    .overlay {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.white.opacity(isLocked ? 0.08 : 0.25), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .shadow(color: isLocked ? .clear : planetColor.opacity(0.3), radius: 12)

                Text(planet.emoji)
                    .font(.system(size: 48))
                    .opacity(isLocked ? 0.25 : 1.0)

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(SpaceTheme.planetGreen)
                        .background(Circle().fill(SpaceTheme.deepNavy).padding(-3))
                        .offset(x: 44, y: -44)
                }

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.25))
                        .offset(x: 44, y: -44)
                }

                if isActive {
                    Text(viewModel.profile.explorerType.emoji)
                        .font(.title2)
                        .offset(x: -68)
                        .modifier(FloatEffect())
                }
            }

            VStack(spacing: 6) {
                Text(planet.name)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(isLocked ? .white.opacity(0.25) : .white)

                Text(planet.subtitle)
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(isLocked ? .white.opacity(0.15) : .white.opacity(0.5))

                if !isLocked {
                    HStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.white.opacity(0.1))
                                    .frame(height: 6)
                                Capsule()
                                    .fill(isCompleted ? SpaceTheme.planetGreen : planetColor)
                                    .frame(width: geo.size.width * (Double(completed) / Double(JourneyPlanet.foodsPerPlanet)), height: 6)
                            }
                        }
                        .frame(width: 100, height: 6)

                        Text("\(completed)/\(JourneyPlanet.foodsPerPlanet)")
                            .font(.system(.caption2, design: .rounded, weight: .bold))
                            .foregroundStyle(isCompleted ? SpaceTheme.planetGreen : planetColor)
                    }
                } else {
                    Text("Explore \(planet.foodsRequired) foods to unlock")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
        }
        .padding(.vertical, 16)
        .offset(x: xOffset)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 30)
        .animation(.spring(duration: 0.6).delay(Double(planet.rawValue) * 0.1), value: appeared)
    }

    private func pathConnector(from planet: JourneyPlanet) -> some View {
        let nextPlanet = JourneyPlanet(rawValue: planet.rawValue + 1)
        let isConnected = nextPlanet.map { !$0.isLocked(totalExplored: foodsExplored) } ?? false
        let planetColor = SpaceTheme.planetColor(hex: planet.accentColor)

        return VStack(spacing: 5) {
            ForEach(0..<4, id: \.self) { _ in
                Circle()
                    .fill(isConnected ? planetColor.opacity(0.4) : .white.opacity(0.08))
                    .frame(width: 4, height: 4)
            }
        }
        .frame(height: 36)
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
