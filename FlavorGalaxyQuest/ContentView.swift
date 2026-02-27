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
                }
                .animation(.spring(duration: 0.5), value: viewModel.mode == .onboarding)
                .animation(.spring(duration: 0.5), value: viewModel.mode == .explorer)
                .animation(.spring(duration: 0.5), value: viewModel.mode == .parentDashboard)
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
