import SwiftUI

struct ContentView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
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
        }
        .animation(.spring(duration: 0.5), value: viewModel.mode == .onboarding)
        .animation(.spring(duration: 0.5), value: viewModel.mode == .explorer)
        .animation(.spring(duration: 0.5), value: viewModel.mode == .parentDashboard)
        .preferredColorScheme(.dark)
    }
}
