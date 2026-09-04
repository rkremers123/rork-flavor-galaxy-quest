import SwiftUI
import UIKit

struct CustomFoodCreationModal: View {
    let initialName: String
    let viewModel: AppViewModel
    var onFoodCreated: ((FoodItem) -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var foodName: String = ""
    @State private var selectedTexture: FoodTexture = .soft
    @State private var selectedFlavor: FoodFlavor = .bland
    @State private var selectedTemperature: FoodTemperature = .roomTemp
    @State private var selectedColor: FoodColor = .brown
    @State private var selectedFoodGroup: FoodGroup = .other
    @State private var showConfirmation: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                SpaceBackgroundView()

                ScrollView {
                    VStack(spacing: 24) {
                        previewCard
                        nameSection
                        colorSection
                        foodGroupSection
                        textureSection
                        flavorSection
                        temperatureSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)

                if showConfirmation {
                    confirmationOverlay
                }
            }
            .navigationTitle("New Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        withAnimation(.spring(duration: 0.3)) {
                            showConfirmation = true
                        }
                    }
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .foregroundStyle(SpaceTheme.cosmicCyan)
                    .disabled(foodName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                foodName = initialName
            }
        }
    }

    private var previewCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [SpaceTheme.cosmicCyan.opacity(0.3), .clear],
                            center: .center,
                            startRadius: 15,
                            endRadius: 50
                        )
                    )
                    .frame(width: 90, height: 90)

                Group {
                    if UIImage(named: "food_custom_gem") != nil {
                        Image("food_custom_gem")
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                    } else {
                        Text("🍽️")
                            .font(.system(size: 40))
                    }
                }
            }

            if !foodName.trimmingCharacters(in: .whitespaces).isEmpty {
                HStack(spacing: 6) {
                    Text(selectedColor.emoji)
                        .font(.caption)
                    Text(foodName)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                    Text("(\(selectedFoodGroup.label))")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            HStack(spacing: 12) {
                propertyPill(selectedTexture.label, icon: "waveform")
                propertyPill(selectedFlavor.label, icon: "drop.fill")
                propertyPill(selectedTemperature.label, icon: "thermometer.medium")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func propertyPill(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.system(.caption2, design: .rounded, weight: .medium))
        }
        .foregroundStyle(.white.opacity(0.5))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(.white.opacity(0.08)))
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Food Name", icon: "pencil")

            TextField("Enter food name", text: $foodName)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.white)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .autocorrectionDisabled()
        }
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Color", icon: "paintpalette.fill")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 8)], spacing: 8) {
                ForEach(FoodColor.allCases, id: \.self) { color in
                    selectionChip(
                        label: "\(color.emoji) \(color.label)",
                        isSelected: selectedColor == color
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedColor = color
                        }
                    }
                }
            }
        }
    }

    private var foodGroupSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Food Group", icon: "square.stack.3d.up.fill")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 85), spacing: 8)], spacing: 8) {
                ForEach(FoodGroup.allCases, id: \.self) { group in
                    selectionChip(
                        label: group.label,
                        isSelected: selectedFoodGroup == group
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedFoodGroup = group
                        }
                    }
                }
            }
        }
    }

    private var textureSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Texture", icon: "waveform")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                ForEach(FoodTexture.allCases, id: \.self) { texture in
                    selectionChip(
                        label: texture.label,
                        isSelected: selectedTexture == texture
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedTexture = texture
                        }
                    }
                }
            }
        }
    }

    private var flavorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Flavor", icon: "drop.fill")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                ForEach(FoodFlavor.allCases, id: \.self) { flavor in
                    selectionChip(
                        label: flavor.label,
                        isSelected: selectedFlavor == flavor
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedFlavor = flavor
                        }
                    }
                }
            }
        }
    }

    private var temperatureSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Temperature", icon: "thermometer.medium")

            HStack(spacing: 8) {
                ForEach(FoodTemperature.allCases, id: \.self) { temp in
                    selectionChip(
                        label: temp.label,
                        isSelected: selectedTemperature == temp
                    ) {
                        withAnimation(.spring(duration: 0.25)) {
                            selectedTemperature = temp
                        }
                    }
                }
            }
        }
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(SpaceTheme.cosmicCyan)
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private func selectionChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(isSelected ? SpaceTheme.deepNavy : .white.opacity(0.6))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? SpaceTheme.cosmicCyan : .white.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isSelected ? SpaceTheme.cosmicCyan : .white.opacity(0.08), lineWidth: 1)
                )
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(duration: 0.3)) {
                        showConfirmation = false
                    }
                }

            VStack(spacing: 20) {
                Group {
                    if UIImage(named: "food_custom_gem") != nil {
                        Image("food_custom_gem")
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                    } else {
                        Text("🍽️")
                            .font(.system(size: 48))
                    }
                }

                Text("Create Custom Food?")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                VStack(spacing: 8) {
                    confirmationRow("Name", value: foodName)
                    confirmationRow("Color", value: "\(selectedColor.emoji) \(selectedColor.label)")
                    confirmationRow("Food Group", value: selectedFoodGroup.label)
                    confirmationRow("Texture", value: selectedTexture.label)
                    confirmationRow("Flavor", value: selectedFlavor.label)
                    confirmationRow("Temperature", value: selectedTemperature.label)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.white.opacity(0.06))
                )

                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            showConfirmation = false
                        }
                    } label: {
                        Text("Go Back")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule().fill(.white.opacity(0.08))
                            )
                    }

                    Button {
                        let createdFood = viewModel.createCustomFood(
                            name: foodName.trimmingCharacters(in: .whitespaces),
                            texture: selectedTexture,
                            flavor: selectedFlavor,
                            temperature: selectedTemperature,
                            color: selectedColor,
                            foodGroup: selectedFoodGroup
                        )
                        dismiss()
                        if let onFoodCreated {
                            onFoodCreated(createdFood)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Create")
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundStyle(SpaceTheme.deepNavy)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule().fill(SpaceTheme.cosmicCyan)
                        )
                    }
                    .sensoryFeedback(.success, trigger: showConfirmation)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(SpaceTheme.deepNavy)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
            .transition(.scale(scale: 0.9).combined(with: .opacity))
        }
    }

    private func confirmationRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
            Spacer()
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}
