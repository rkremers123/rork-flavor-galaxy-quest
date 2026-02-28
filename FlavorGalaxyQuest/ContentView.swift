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
                            explorerEmoji: viewModel.profile.explorerType.emoji,
                            onDismiss: { viewModel.dismissLevelUp() }
                        )
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .zIndex(200)
                    }

                    if viewModel.showPlanetCelebration, let planet = viewModel.celebratedPlanet {
                        PlanetCelebrationView(
                            planet: planet,
                            explorerEmoji: viewModel.profile.explorerType.emoji,
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
        TabView(selection: $viewModel.selectedTab) {
            JourneyMapScreen(viewModel: viewModel)
                .tabItem {
                    Label("Journey", systemImage: "map.fill")
                }
                .tag(0)

            ActiveQuestScreen(viewModel: viewModel)
                .tabItem {
                    Label("Quest", systemImage: "star.circle.fill")
                }
                .tag(1)

            FoodBrowserScreen(viewModel: viewModel)
                .tabItem {
                    Label("Foods", systemImage: "fork.knife")
                }
                .tag(2)

            SettingsScreen(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(SpaceTheme.cosmicCyan)
    }
}
