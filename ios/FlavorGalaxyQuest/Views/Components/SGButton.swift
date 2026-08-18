import SwiftUI

/// Sensory Galaxy primary / ghost button.
/// Kid = solid gold + navy type. Parent = solid cyan + navy type.
/// Ghost = 1pt card stroke + white type. Never a translucent fill that looks disabled.
struct SGButton: View {
    enum Style {
        case kid
        case parent
        case ghost
    }

    let title: String
    var style: Style = .kid
    var icon: String? = nil
    var enabled: Bool = true
    let action: () -> Void

    @State private var tapTick = 0

    var body: some View {
        Button {
            tapTick += 1
            action()
        } label: {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(SGFont.headline())
            .foregroundStyle(labelColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(fill)
            .overlay(stroke)
            .clipShape(Capsule())
        }
        .buttonStyle(SGPressStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
        .sensoryFeedback(.impact, trigger: tapTick)
        .accessibilityAddTraits(.isButton)
    }

    private var labelColor: Color {
        switch style {
        case .kid, .parent: SGColor.textOnCTA
        case .ghost: SGColor.textPrimary
        }
    }

    @ViewBuilder
    private var fill: some View {
        switch style {
        case .kid:
            Capsule().fill(SGColor.goldCTA)
        case .parent:
            Capsule().fill(SGColor.parentCTA)
        case .ghost:
            Capsule().fill(Color.clear)
        }
    }

    @ViewBuilder
    private var stroke: some View {
        if style == .ghost {
            Capsule().stroke(SGColor.cardStroke, lineWidth: 1)
        }
    }
}

private struct SGPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(SGMotion.press, value: configuration.isPressed)
    }
}
