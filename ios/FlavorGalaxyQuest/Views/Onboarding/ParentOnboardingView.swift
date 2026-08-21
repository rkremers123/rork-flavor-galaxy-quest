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
            case 0: patternsBeat
            case 1: bridgeBeat
            default: celebrateBeat
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

    // MARK: - Beat 0 — Identify Patterns

    private var patternsBeat: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("explorer_star")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .scaleEffect(appeared ? 1 : 0.86)
                .opacity(appeared ? 1 : 0)

            Text("Identify Patterns")
                .font(SGFont.display(32))
                .foregroundStyle(SGColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("Log what your child explores. Look, touch, smell, lick, or a taste all count. The app reads textures, flavors, temperatures, and colors they already go for. You see the sensory patterns they trust, and where they stall.")
                .font(SGFont.body())
                .foregroundStyle(SGColor.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - Beat 1 — Bridge Foods

    private var bridgeBeat: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Bridge Foods")
                .font(SGFont.display(32))
                .foregroundStyle(SGColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("The app finds bridge foods: a food they already enjoy, plus one new sensory element. If they like crunchy salty crackers, try crunchy salty pretzels. If nothing is that close, it does not invent a pick.")
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

    // MARK: - Beat 2 — Celebrate Progress

    private var celebrateBeat: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("planet_base_camp")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            Text("Celebrate Progress")
                .font(SGFont.display(32))
                .foregroundStyle(SGColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("Your child earns star dust, badges, and streaks. You unlock a parent log with a PIN and see what they actually did. Mealtimes can shift from battles to celebrating how brave they’re being.")
                .font(SGFont.body())
                .foregroundStyle(SGColor.textSecondary)
                .multilineTextAlignment(.center)

            SGCard(padding: 16) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("BASE CAMP")
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

                    Text("Star dust, badges, streaks. Looking still counts.")
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
