import SwiftUI

struct PlanetQuestView: View {
    let food: FoodItem
    let viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var activeStep: SensoryStep?
    @State private var showCompletion: Bool = false
    @State private var celebrateTrigger: Int = 0
    @State private var showShield: Bool = false

    private var progress: QuestProgress {
        viewModel.questProgress(for: food.id)
    }

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            ScrollView {
                VStack(spacing: 24) {
                    questHeader
                    sensoryWheel
                    missionArea
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)

            if showCompletion {
                questCompletionOverlay
            }
        }
    }

    private var questHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 70
                        )
                    )
                    .frame(width: 120, height: 120)

                Text(food.emoji)
                    .font(.system(size: 56))
            }

            Text("Planet \(food.name)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                infoTag(food.texture.label, icon: "waveform")
                infoTag(food.flavor.label, icon: "drop.fill")
                infoTag(food.aroma.label, icon: "wind")
            }
        }
    }

    private func infoTag(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.system(.caption2, design: .rounded, weight: .medium))
        }
        .foregroundStyle(.white.opacity(0.6))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(.white.opacity(0.08)))
    }

    private var sensoryWheel: some View {
        VStack(spacing: 16) {
            Text("Sensory Missions")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                ForEach(SensoryStep.allCases, id: \.self) { step in
                    let isCompleted = progress.completedSteps.contains(step)
                    let isActive = activeStep == step
                    let isSkipped = progress.skippedSteps.contains(step)
                    let isAvailable = canAttemptStep(step)

                    Button {
                        if isAvailable && !isCompleted {
                            withAnimation(.spring(duration: 0.3)) {
                                activeStep = step
                            }
                            if step.isHighStakes {
                                showShield = true
                            }
                        }
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(
                                        isCompleted
                                            ? SpaceTheme.planetColor(hex: step.color).opacity(0.3)
                                            : isActive
                                                ? SpaceTheme.cosmicCyan.opacity(0.2)
                                                : .white.opacity(0.06)
                                    )
                                    .frame(width: 52, height: 52)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                isCompleted
                                                    ? SpaceTheme.planetColor(hex: step.color)
                                                    : isActive
                                                        ? SpaceTheme.cosmicCyan
                                                        : .white.opacity(0.15),
                                                lineWidth: isActive ? 2.5 : 1.5
                                            )
                                    )

                                if isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.headline.bold())
                                        .foregroundStyle(SpaceTheme.planetColor(hex: step.color))
                                } else if isSkipped {
                                    Image(systemName: "arrow.uturn.right")
                                        .font(.caption.bold())
                                        .foregroundStyle(.white.opacity(0.4))
                                } else {
                                    Image(systemName: step.icon)
                                        .font(.callout)
                                        .foregroundStyle(
                                            isAvailable ? .white : .white.opacity(0.3)
                                        )
                                }
                            }

                            Text(step.label)
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(
                                    isCompleted ? SpaceTheme.planetColor(hex: step.color) : .white.opacity(0.5)
                                )
                        }
                    }
                    .disabled(!isAvailable || isCompleted)
                    .sensoryFeedback(.impact(flexibility: .soft), trigger: activeStep == step)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var missionArea: some View {
        VStack(spacing: 16) {
            if let step = activeStep {
                missionCard(for: step)
            } else if progress.isComplete {
                completedCard
            } else {
                PaxMascotView(
                    message: progress.completedSteps.isEmpty
                        ? "Explorer! We need to scan Planet \(food.name). Tap a mission to start!"
                        : "Great progress! Keep going, you're doing amazing!",
                    size: 60
                )
            }
        }
    }

    private func missionCard(for step: SensoryStep) -> some View {
        VStack(spacing: 20) {
            PaxMascotView(message: step.missionDescription, size: 50)

            if step.isHighStakes && showShield {
                HStack(spacing: 8) {
                    Image(systemName: "shield.checkered")
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                    Text("Shield Active! It's okay to spit it out.")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(SpaceTheme.cosmicCyan.opacity(0.1))
                )
            }

            HStack(spacing: 12) {
                Button {
                    completeCurrentStep(step)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("Mission Complete!")
                    }
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(SpaceTheme.deepNavy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(SpaceTheme.starGold)
                    )
                }
                .sensoryFeedback(.success, trigger: celebrateTrigger)

                Button {
                    skipCurrentStep(step)
                } label: {
                    Text("Not today")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(.white.opacity(0.06))
                        )
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "sparkles")
                    .font(.caption2)
                Text("+\(step.starDustReward) Star Dust")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
            }
            .foregroundStyle(SpaceTheme.starGold.opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(SpaceTheme.cosmicCyan.opacity(0.2), lineWidth: 1)
                )
        )
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    private var completedCard: some View {
        VStack(spacing: 16) {
            Text("🎉")
                .font(.system(size: 48))

            Text("Planet Colonized!")
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text("You've completed all missions on Planet \(food.name)! You're a true Space Explorer!")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button("Back to Galaxy") {
                dismiss()
            }
            .font(.system(.headline, design: .rounded, weight: .bold))
            .foregroundStyle(SpaceTheme.deepNavy)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Capsule().fill(SpaceTheme.planetGreen))
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(SpaceTheme.planetGreen.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private var questCompletionOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture { showCompletion = false }

            VStack(spacing: 20) {
                Text("⭐️")
                    .font(.system(size: 64))

                Text("Amazing!")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                Text("You earned Star Dust!")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(SpaceTheme.starGold)
            }
            .scaleEffect(showCompletion ? 1.0 : 0.5)
            .opacity(showCompletion ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCompletion)
        }
        .transition(.opacity)
    }

    private func canAttemptStep(_ step: SensoryStep) -> Bool {
        let allSteps = SensoryStep.allCases
        guard let index = allSteps.firstIndex(of: step) else { return false }
        if index == 0 { return true }
        let previousStep = allSteps[index - 1]
        return progress.completedSteps.contains(previousStep) || progress.skippedSteps.contains(previousStep)
    }

    private func completeCurrentStep(_ step: SensoryStep) {
        viewModel.completeStep(step, for: food.id)
        celebrateTrigger += 1

        withAnimation(.spring) {
            showCompletion = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring) {
                showCompletion = false
                activeStep = nil
                showShield = false
            }
        }
    }

    private func skipCurrentStep(_ step: SensoryStep) {
        viewModel.skipStep(step, for: food.id)
        withAnimation(.spring) {
            activeStep = nil
            showShield = false
        }
    }
}
