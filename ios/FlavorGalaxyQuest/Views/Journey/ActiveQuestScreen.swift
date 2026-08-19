import SwiftUI

struct ActiveQuestScreen: View {
    @Bindable var viewModel: AppViewModel
    @State private var showCompletion = false
    @State private var celebrateTrigger = 0
    @State private var showVerification = false
    @State private var showEducation = false
    @State private var showFoodProfile = false
    @State private var completedStep: SensoryStep?
    @State private var lookLoggedThisSitting = false

    private var food: FoodItem? { viewModel.activeQuestFood }
    private var progress: QuestProgressModel? { viewModel.activeQuestProgress }
    private var completedSteps: [SensoryStep] { progress?.completedSteps ?? [] }
    private var skippedSteps: [SensoryStep] { progress?.skippedSteps ?? [] }

    private var currentStep: SensoryStep? {
        SensoryStep.allCases.first { !completedSteps.contains($0) && !skippedSteps.contains($0) }
    }

    private var isGoalFood: Bool {
        guard let food else { return false }
        return viewModel.profile.targetFoodId == food.id
    }

    private var isSafeFood: Bool {
        guard let food else { return false }
        return viewModel.profile.safeFoodIds.contains(food.id)
    }

    private var similarFoods: [FoodItem] {
        guard let food else { return [] }
        let allFoods = FoodDatabase.allFoods + viewModel.customFoodItems
        return allFoods.filter {
            $0.id != food.id &&
            !viewModel.isHardExcluded($0) &&
            ($0.color == food.color || $0.foodGroup == food.foodGroup)
        }.prefix(4).map { $0 }
    }

    private var whyThisFood: String? {
        guard let food else { return nil }
        if isGoalFood { return "This is \(viewModel.profile.explorerDisplayName)'s goal food!" }
        if let bridge = viewModel.profile.activeBridges.first(where: { $0.bridgeFoodId == food.id }),
           let safeFood = FoodDatabase.food(byId: bridge.safeFoodId) {
            return "Bridge from \(safeFood.name) — shares similar sensory traits."
        }
        if isSafeFood { return "A safe food \(viewModel.profile.explorerDisplayName) already enjoys." }
        return nil
    }

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            if let food {
                VStack(spacing: 0) {
                    questContent(food)

                    if let step = currentStep {
                        floatingActionBar(step, food: food)
                    }
                }
            } else {
                emptyState
            }

            if showCompletion, let step = completedStep {
                stepCelebrationOverlay(step)
            }
        }
        .sheet(isPresented: $showEducation) {
            SensoryEducationModal()
        }
        .sheet(isPresented: $showFoodProfile) {
            if let food {
                FoodProfileModal(food: food, viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(SpaceTheme.deepNavy)
            }
        }
        .sheet(isPresented: $showVerification) {
            ParentVerificationSheet(
                foodName: food?.name ?? "",
                step: completedStep ?? .taste,
                onVerify: { verification in
                    if let food {
                        viewModel.verifyTasteStep(foodId: food.id, verification: verification)
                    }
                    showVerification = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    private func questContent(_ food: FoodItem) -> some View {
        ScrollView {
            VStack(spacing: 28) {
                heroSection(food)
                phaseTimeline
                if let step = currentStep {
                    actionArea(step, food: food)
                } else if progress?.isComplete ?? false {
                    completedArea(food)
                }
                if !similarFoods.isEmpty {
                    similarFoodsSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
    }

    private func heroSection(_ food: FoodItem) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.25),
                                .clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 120
                        )
                    )
                    .frame(width: 200, height: 200)

                Text(food.emoji)
                    .font(.system(size: 90))
            }

            Button { showFoodProfile = true } label: {
                HStack(spacing: 6) {
                    Text(food.name)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            HStack(spacing: 8) {
                Text(food.color.emoji)
                    .font(.caption)
                Text(food.color.label)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                Text("·")
                    .foregroundStyle(.white.opacity(0.3))
                Image(systemName: food.foodGroup.icon)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
                Text(food.foodGroup.label)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(.white.opacity(0.06)))

            if viewModel.profile.currentStreak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("\(viewModel.profile.currentStreak) day streak")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(.orange.opacity(0.1)))
            }

            sensoryProfilePills(food)

            if let reason = whyThisFood {
                HStack(spacing: 8) {
                    Image(systemName: isGoalFood ? "target" : isSafeFood ? "checkmark.shield.fill" : "arrow.triangle.branch")
                        .font(.caption)
                        .foregroundStyle(isGoalFood ? SpaceTheme.starGold : isSafeFood ? SpaceTheme.planetGreen : SpaceTheme.cosmicCyan)
                    Text(reason)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(isGoalFood ? SpaceTheme.starGold : isSafeFood ? SpaceTheme.planetGreen : SpaceTheme.cosmicCyan)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill((isGoalFood ? SpaceTheme.starGold : isSafeFood ? SpaceTheme.planetGreen : SpaceTheme.cosmicCyan).opacity(0.1))
                )
            }

            if let bridge = viewModel.profile.activeBridges.first(where: { $0.bridgeFoodId == food.id }) {
                HStack(spacing: 8) {
                    Image(systemName: bridge.bridgeType.icon)
                        .font(.caption)
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                    Text("\(bridge.bridgeType.label) · Day \(bridge.daysActive + 1)")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule().fill(SpaceTheme.cosmicCyan.opacity(0.1))
                )
            }
        }
    }

    private func sensoryProfilePills(_ food: FoodItem) -> some View {
        HStack(spacing: 10) {
            sensoryPill("👅 \(food.texture.label)", icon: nil)
            sensoryPill("🍍 \(food.flavor.label)", icon: nil)
            sensoryPill("🌡️ \(food.temperature.label)", icon: nil)
        }
    }

    private var phaseTimeline: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(SensoryStep.allCases, id: \.self) { step in
                let isCompleted = completedSteps.contains(step)
                let isSkipped = skippedSteps.contains(step)
                let isCurrent = step == currentStep
                let stepColor = SpaceTheme.planetColor(hex: step.color)

                Button {
                    if isCurrent, let food {
                        performStepCompletion(step, food: food)
                    }
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    isCompleted ? stepColor.opacity(0.2) :
                                    isCurrent ? SpaceTheme.cosmicCyan.opacity(0.15) :
                                    .white.opacity(0.04)
                                )
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle().stroke(
                                        isCompleted ? stepColor :
                                        isCurrent ? SpaceTheme.cosmicCyan :
                                        .white.opacity(0.08),
                                        lineWidth: isCurrent ? 2.5 : 1.5
                                    )
                                )

                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.callout.bold())
                                    .foregroundStyle(stepColor)
                            } else if isSkipped {
                                Image(systemName: "arrow.uturn.right")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white.opacity(0.3))
                            } else {
                                Image(systemName: step.icon)
                                    .font(.callout)
                                    .foregroundStyle(isCurrent ? SpaceTheme.cosmicCyan : .white.opacity(0.2))
                            }
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.label.uppercased())
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(
                                    isCompleted ? stepColor :
                                    isCurrent ? .white :
                                    .white.opacity(0.25)
                                )

                            if isCurrent {
                                Text("Tap to complete · \(step.missionTitle)")
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .foregroundStyle(SpaceTheme.cosmicCyan)
                            }
                        }

                        Spacer()

                        if isCompleted {
                            Text("+\(step.starDustReward)")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(SpaceTheme.starGold.opacity(0.5))
                        }

                        if isCurrent {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                                .foregroundStyle(SpaceTheme.cosmicCyan)
                        }
                    }
                    .padding(.vertical, 12)
                }
                .disabled(!isCurrent)
                .sensoryFeedback(.impact(flexibility: .solid), trigger: isCurrent ? celebrateTrigger : 0)

                if step != .taste {
                    HStack {
                        Rectangle()
                            .fill(isCompleted ? stepColor.opacity(0.25) : .white.opacity(0.04))
                            .frame(width: 2, height: 8)
                            .padding(.leading, 21)
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func actionArea(_ step: SensoryStep, food: FoodItem) -> some View {
        VStack(spacing: 16) {
            PaxMascotView(message: step.missionDescription, size: 50)

            if step.isHighStakes {
                HStack(spacing: 8) {
                    Image(systemName: "shield.checkered")
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                    Text("Shield Active! It's okay to spit it out.")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(SpaceTheme.cosmicCyan.opacity(0.08))
                )
            }

            Button {
                performStepCompletion(step, food: food)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("I Did This Phase!")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                }
                .foregroundStyle(SpaceTheme.deepNavy)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Capsule().fill(SpaceTheme.starGold))
            }
            .sensoryFeedback(.success, trigger: celebrateTrigger)

            Button {
                showEducation = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "questionmark.circle")
                    Text("Tell Me More")
                }
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Capsule().fill(.white.opacity(0.05)))
            }

            Button {
                viewModel.pauseQuestSitting()
            } label: {
                Text("Not today")
                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(.white.opacity(0.05)))
            }

            if lookLoggedThisSitting {
                Text("Looking still counted if you already logged it.")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.35))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func floatingActionBar(_ step: SensoryStep, food: FoodItem) -> some View {
        VStack(spacing: 0) {
            Divider().overlay(.white.opacity(0.06))

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(step.label.uppercased())
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 9))
                        Text("+\(step.starDustReward) Star Dust")
                            .font(.system(.caption2, design: .rounded, weight: .semibold))
                    }
                    .foregroundStyle(SpaceTheme.starGold.opacity(0.7))
                }

                Spacer()

                Button {
                    performStepCompletion(step, food: food)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                        Text("I Did It!")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                    }
                    .foregroundStyle(SpaceTheme.deepNavy)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(SpaceTheme.starGold))
                }
                .sensoryFeedback(.success, trigger: celebrateTrigger)

                Button {
                    viewModel.pauseQuestSitting()
                } label: {
                    Text("Not today")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial.opacity(0.8))
            .background(SpaceTheme.deepNavy.opacity(0.9))
        }
    }

    private func completedArea(_ food: FoodItem) -> some View {
        VStack(spacing: 20) {
            Text("🎉").font(.system(size: 60))

            Text("Quest Complete!")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text("You've mastered Planet \(food.name)!")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                viewModel.activeQuestFoodId = nil
                viewModel.selectedTab = 2
            } label: {
                Text("Explore More Foods")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(SpaceTheme.deepNavy)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(SpaceTheme.planetGreen))
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(SpaceTheme.planetGreen.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(SpaceTheme.cosmicCyan.opacity(0.06))
                    .frame(width: 140, height: 140)
                Image(systemName: "star.circle")
                    .font(.system(size: 56))
                    .foregroundStyle(SpaceTheme.cosmicCyan.opacity(0.35))
            }

            Text("No Active Quest")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text("Choose a food from the Foods tab\nto start your next adventure!")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)

            Button {
                viewModel.selectedTab = 2
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                    Text("Browse Foods")
                }
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(SpaceTheme.deepNavy)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(Capsule().fill(SpaceTheme.cosmicCyan))
            }

            Spacer()
        }
    }

    private func sensoryPill(_ text: String, icon: String?) -> some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
                .font(.system(.caption2, design: .rounded, weight: .medium))
        }
        .foregroundStyle(.white.opacity(0.5))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(.white.opacity(0.06)))
    }

    private func performStepCompletion(_ step: SensoryStep, food: FoodItem) {
        completedStep = step
        if step == .look {
            lookLoggedThisSitting = true
        }
        viewModel.completeStep(step, for: food.id)
        celebrateTrigger += 1

        withAnimation(.spring) { showCompletion = true }

        let hasMilestone = viewModel.streakMilestone != nil
        let displayDuration: Duration = hasMilestone ? .seconds(3.5) : .seconds(2)

        Task {
            try? await Task.sleep(for: displayDuration)
            viewModel.streakMilestone = nil
            withAnimation(.spring) {
                showCompletion = false
                if step.isHighStakes {
                    showVerification = true
                }
            }
        }
    }

    private var similarFoodsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(SpaceTheme.cosmicCyan)
                Text("Similar Foods")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(similarFoods) { similar in
                        Button {
                            viewModel.setActiveQuest(food: similar)
                        } label: {
                            VStack(spacing: 6) {
                                Text(similar.emoji)
                                    .font(.title2)
                                Text(similar.name)
                                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                HStack(spacing: 2) {
                                    Text(similar.color.emoji)
                                        .font(.system(size: 8))
                                    Text(similar.foodGroup.label)
                                        .font(.system(size: 9, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }
                            .frame(width: 80)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(.white.opacity(0.06), lineWidth: 1)
                                    )
                            )
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 0)
            .scrollIndicators(.hidden)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.03))
        )
    }

    private func stepCelebrationOverlay(_ step: SensoryStep) -> some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 16) {
                if let milestone = viewModel.streakMilestone {
                    Text(milestone.emoji).font(.system(size: 56))

                    Text(milestone.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

                    Text(milestone.message)
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                } else {
                    Text("⭐️").font(.system(size: 56))

                    Text("Amazing!")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)

                    Text(step.paxEncouragement)
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                    Text("+\(step.starDustReward) Star Dust")
                }
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(SpaceTheme.starGold)

                if viewModel.profile.currentStreak > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("Streak: Day \(viewModel.profile.currentStreak)!")
                            .foregroundStyle(.orange)
                    }
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .padding(.top, 4)
                }
            }
            .scaleEffect(showCompletion ? 1.0 : 0.5)
            .opacity(showCompletion ? 1 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showCompletion)
        }
        .transition(.opacity)
    }
}
