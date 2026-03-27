import SwiftUI

struct CharacterSelectionView: View {
    @Binding var selectedType: ExplorerType
    @Binding var customName: String
    @State private var appeared: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 12)

            Text("Choose Your Explorer")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                ForEach(ExplorerType.allCases, id: \.self) { type in
                    let isSelected = selectedType == type
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedType = type
                        }
                    } label: {
                        VStack(spacing: 10) {
                            Image(type.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                                .scaleEffect(isSelected ? 1.1 : 1.0)

                            Text(type.defaultName)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .foregroundStyle(.white)

                            Text(type.title)
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(SpaceTheme.cosmicCyan)

                            Text(type.tagline)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(
                                    isSelected
                                        ? SpaceTheme.planetColor(hex: type.accentHex).opacity(0.2)
                                        : .white.opacity(0.05)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(
                                            isSelected
                                                ? SpaceTheme.planetColor(hex: type.accentHex).opacity(0.7)
                                                : .white.opacity(0.1),
                                            lineWidth: isSelected ? 2.5 : 1
                                        )
                                )
                        )
                    }
                    .sensoryFeedback(.selection, trigger: isSelected)
                }
            }
            .padding(.horizontal, 20)

            VStack(alignment: .leading, spacing: 8) {
                Text("Name Your Explorer")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(SpaceTheme.cosmicCyan)

                TextField(selectedType.defaultName, text: $customName)
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
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring.delay(0.2)) { appeared = true }
        }
    }
}
