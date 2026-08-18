import SwiftUI

/// First-run parent beats for Sensory Galaxy.
/// ContentView already wires:
///   onCreateProfile → viewModel.finishParentOnboarding()
///   onSkip          → viewModel.skipParentOnboarding()
/// Three full-screen beats on SpaceBackground. No cream, no TabView, no systemGray.
struct ParentOnboardingView: View {
    let onCreateProfile: () -> Void
    let onSkip: () -> Void

    @State private var currentBeat: Int = 0
    @State private var appeared: Bool = false

    private let totalBeats = 3

    var body: some View {
        SGScreen {
            VStack(spacing: 0) {
                SGDotBar(count: totalBeats, index: currentBeat)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                beatStack
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(SGMotion.step) { appeared = true }
        }
    }

    @ViewBuilder
    private var beatStack: some View {
        ZStack {
            switch currentBeat {
            case 0: explorerBeat
            case 1: phasesBeat
            default: progressBeat
            }
        }
        .id(currentBeat)
        .transition(
            .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 12)),
                removal: .opacity
            )
        )
        .animation(SGMotion.step, value: currentBeat)
        .padding(.horizontal, 24)
    }

    // MARK: - Beat 0 — explorer

    private var explorerBeat: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("explorer_nova")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .scaleEffect(appeared ? 1 : 0.86)
                .opacity(appeared ? 1 : 0)

            Text("They're not picky.\nThey're an explorer.")
                .font(SGFont.display(32))
                .foregroundStyle(SGColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("Sensory Galaxy turns gentle food steps into a space journey.")
                .font(SGFont.body())
                .foregroundStyle(SGColor.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - Beat 1 — five SOS phases

    private var phasesBeat: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Five gentle phases.\nNo pressure.")
                .font(SGFont.display(32))
                .foregroundStyle(SGColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("We use the SOS approach. Each phase can take days.")
                .font(SGFont.body())
                .foregroundStyle(SGColor.textSecondary)
                .multilineTextAlignment(.center)

            SGCard(padding: 16) {
                HStack(spacing: 0) {
                    ForEach(Array(SensoryStep.allCases.enumerated()), id: \.element) { index, step in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(SpaceTheme.planetColor(hex: step.color).opacity(0.22))
                                    .frame(width: 44, height: 44)
                                Image(systemName: step.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(SpaceTheme.planetColor(hex: step.color))
                            }
                            Text(step.label.uppercased())
                                .font(SGFont.caption())
                                .tracking(0.8)
                                .foregroundStyle(SGColor.textPrimary)
                        }
                        .frame(maxWidth: .infinity)

                        if index < SensoryStep.allCases.count - 1 {
                            Capsule()
                                .fill(SGColor.cardStroke)
                                .frame(width: 10, height: 2)
                                .offset(y: -12)
                        }
                    }
                }
            }

            Spacer()
        }
    }

    // MARK: - Beat 2 — grown-up view

    private var progressBeat: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("You'll see\nthe progress.")
                .font(SGFont.display(32))
                .foregroundStyle(SGColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("A grown-up view tracks patterns and next foods.")
                .font(SGFont.body())
                .foregroundStyle(SGColor.textSecondary)
                .multilineTextAlignment(.center)

            SGCard(padding: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("COMMAND VIEW")
                        .font(SGFont.caption())
                        .tracking(0.8)
                        .foregroundStyle(SGColor.glow)

                    HStack(spacing: 10) {
                        ForEach(Array(JourneyPlanet.allCases.prefix(5)), id: \.id) { planet in
                            Image(planet.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                                .opacity(planet == .baseCamp ? 1 : 0.45)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Text("Base Camp is ready. The rest of the galaxy waits.")
                        .font(SGFont.caption())
                        .foregroundStyle(SGColor.textSecondary)
                }
            }

            Spacer()
        }
    }

    // MARK: - Bottom chrome

    private var bottomBar: some View {
        VStack(spacing: 12) {
            if currentBeat < totalBeats - 1 {
                SGButton(title: "Continue", style: .parent) {
                    withAnimation(SGMotion.step) { currentBeat += 1 }
                }
            } else {
                SGButton(title: "Meet the Explorer", style: .parent, icon: "sparkles") {
                    onCreateProfile()
                }
            }

            if currentBeat == 0 || currentBeat == totalBeats - 1 {
                Button(action: onSkip) {
                    Text("Skip for now")
                        .font(SGFont.headline())
                        .foregroundStyle(SGColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
