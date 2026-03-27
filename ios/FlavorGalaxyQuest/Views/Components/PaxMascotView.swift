import SwiftUI

struct PaxMascotView: View {
    let message: String
    var size: CGFloat = 80
    var explorerType: ExplorerType = .nova
    @State private var bounce: Bool = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [SpaceTheme.cosmicCyan.opacity(0.3), .clear],
                            center: .center,
                            startRadius: size * 0.3,
                            endRadius: size * 0.6
                        )
                    )
                    .frame(width: size, height: size)

                Image(explorerType.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.6, height: size * 0.6)
                    .offset(y: bounce ? -4 : 4)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: bounce)
            }
            .frame(width: size, height: size)

            if !message.isEmpty {
                Text(message)
                    .font(.system(.callout, design: .rounded, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(SpaceTheme.spacePurple.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(SpaceTheme.cosmicCyan.opacity(0.4), lineWidth: 1)
                            )
                    )
            }
        }
        .onAppear { bounce = true }
    }
}
