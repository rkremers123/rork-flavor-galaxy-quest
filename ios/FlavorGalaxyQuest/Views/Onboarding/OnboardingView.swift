import SwiftUI

struct OnboardingView: View {
    let viewModel: AppViewModel
    @State private var currentStep: Int = 0
    @State private var childName: String = ""
    @State private var childAge: Int = 5
    @State private var selectedExplorerType: ExplorerType = .nova
    @State private var explorerCustomName: String = ""
    @State private var selectedSafeFoods: Set<UUID> = []
    @State private var appeared: Bool = false
    @State private var showResetConfirmation: Bool = false
    @State private var goalFoodName: String = ""
    @State private var goalTextures: Set<FoodTexture> = []
    @State private var goalFlavors: Set<FoodFlavor> = []
    @State private var goalTemperature: FoodTemperature? = nil
    @State private var goalNotes: String = ""
    @State private var randomExplorer: ExplorerType = ExplorerType.allCases.randomElement() ?? .nova

    private let totalSteps = 6
    private let maxSafeFoodPicks = 12

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
                    goalFoodStep.tag(4)
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
                Image(randomExplorer.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(appeared ? 1.0 : 0.3)
                    .opacity(appeared ? 1 : 0)

                Text("Welcome to\nSensory Galaxy!")
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

            Text("\(selectedSafeFoods.count)/\(maxSafeFoodPicks) selected")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(selectedSafeFoods.count >= maxSafeFoodPicks ? SpaceTheme.warningOrange : SpaceTheme.cosmicCyan)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], spacing: 12) {
                    ForEach(FoodDatabase.allFoods) { food in
                        safeFoodCell(food)
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

    private var goalFoodStep: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 12)

            PaxMascotView(message: "What's your goal food?", size: 50)
                .padding(.horizontal)

            Text("What food would your child love to eat someday?")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    onboardingTextField(label: "Goal Food", placeholder: "e.g., Pizza", text: $goalFoodName, accent: SpaceTheme.warningOrange)

                    if let matchedFood = FoodDatabase.food(byName: goalFoodName) {
                        HStack(spacing: 8) {
                            Text(matchedFood.color.emoji)
                                .font(.caption)
                            Text(matchedFood.name)
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("(\(matchedFood.foodGroup.label))")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(SpaceTheme.planetGreen)
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(SpaceTheme.planetGreen.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(SpaceTheme.planetGreen.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("What challenges does it have?")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(.white.opacity(0.7))

                        sensorySection(title: "TEXTURE", icon: "waveform") {
                            FlowLayout(spacing: 8) {
                                ForEach(FoodTexture.allCases, id: \.self) { texture in
                                    sensoryChip(texture.label, selected: goalTextures.contains(texture)) {
                                        if goalTextures.contains(texture) { goalTextures.remove(texture) }
                                        else { goalTextures.insert(texture) }
                                    }
                                }
                            }
                        }

                        sensorySection(title: "FLAVOR", icon: "drop.fill") {
                            FlowLayout(spacing: 8) {
                                ForEach(FoodFlavor.allCases, id: \.self) { flavor in
                                    sensoryChip(flavor.label, selected: goalFlavors.contains(flavor)) {
                                        if goalFlavors.contains(flavor) { goalFlavors.remove(flavor) }
                                        else { goalFlavors.insert(flavor) }
                                    }
                                }
                            }
                        }

                        sensorySection(title: "TEMPERATURE", icon: "thermometer.medium") {
                            HStack(spacing: 8) {
                                ForEach(FoodTemperature.allCases, id: \.self) { temp in
                                    sensoryChip(temp.label, selected: goalTemperature == temp) {
                                        goalTemperature = goalTemperature == temp ? nil : temp
                                    }
                                }
                            }
                        }
                    }

                    onboardingTextField(label: "Any other notes?", placeholder: "Optional", text: $goalNotes, accent: .white.opacity(0.4))
                }
                .padding(.horizontal, 24)
            }
            .scrollIndicators(.hidden)

            nextButton("Continue") {
                viewModel.profile.goalFoodName = goalFoodName
                viewModel.profile.goalFoodTextures = Array(goalTextures)
                viewModel.profile.goalFoodFlavors = Array(goalFlavors)
                viewModel.profile.goalFoodTemperature = goalTemperature
                viewModel.profile.goalFoodNotes = goalNotes
                viewModel.profile.goalFoodSetDate = Date()
                viewModel.profile.safeFoodIds = Array(selectedSafeFoods)
                viewModel.profile.targetFoodName = goalFoodName
                currentStep = 5
            }
            .disabled(goalFoodName.trimmingCharacters(in: .whitespaces).isEmpty)
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
                        label: "Foods you already like",
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

                if !goalFoodName.isEmpty {
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
                            Text(goalFoodName)
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
                        Text("Foods you already like")
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

            if !selectedSafeFoods.isEmpty {
                safeFoodDiversitySummary
            }

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

    private var safeFoodDiversitySummary: some View {
        let safeFoods = FoodDatabase.allFoods.filter { selectedSafeFoods.contains($0.id) }
        let groupCounts = Dictionary(grouping: safeFoods, by: \.foodGroup).mapValues(\.count)
        let uniqueColors = Set(safeFoods.map(\.color))

        return VStack(alignment: .leading, spacing: 8) {
            Text("Your safe foods cover:")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(SpaceTheme.cosmicCyan)

            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.caption2)
                    .foregroundStyle(SpaceTheme.planetGreen)
                Text("Food Groups: " + groupCounts.sorted(by: { $0.key.rawValue < $1.key.rawValue }).map { "\($0.key.label) (\($0.value))" }.joined(separator: ", "))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.caption2)
                    .foregroundStyle(SpaceTheme.planetGreen)
                HStack(spacing: 2) {
                    Text("Colors:")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                    ForEach(Array(uniqueColors).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { color in
                        Text(color.emoji)
                            .font(.system(size: 10))
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(SpaceTheme.cosmicCyan.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
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

    private func safeFoodCell(_ food: FoodItem) -> some View {
        let isSelected = selectedSafeFoods.contains(food.id)
        let fillColor: Color = isSelected ? SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.3) : .white.opacity(0.06)
        let strokeColor: Color = isSelected ? SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.6) : .white.opacity(0.1)

        let atCap = !isSelected && selectedSafeFoods.count >= maxSafeFoodPicks

        return Button {
            if isSelected {
                selectedSafeFoods.remove(food.id)
            } else if selectedSafeFoods.count < maxSafeFoodPicks {
                selectedSafeFoods.insert(food.id)
            }
        } label: {
            VStack(spacing: 4) {
                Text(food.emoji)
                    .font(.title2)
                HStack(spacing: 2) {
                    Text(food.color.emoji)
                        .font(.system(size: 8))
                    Text(food.name)
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                Text(food.foodGroup.label)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(strokeColor, lineWidth: 1.5)
                    )
            )
        }
        .opacity(atCap ? 0.4 : 1)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    private func onboardingTextField(label: String, placeholder: String, text: Binding<String>, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(accent)

            TextField(placeholder, text: text)
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

    private func sensorySection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(SpaceTheme.cosmicCyan)
                Text(title)
                    .font(.system(.caption2, design: .rounded, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.5))
                    .tracking(1)
            }
            content()
        }
    }

    private func sensoryChip(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(selected ? SpaceTheme.deepNavy : .white.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selected ? SpaceTheme.cosmicCyan : .white.opacity(0.08))
                )
                .overlay(
                    Capsule()
                        .stroke(selected ? SpaceTheme.cosmicCyan : .white.opacity(0.12), lineWidth: 1)
                )
        }
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
