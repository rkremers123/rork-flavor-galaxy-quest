import SwiftUI

/// Kid first-run for Sensory Galaxy.
/// Same galaxy chrome as ParentOnboardingView: SGScreen, SGDotBar, SGButton, SGCard.
/// Button-driven steps with Back. No TabView, no cream, no Color(.systemGray*).
/// Profile writes stay on AppViewModel (name, age, explorer, safeFoodIds, goal food, completeOnboarding).
struct OnboardingView: View {
    let viewModel: AppViewModel

    private enum Step: Int, CaseIterable {
        case welcome, profile, character, safeFoods, goal, summary
    }

    @State private var step: Step = .welcome
    @State private var childName: String = ""
    @State private var childAge: Int = 5
    @State private var selectedExplorerType: ExplorerType = .nova
    @State private var explorerCustomName: String = ""
    @State private var selectedSafeFoods: Set<UUID> = []
    @State private var appeared: Bool = false
    @State private var goalFoodName: String = ""
    @State private var goalTextures: Set<FoodTexture> = []
    @State private var goalFlavors: Set<FoodFlavor> = []
    @State private var goalTemperature: FoodTemperature? = nil
    @State private var goalNotes: String = ""
    @State private var showGoalDetails: Bool = false
    @State private var randomExplorer: ExplorerType = ExplorerType.allCases.randomElement() ?? .nova

    private let maxSafeFoodPicks = 12

    private var nameIsValid: Bool {
        !childName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var goalIsValid: Bool {
        !goalFoodName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var explorerLabel: String {
        let trimmed = childName.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "your explorer" : trimmed
    }

    var body: some View {
        SGScreen {
            VStack(spacing: 0) {
                SGDotBar(count: Step.allCases.count, index: step.rawValue)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                stepStack
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
            }
        }
        .onAppear {
            withAnimation(SGMotion.step.delay(0.2)) { appeared = true }
        }
    }

    @ViewBuilder
    private var stepStack: some View {
        ZStack {
            switch step {
            case .welcome: welcomeStep
            case .profile: profileStep
            case .character: characterStep
            case .safeFoods: safeFoodsStep
            case .goal: goalStep
            case .summary: summaryStep
            }
        }
        .id(step)
        .transition(
            .asymmetric(
                insertion: .opacity.combined(with: .offset(y: 12)),
                removal: .opacity
            )
        )
        .animation(SGMotion.step, value: step)
        .padding(.horizontal, 24)
    }

    // MARK: - Bottom chrome

    @ViewBuilder
    private var bottomBar: some View {
        VStack(spacing: 12) {
            switch step {
            case .welcome:
                SGButton(title: "Launch Mission", style: .kid, icon: "sparkles") {
                    go(to: .profile)
                }
            case .profile:
                SGButton(title: "Next", style: .kid, enabled: nameIsValid) {
                    viewModel.profile.name = childName.trimmingCharacters(in: .whitespaces)
                    viewModel.profile.age = childAge
                    go(to: .character)
                }
            case .character:
                SGButton(title: "Next", style: .kid) {
                    viewModel.profile.explorerType = selectedExplorerType
                    viewModel.profile.explorerCustomName = explorerCustomName
                    go(to: .safeFoods)
                }
            case .safeFoods:
                SGButton(title: "Next", style: .kid) {
                    viewModel.profile.safeFoodIds = Array(selectedSafeFoods)
                    go(to: .goal)
                }
            case .goal:
                SGButton(title: "Continue", style: .kid, enabled: goalIsValid) {
                    writeGoalFood()
                    viewModel.profile.safeFoodIds = Array(selectedSafeFoods)
                    go(to: .summary)
                }
            case .summary:
                SGButton(title: "Land on Base Camp", style: .kid, icon: "rocket.fill") {
                    viewModel.completeOnboarding()
                }
            }

            if step == .goal {
                Button(action: skipGoal) {
                    Text("Skip for now")
                        .font(SGFont.headline())
                        .foregroundStyle(SGColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
            }

            if step != .welcome {
                Button(action: goBack) {
                    Text("Back")
                        .font(SGFont.headline())
                        .foregroundStyle(SGColor.textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func go(to next: Step) {
        withAnimation(SGMotion.step) { step = next }
    }

    private func goBack() {
        guard let previous = Step(rawValue: step.rawValue - 1) else { return }
        go(to: previous)
    }

    private func skipGoal() {
        go(to: .summary)
    }

    private func writeGoalFood() {
        let name = goalFoodName.trimmingCharacters(in: .whitespaces)
        viewModel.profile.goalFoodName = name
        viewModel.profile.goalFoodTextures = Array(goalTextures)
        viewModel.profile.goalFoodFlavors = Array(goalFlavors)
        viewModel.profile.goalFoodTemperature = goalTemperature
        viewModel.profile.goalFoodNotes = goalNotes
        viewModel.profile.goalFoodSetDate = Date()
        viewModel.profile.targetFoodName = name
    }

    // MARK: - Welcome

    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(randomExplorer.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .scaleEffect(appeared ? 1 : 0.86)
                .opacity(appeared ? 1 : 0)

            Text("Welcome to\nSensory Galaxy!")
                .font(SGFont.display(32))
                .foregroundStyle(SGColor.textPrimary)
                .multilineTextAlignment(.center)

            Text("Every food is a planet waiting to be explored.")
                .font(SGFont.body())
                .foregroundStyle(SGColor.textSecondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    // MARK: - Name / age

    private var profileStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                PaxMascotView(message: "What's your explorer's name?", size: 60)

                SGCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("EXPLORER NAME")
                            .font(SGFont.caption())
                            .tracking(0.8)
                            .foregroundStyle(SGColor.glow)

                        TextField("Enter name", text: $childName)
                            .font(SGFont.title(20))
                            .foregroundStyle(SGColor.textPrimary)
                            .padding(14)
                            .background(fieldBackground)
                    }
                }

                SGCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("AGE: \(childAge)")
                            .font(SGFont.caption())
                            .tracking(0.8)
                            .foregroundStyle(SGColor.glow)

                        HStack(spacing: 8) {
                            ForEach(3...10, id: \.self) { age in
                                Button {
                                    childAge = age
                                } label: {
                                    Text("\(age)")
                                        .font(SGFont.headline())
                                        .foregroundStyle(childAge == age ? SGColor.textOnCTA : SGColor.textPrimary)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle().fill(childAge == age ? SGColor.gold : SGColor.chipIdle)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Character

    private var characterStep: some View {
        ScrollView {
            CharacterSelectionView(
                selectedType: $selectedExplorerType,
                customName: $explorerCustomName
            )
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Safe foods

    private var safeFoodsStep: some View {
        VStack(spacing: 16) {
            PaxMascotView(
                message: "Which foods does \(explorerLabel) already like?",
                size: 50
            )

            Text("\(selectedSafeFoods.count)/\(maxSafeFoodPicks) selected")
                .font(SGFont.caption())
                .foregroundStyle(selectedSafeFoods.count >= maxSafeFoodPicks ? SGColor.ember : SGColor.glow)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], spacing: 12) {
                    ForEach(FoodDatabase.allFoods) { food in
                        safeFoodCell(food)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Goal

    private var goalStep: some View {
        ScrollView {
            VStack(spacing: 16) {
                PaxMascotView(message: "What's your goal food?", size: 50)

                Text("What food would \(explorerLabel) love to eat someday?")
                    .font(SGFont.body())
                    .foregroundStyle(SGColor.textSecondary)
                    .multilineTextAlignment(.center)

                SGCard(accent: SGColor.ember.opacity(0.45)) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("GOAL FOOD")
                            .font(SGFont.caption())
                            .tracking(0.8)
                            .foregroundStyle(SGColor.ember)

                        TextField("e.g., Pizza", text: $goalFoodName)
                            .font(SGFont.title(20))
                            .foregroundStyle(SGColor.textPrimary)
                            .padding(14)
                            .background(fieldBackground)
                    }
                }

                if let matchedFood = FoodDatabase.food(byName: goalFoodName) {
                    SGCard(accent: SGColor.leaf.opacity(0.45)) {
                        HStack(spacing: 8) {
                            FoodIcon(food: matchedFood, size: 22)
                            Text(matchedFood.name)
                                .font(SGFont.caption())
                                .foregroundStyle(SGColor.textPrimary)
                            Text("(\(matchedFood.foodGroup.label))")
                                .font(SGFont.caption())
                                .foregroundStyle(SGColor.textMuted)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(SGColor.leaf)
                        }
                    }
                }

                Button {
                    withAnimation(SGMotion.press) { showGoalDetails.toggle() }
                } label: {
                    HStack {
                        Text(showGoalDetails ? "Hide sensory details" : "Add sensory details")
                            .font(SGFont.headline())
                        Spacer()
                        Image(systemName: showGoalDetails ? "chevron.up" : "chevron.down")
                    }
                    .foregroundStyle(SGColor.textSecondary)
                    .frame(height: 44)
                }
                .buttonStyle(.plain)

                if showGoalDetails {
                    SGCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("What challenges does it have?")
                                .font(SGFont.caption())
                                .foregroundStyle(SGColor.textSecondary)

                            sensorySection(title: "TEXTURE", icon: "waveform") {
                                FlowLayout(spacing: 8) {
                                    ForEach(FoodTexture.allCases, id: \.self) { texture in
                                        SGChip(label: texture.label, selected: goalTextures.contains(texture)) {
                                            if goalTextures.contains(texture) { goalTextures.remove(texture) }
                                            else { goalTextures.insert(texture) }
                                        }
                                    }
                                }
                            }

                            sensorySection(title: "FLAVOR", icon: "drop.fill") {
                                FlowLayout(spacing: 8) {
                                    ForEach(FoodFlavor.allCases, id: \.self) { flavor in
                                        SGChip(label: flavor.label, selected: goalFlavors.contains(flavor)) {
                                            if goalFlavors.contains(flavor) { goalFlavors.remove(flavor) }
                                            else { goalFlavors.insert(flavor) }
                                        }
                                    }
                                }
                            }

                            sensorySection(title: "TEMPERATURE", icon: "thermometer.medium") {
                                HStack(spacing: 8) {
                                    ForEach(FoodTemperature.allCases, id: \.self) { temp in
                                        SGChip(label: temp.label, selected: goalTemperature == temp) {
                                            goalTemperature = goalTemperature == temp ? nil : temp
                                        }
                                    }
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("NOTES")
                                    .font(SGFont.caption())
                                    .tracking(0.8)
                                    .foregroundStyle(SGColor.textMuted)

                                TextField("Optional", text: $goalNotes)
                                    .font(SGFont.body())
                                    .foregroundStyle(SGColor.textPrimary)
                                    .padding(14)
                                    .background(fieldBackground)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Summary

    private var summaryStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                PaxMascotView(
                    message: "Here's \(explorerLabel == "your explorer" ? "your explorer's" : explorerLabel + "'s") mission briefing!",
                    size: 60
                )

                SGCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 14) {
                            Image(selectedExplorerType.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(childName.trimmingCharacters(in: .whitespaces).isEmpty ? selectedExplorerType.defaultName : childName)
                                    .font(SGFont.title())
                                    .foregroundStyle(SGColor.textPrimary)
                                Text("Age \(childAge) · \(selectedExplorerType.defaultName)")
                                    .font(SGFont.caption())
                                    .foregroundStyle(SGColor.textSecondary)
                            }
                        }

                        if goalIsValid {
                            HStack(spacing: 12) {
                                Image(systemName: "target")
                                    .font(.title3)
                                    .foregroundStyle(SGColor.ember)
                                    .frame(width: 36, height: 36)
                                    .background(Circle().fill(SGColor.ember.opacity(0.15)))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("GOAL FOOD")
                                        .font(SGFont.caption())
                                        .tracking(0.8)
                                        .foregroundStyle(SGColor.textMuted)
                                    Text(goalFoodName)
                                        .font(SGFont.headline())
                                        .foregroundStyle(SGColor.textPrimary)
                                }
                                Spacer()
                            }
                        }

                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(SGColor.leaf)
                            Text("Foods they like: \(selectedSafeFoods.count)")
                                .font(SGFont.headline())
                                .foregroundStyle(SGColor.textPrimary)
                            Spacer()
                        }

                        if !selectedSafeFoods.isEmpty {
                            let liked = FoodDatabase.allFoods.filter { selectedSafeFoods.contains($0.id) }
                            ScrollView(.horizontal) {
                                HStack(spacing: 8) {
                                    ForEach(liked) { food in
                                        HStack(spacing: 6) {
                                            FoodIcon(food: food, size: 14)
                                            Text(food.name)
                                                .font(SGFont.caption())
                                                .foregroundStyle(SGColor.textPrimary)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(SGColor.leaf.opacity(0.15))
                                                .overlay(
                                                    Capsule().stroke(SGColor.leaf.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }
                }

                if !selectedSafeFoods.isEmpty {
                    diversityCard
                }
            }
            .padding(.bottom, 12)
        }
        .scrollIndicators(.hidden)
    }

    private var diversityCard: some View {
        let safeFoods = FoodDatabase.allFoods.filter { selectedSafeFoods.contains($0.id) }
        let groupCounts = Dictionary(grouping: safeFoods, by: \.foodGroup).mapValues(\.count)
        let uniqueColors = Set(safeFoods.map(\.color))

        return SGCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Foods you already like cover:")
                    .font(SGFont.caption())
                    .foregroundStyle(SGColor.glow)

                Text(
                    "Food groups: " +
                    groupCounts.sorted(by: { $0.key.rawValue < $1.key.rawValue })
                        .map { "\($0.key.label) (\($0.value))" }
                        .joined(separator: ", ")
                )
                .font(SGFont.caption())
                .foregroundStyle(SGColor.textSecondary)

                HStack(spacing: 4) {
                    Text("Colors:")
                        .font(SGFont.caption())
                        .foregroundStyle(SGColor.textSecondary)
                    ForEach(Array(uniqueColors).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { color in
                        Circle()
                            .fill(SpaceTheme.planetColor(hex: color.hex))
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 0.5))
                    }
                }
            }
        }
    }

    // MARK: - Cells

    private func safeFoodCell(_ food: FoodItem) -> some View {
        let isSelected = selectedSafeFoods.contains(food.id)
        let planet = SpaceTheme.planetColor(hex: food.planetColorHex)
        let atCap = !isSelected && selectedSafeFoods.count >= maxSafeFoodPicks

        return Button {
            if isSelected {
                selectedSafeFoods.remove(food.id)
            } else if selectedSafeFoods.count < maxSafeFoodPicks {
                selectedSafeFoods.insert(food.id)
            }
        } label: {
            VStack(spacing: 4) {
                FoodIcon(food: food, size: 28)
                HStack(spacing: 2) {
                    Circle()
                        .fill(SpaceTheme.planetColor(hex: food.color.hex))
                        .frame(width: 6, height: 6)
                    Text(food.name)
                        .font(SGFont.caption())
                        .foregroundStyle(SGColor.textPrimary)
                        .lineLimit(1)
                }
                Text(food.foodGroup.label)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(SGColor.textMuted)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: SGRadius.chip, style: .continuous)
                    .fill(isSelected ? planet.opacity(0.3) : SGColor.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SGRadius.chip, style: .continuous)
                    .stroke(isSelected ? planet.opacity(0.7) : SGColor.cardStroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .opacity(atCap ? 0.4 : 1)
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    private func sensorySection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(SGColor.glow)
                Text(title)
                    .font(SGFont.caption())
                    .tracking(1)
                    .foregroundStyle(SGColor.textMuted)
            }
            content()
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(SGColor.chipIdle)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(SGColor.cardStroke, lineWidth: 1)
            )
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
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
