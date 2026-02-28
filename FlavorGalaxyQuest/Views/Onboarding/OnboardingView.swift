import SwiftUI

struct OnboardingView: View {
    let viewModel: AppViewModel
    @State private var currentStep: Int = 0
    @State private var childName: String = ""
    @State private var childAge: Int = 5
    @State private var selectedExplorerType: ExplorerType = .nova
    @State private var explorerCustomName: String = ""
    @State private var selectedSafeFoods: Set<UUID> = []
    @State private var targetFoodName: String = ""
    @State private var rewardName: String = ""
    @State private var appeared: Bool = false
    @State private var showResetConfirmation: Bool = false

    private let totalSteps = 6

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            VStack(spacing: 0) {
                stepIndicator
                    .padding(.top, 16)

                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    profileStep.tag(1)
                    characterStep.tag(2)
                    safeFoodsStep.tag(3)
                    goalStep.tag(4)
                    summaryStep.tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(duration: 0.4), value: currentStep)
            }
        }
        .onAppear {
            withAnimation(.spring.delay(0.3)) { appeared = true }
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? SpaceTheme.cosmicCyan : .white.opacity(0.2))
                    .frame(width: index == currentStep ? 28 : 8, height: 8)
                    .animation(.spring, value: currentStep)
            }
        }
        .padding(.horizontal)
    }

    private var welcomeStep: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("🧑‍🚀")
                    .font(.system(size: 80))
                    .scaleEffect(appeared ? 1.0 : 0.3)
                    .opacity(appeared ? 1 : 0)

                Text("Welcome to\nFlavor Galaxy!")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Every food is a planet waiting\nto be explored. No pressure,\njust adventure!")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .offset(y: appeared ? 0 : 30)
            .opacity(appeared ? 1 : 0)

            Spacer()

            nextButton("Launch Mission") { currentStep = 1 }
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }

    private var profileStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            PaxMascotView(message: "What's your explorer's name?", size: 60)
                .padding(.horizontal)

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explorer Name")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(SpaceTheme.cosmicCyan)

                    TextField("Enter name", text: $childName)
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Age: \(childAge)")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(SpaceTheme.cosmicCyan)

                    HStack(spacing: 16) {
                        ForEach(3...10, id: \.self) { age in
                            Button {
                                childAge = age
                            } label: {
                                Text("\(age)")
                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                    .foregroundStyle(childAge == age ? SpaceTheme.deepNavy : .white)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(childAge == age ? SpaceTheme.cosmicCyan : .white.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            nextButton("Next") {
                viewModel.profile.name = childName
                viewModel.profile.age = childAge
                currentStep = 2
            }
            .disabled(childName.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.bottom, 40)
        }
    }

    private var characterStep: some View {
        VStack(spacing: 0) {
            CharacterSelectionView(
                selectedType: $selectedExplorerType,
                customName: $explorerCustomName
            )

            nextButton("Next") {
                viewModel.profile.explorerType = selectedExplorerType
                viewModel.profile.explorerCustomName = explorerCustomName
                currentStep = 3
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private var safeFoodsStep: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 12)

            PaxMascotView(message: "Which foods does \(childName.isEmpty ? "your explorer" : childName) already like?", size: 50)
                .padding(.horizontal)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], spacing: 12) {
                    ForEach(FoodDatabase.allFoods) { food in
                        Button {
                            if selectedSafeFoods.contains(food.id) {
                                selectedSafeFoods.remove(food.id)
                            } else {
                                selectedSafeFoods.insert(food.id)
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Text(food.emoji)
                                    .font(.title2)
                                Text(food.name)
                                    .font(.system(.caption2, design: .rounded, weight: .medium))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(selectedSafeFoods.contains(food.id)
                                        ? SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.3)
                                        : .white.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(selectedSafeFoods.contains(food.id)
                                                ? SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.6)
                                                : .white.opacity(0.1), lineWidth: 1.5)
                                    )
                            )
                        }
                        .sensoryFeedback(.selection, trigger: selectedSafeFoods.contains(food.id))
                    }
                }
                .padding(.horizontal, 20)
            }

            nextButton("Next") {
                viewModel.profile.safeFoodIds = Array(selectedSafeFoods)
                currentStep = 4
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private var goalStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            PaxMascotView(message: "What food would you love them to try someday?", size: 60)
                .padding(.horizontal)

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Food")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(SpaceTheme.cosmicCyan)

                    TextField("e.g. Broccoli", text: $targetFoodName)
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Star Jar Reward")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(SpaceTheme.starGold)

                    TextField("e.g. New Lego Set", text: $rewardName)
                        .font(.system(.title3, design: .rounded, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            nextButton("Next") {
                viewModel.profile.targetFoodName = targetFoodName
                if !rewardName.isEmpty {
                    viewModel.profile.starJarRewardName = rewardName
                }
                viewModel.profile.safeFoodIds = Array(selectedSafeFoods)
                currentStep = 5
            }
            .padding(.bottom, 40)
        }
    }

    private var masteredCount: Int { selectedSafeFoods.count }

    private var toExploreCount: Int {
        FoodDatabase.allFoods.count - selectedSafeFoods.count
    }

    private var summaryStep: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            PaxMascotView(message: "Here's \(childName.isEmpty ? "your explorer's" : childName + "'s") mission briefing!", size: 60)
                .padding(.horizontal)

            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    summaryCard(
                        count: masteredCount,
                        label: "Foods Mastered",
                        icon: "checkmark.seal.fill",
                        color: SpaceTheme.planetGreen
                    )
                    summaryCard(
                        count: toExploreCount,
                        label: "Foods to Explore",
                        icon: "sparkles",
                        color: SpaceTheme.cosmicCyan
                    )
                }

                if !targetFoodName.isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.title3)
                            .foregroundStyle(SpaceTheme.warningOrange)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(SpaceTheme.warningOrange.opacity(0.15)))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Target Food")
                                .font(.system(.caption2, design: .rounded, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                            Text(targetFoodName)
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(SpaceTheme.warningOrange.opacity(0.2), lineWidth: 1)
                            )
                    )
                }

                if masteredCount > 0 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Already Mastered")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(SpaceTheme.planetGreen)

                        let masteredFoods = FoodDatabase.allFoods.filter { selectedSafeFoods.contains($0.id) }
                        ScrollView(.horizontal) {
                            HStack(spacing: 8) {
                                ForEach(masteredFoods) { food in
                                    HStack(spacing: 6) {
                                        Text(food.emoji)
                                            .font(.caption)
                                        Text(food.name)
                                            .font(.system(.caption2, design: .rounded, weight: .medium))
                                            .foregroundStyle(.white)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(SpaceTheme.planetGreen.opacity(0.15))
                                            .overlay(
                                                Capsule()
                                                    .stroke(SpaceTheme.planetGreen.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        .contentMargins(.horizontal, 0)
                        .scrollIndicators(.hidden)
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.white.opacity(0.04))
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                viewModel.completeOnboarding()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "rocket.fill")
                    Text("Begin Exploring!")
                }
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(SpaceTheme.deepNavy)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [SpaceTheme.starGold, SpaceTheme.warningOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func summaryCard(count: Int, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text("\(count)")
                .font(.system(.title, design: .rounded, weight: .heavy))
                .foregroundStyle(.white)

            Text(label)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func nextButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(SpaceTheme.cosmicCyan.opacity(0.8))
                        .overlay(
                            Capsule()
                                .stroke(SpaceTheme.cosmicCyan, lineWidth: 1)
                        )
                )
        }
        .padding(.horizontal, 24)
    }
}
