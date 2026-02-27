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
                    case .onboarding:
                        OnboardingView(viewModel: viewModel)
                            .transition(.opacity)

                    case .explorer:
                        GalaxyMapView(viewModel: viewModel)
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
                }
                .animation(.spring(duration: 0.5), value: viewModel.mode == .onboarding)
                .animation(.spring(duration: 0.5), value: viewModel.mode == .explorer)
                .animation(.spring(duration: 0.5), value: viewModel.mode == .parentDashboard)
                .animation(.spring(duration: 0.4), value: viewModel.showLevelUp)
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
