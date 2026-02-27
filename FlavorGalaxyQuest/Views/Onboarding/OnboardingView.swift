import SwiftUI

struct OnboardingView: View {
    let viewModel: AppViewModel
    @State private var currentStep: Int = 0
    @State private var childName: String = ""
    @State private var childAge: Int = 5
    @State private var selectedSafeFoods: Set<UUID> = []
    @State private var targetFoodName: String = ""
    @State private var rewardName: String = ""
    @State private var appeared: Bool = false

    private let totalSteps = 4

    var body: some View {
        ZStack {
            SpaceBackgroundView()

            VStack(spacing: 0) {
                stepIndicator
                    .padding(.top, 16)

                TabView(selection: $currentStep) {
                    welcomeStep.tag(0)
                    profileStep.tag(1)
                    safeFoodsStep.tag(2)
                    goalStep.tag(3)
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
                currentStep = 3
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

            Button {
                viewModel.profile.targetFoodName = targetFoodName
                if !rewardName.isEmpty {
                    viewModel.profile.starJarRewardName = rewardName
                }
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
