import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: AppViewModel?

    var body: some View {
        ZStack {
            if let viewModel {
                ZStack {
                    switch viewModel.mode {
                    case .parentOnboarding:
                        ParentOnboardingView(
                            onCreateProfile: { viewModel.finishParentOnboarding() },
                            onSkip: { viewModel.skipParentOnboarding() }
                        )
                        .transition(.opacity)

                    case .onboarding:
                        OnboardingView(viewModel: viewModel)
                            .transition(.opacity)

                    case .explorer:
                        MainTabView(viewModel: viewModel)
                            .transition(.opacity)

                    case .parentDashboard:
                        ParentDashboardView(viewModel: viewModel)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }

                    if viewModel.isTransitioning {
                        WarpTransitionView()
                            .transition(.opacity)
                            .zIndex(100)
                    }

                    if viewModel.showLevelUp, let level = viewModel.newLevelReached {
                        LevelUpCelebrationView(
                            level: level,
                            explorerType: viewModel.profile.explorerType,
                            onDismiss: { viewModel.dismissLevelUp() }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .zIndex(200)
                    }

                    if viewModel.showPlanetCelebration, let planet = viewModel.celebratedPlanet {
                        PlanetCelebrationView(
                            planet: planet,
                            explorerType: viewModel.profile.explorerType,
                            onComplete: { viewModel.dismissPlanetCelebration() }
                        )
                        .transition(.opacity)
                        .zIndex(300)
                    }

                    if viewModel.showPlanetWisdom, let planet = viewModel.wisdomPlanet {
                        PlanetWisdomModal(
                            planet: planet,
                            onContinue: { viewModel.dismissPlanetWisdom() }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .zIndex(350)
                    }

                    if viewModel.showCertificate {
                        CertificateView(
                            childName: viewModel.profile.explorerDisplayName,
                            explorerType: viewModel.profile.explorerType,
                            foodsExplored: viewModel.exploredFoodsCount,
                            starDust: viewModel.profile.totalStarDust,
                            daysActive: max(Calendar.current.dateComponents([.day], from: viewModel.profile.createdDate, to: Date()).day ?? 0 + 1, 1),
                            onDismiss: { viewModel.showCertificate = false }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        .zIndex(400)
                    }
                }
                .animation(.spring(duration: 0.5), value: viewModel.mode == .parentOnboarding)
                .animation(.spring(duration: 0.5), value: viewModel.mode == .onboarding)
                .animation(.spring(duration: 0.5), value: viewModel.mode == .explorer)
                .animation(.spring(duration: 0.5), value: viewModel.mode == .parentDashboard)
                .animation(.spring(duration: 0.4), value: viewModel.showLevelUp)
                .animation(.spring(duration: 0.5), value: viewModel.showPlanetCelebration)
                .animation(.spring(duration: 0.4), value: viewModel.showPlanetWisdom)
                .animation(.spring(duration: 0.5), value: viewModel.showCertificate)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if viewModel == nil {
                viewModel = AppViewModel(modelContext: modelContext)
            }
        }
    }
}

struct MainTabView: View {
    @Bindable var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch viewModel.selectedTab {
                case 1:
                    ActiveQuestScreen(viewModel: viewModel)
                case 2:
                    FoodBrowserScreen(viewModel: viewModel)
                default:
                    JourneyMapScreen(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            KidGalaxyTabBar(selectedTab: $viewModel.selectedTab)
        }
        .background(SGColor.galaxyBackground.ignoresSafeArea())
    }
}

/// Kid-visible tabs only: Journey, Quest, Foods. No Settings / Parent / Paywall / Dashboard.
struct KidGalaxyTabBar: View {
    @Binding var selectedTab: Int

    private let items: [(id: Int, title: String, icon: String)] = [
        (0, "Journey", "map.fill"),
        (1, "Quest", "star.circle.fill"),
        (2, "Foods", "fork.knife"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.id) { item in
                let selected = selectedTab == item.id
                Button {
                    selectedTab = item.id
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 22, weight: .semibold))
                        Text(item.title)
                            .font(SGFont.caption())
                    }
                    .foregroundStyle(selected ? SGColor.gold : SGColor.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.title)
                .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            SGColor.void
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(SGColor.glow.opacity(0.35))
                        .frame(height: 1)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }
}
