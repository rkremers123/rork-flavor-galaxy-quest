import SwiftUI

struct RegressionModal: View {
    let food: FoodItem
    let viewModel: AppViewModel
    let onDismiss: () -> Void

    @State private var regressionDate: Date = Date()
    @State private var parentNotes: String = ""
    @State private var showConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    foodHeader

                    VStack(alignment: .leading, spacing: 12) {
                        Text("When did they stop eating this?")
                            .font(.subheadline.weight(.semibold))

                        DatePicker(
                            "Regression date",
                            selection: $regressionDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding(12)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(.rect(cornerRadius: 12))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (optional)")
                            .font(.subheadline.weight(.semibold))

                        TextField("What changed? Any context helps...", text: $parentNotes, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(.rect(cornerRadius: 12))
                    }

                    infoCard

                    Button {
                        showConfirmation = true
                    } label: {
                        Text("Mark as Used to Eat")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(.rect(cornerRadius: 14))
                    }
                }
                .padding(20)
            }
            .navigationTitle("Regression Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss() }
                }
            }
            .alert("Mark as Used to Eat?", isPresented: $showConfirmation) {
                Button("Confirm", role: .destructive) {
                    viewModel.markAsUsedToEat(
                        food: food,
                        regressionDate: regressionDate,
                        notes: parentNotes
                    )
                    onDismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("\(food.name) will be flagged as a regression. This helps us detect sensory patterns and provide better recommendations.")
            }
        }
    }

    private var foodHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.2))
                    .frame(width: 56, height: 56)
                FoodIcon(food: food, size: 32)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.title3.weight(.bold))
                HStack(spacing: 8) {
                    Text(food.texture.label)
                    Text("·")
                    Text(food.flavor.label)
                    Text("·")
                    Text(food.temperature.label)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.blue)
                .font(.callout)

            VStack(alignment: .leading, spacing: 4) {
                Text("Why track regressions?")
                    .font(.caption.weight(.semibold))
                Text("Regressions are normal. When 2+ foods with the same sensory attribute regress, we detect patterns and suggest recovery strategies.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.blue.opacity(0.06))
        .clipShape(.rect(cornerRadius: 12))
    }
}
