import SwiftUI

struct StarDustCounter: View {
    let amount: Int
    @State private var displayedAmount: Int = 0
    @State private var sparkle: Int = 0

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.subheadline.bold())
                .foregroundStyle(SpaceTheme.starGold)
                .symbolEffect(.bounce, value: sparkle)

            Text("\(displayedAmount)")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(SpaceTheme.starGold)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(SpaceTheme.deepNavy.opacity(0.8))
                .overlay(
                    Capsule()
                        .stroke(SpaceTheme.starGold.opacity(0.4), lineWidth: 1)
                )
        )
        .onAppear { displayedAmount = amount }
        .onChange(of: amount) { _, newValue in
            withAnimation(.spring) {
                displayedAmount = newValue
            }
            sparkle += 1
        }
    }
}
