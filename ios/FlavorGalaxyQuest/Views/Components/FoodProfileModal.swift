import SwiftUI

struct FoodProfileModal: View {
    let food: FoodItem
    let viewModel: AppViewModel

    @Environment(\.dismiss) private var dismiss

    private var progress: QuestProgressModel? {
        viewModel.questProgress(for: food.id)
    }

    private var isGoalFood: Bool {
        viewModel.profile.targetFoodId == food.id
    }

    private var isSafeFood: Bool {
        viewModel.profile.safeFoodIds.contains(food.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    sensoryDetailSection
                    phaseProgressSection
                    allergenSection
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            FoodIcon(food: food, size: 64)

            Text(food.name)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text(food.color.emoji)
                    Text(food.color.label)
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(.white.opacity(0.08)))

                HStack(spacing: 4) {
                    Image(systemName: food.foodGroup.icon)
                        .font(.caption2)
                    Text(food.foodGroup.label)
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(.white.opacity(0.08)))
            }

            HStack(spacing: 16) {
                if isGoalFood {
                    Label("Goal Food", systemImage: "target")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(SpaceTheme.starGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(SpaceTheme.starGold.opacity(0.12)))
                }
                if isSafeFood {
                    Label("Safe Food", systemImage: "checkmark.shield.fill")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                        .foregroundStyle(SpaceTheme.planetGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(SpaceTheme.planetGreen.opacity(0.12)))
                }
            }
        }
    }

    private var sensoryDetailSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Sensory Profile")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))

            VStack(spacing: 10) {
                sensoryRow(emoji: "👅", label: "Texture", value: food.texture.label)
                sensoryRow(emoji: "🍍", label: "Flavor", value: food.flavor.label)
                sensoryRow(emoji: "🌡️", label: "Temperature", value: food.temperature.label)
                sensoryRow(emoji: "👃", label: "Aroma", value: food.aroma.label)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.04))
            )
        }
    }

    private func sensoryRow(emoji: String, label: String, value: String) -> some View {
        HStack {
            Text(emoji)
                .font(.callout)
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var phaseProgressSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Phase Progress")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 0) {
                ForEach(SensoryStep.allCases, id: \.self) { step in
                    let isCompleted = progress?.completedSteps.contains(step) ?? false
                    let isSkipped = progress?.skippedSteps.contains(step) ?? false
                    let stepColor = SpaceTheme.planetColor(hex: step.color)

                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(isCompleted ? stepColor.opacity(0.2) : .white.opacity(0.04))
                                .frame(width: 36, height: 36)
                            if isCompleted {
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundStyle(stepColor)
                            } else if isSkipped {
                                Image(systemName: "arrow.uturn.right")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.2))
                            } else {
                                StepMark(step: step, size: 14, tint: .white.opacity(0.2))
                            }
                        }
                        Text(step.label.uppercased())
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundStyle(isCompleted ? stepColor : .white.opacity(0.25))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.white.opacity(0.04))
            )
        }
    }

    private var allergenSection: some View {
        Group {
            if !food.allergens.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Allergens")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white.opacity(0.6))

                    HStack(spacing: 8) {
                        ForEach(Array(food.allergens).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { allergen in
                            Text(allergen.label)
                                .font(.system(.caption2, design: .rounded, weight: .semibold))
                                .foregroundStyle(.orange)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().fill(.orange.opacity(0.1)))
                        }
                    }
                }
            }
        }
    }
}
