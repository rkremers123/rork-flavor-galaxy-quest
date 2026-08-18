import SwiftUI

/// Rounded galaxy surface. Fill + 1pt stroke, no drop shadow
/// (the starfield already has depth). Optional accent glow for selected cards.
struct SGCard<Content: View>: View {
    var padding: CGFloat = 16
    var corner: CGFloat = SGRadius.card
    var accent: Color? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(SGColor.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(accent ?? SGColor.cardStroke, lineWidth: 1)
            )
            .shadow(
                color: (accent ?? .clear).opacity(accent == nil ? 0 : 0.35),
                radius: accent == nil ? 0 : 12,
                y: 0
            )
    }
}
