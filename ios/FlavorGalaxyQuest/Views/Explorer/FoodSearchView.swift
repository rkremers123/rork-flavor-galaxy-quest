import SwiftUI

struct FoodSearchView: View {
    let viewModel: AppViewModel
    @Binding var selectedFood: FoodItem?
    @State private var searchText: String = ""
    @State private var showCreateFood: Bool = false
    @State private var pendingCustomFood: FoodItem?
    @Environment(\.dismiss) private var dismiss

    private var allFoods: [FoodItem] {
        (FoodDatabase.allFoods + viewModel.customFoodItems).filter { !viewModel.isHardExcluded($0) }
    }

    private var searchResults: [FoodItem] {
        FoodDatabase.search(searchText, in: allFoods)
    }

    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var customFoodIds: Set<UUID> {
        Set(viewModel.customFoodItems.map(\.id))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SpaceBackgroundView()

                VStack(spacing: 0) {
                    searchBar
                    resultsList
                }
            }
            .navigationTitle("Find Foods")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .sheet(isPresented: $showCreateFood) {
                CustomFoodCreationModal(
                    initialName: searchText,
                    viewModel: viewModel,
                    onFoodCreated: { food in
                        pendingCustomFood = food
                    }
                )
            }
            .onChange(of: showCreateFood) { _, isShowing in
                if !isShowing, let food = pendingCustomFood {
                    pendingCustomFood = nil
                    selectedFood = food
                    dismiss()
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.4))

            TextField("Search foods...", text: $searchText)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.white)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if isSearching {
                    if searchResults.count >= 3 {
                        HStack {
                            Text("Showing \(searchResults.count) results")
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(.white.opacity(0.4))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                    }

                    if searchResults.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(searchResults) { food in
                            foodRow(food)
                        }

                        createCustomFoodRow
                            .padding(.top, 4)
                    }
                } else {
                    ForEach(allFoods) { food in
                        foodRow(food)
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
    }

    private func foodRow(_ food: FoodItem) -> some View {
        Button {
            selectedFood = food
            dismiss()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(SpaceTheme.planetColor(hex: food.planetColorHex).opacity(0.2))
                        .frame(width: 44, height: 44)
                    Text(food.emoji)
                        .font(.title3)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(food.name)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white)

                        if customFoodIds.contains(food.id) {
                            Text("CUSTOM")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(SpaceTheme.cosmicCyan)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(SpaceTheme.cosmicCyan.opacity(0.15))
                                )
                        }
                    }

                    HStack(spacing: 8) {
                        sensoryTag(food.texture.label, icon: "waveform")
                        sensoryTag(food.flavor.label, icon: "drop.fill")
                        sensoryTag(food.category.label, icon: food.category.icon)
                    }
                }

                Spacer()

                let progress = viewModel.questProgress(for: food.id)
                if let progress, !progress.completedStepValues.isEmpty {
                    HStack(spacing: 4) {
                        if progress.isComplete {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(SpaceTheme.starGold)
                        } else {
                            Text("\(Int(progress.progressFraction * 100))%")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(SpaceTheme.cosmicCyan)
                        }
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private func sensoryTag(_ text: String, icon: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
            Text(text)
                .font(.system(.caption2, design: .rounded))
        }
        .foregroundStyle(.white.opacity(0.4))
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 40)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.2))

            Text("No foods found for \"\(searchText)\"")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))

            Button {
                showCreateFood = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Create \"\(searchText)\"")
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                        Text("Add as a custom food")
                            .font(.system(.caption, design: .rounded))
                            .opacity(0.7)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .opacity(0.5)
                }
                .foregroundStyle(SpaceTheme.deepNavy)
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(SpaceTheme.cosmicCyan)
                )
            }
            .padding(.horizontal, 20)
        }
    }

    private var createCustomFoodRow: some View {
        Button {
            showCreateFood = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(SpaceTheme.cosmicCyan.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Create \"\(searchText)\"")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(SpaceTheme.cosmicCyan)
                    Text("Add as a custom food")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(SpaceTheme.cosmicCyan.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.white.opacity(0.03))
        }
    }
}
