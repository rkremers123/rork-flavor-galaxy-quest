import SwiftUI

// Sensory Galaxy design tokens.
// Keep the seven SpaceTheme colors — planet / journey code depends on them.
// Banned in first-run UI: Color(.systemGray*), Color(.systemGroupedBackground),
// Color(.secondarySystemGroupedBackground), Color.accentColor, cream lavenders,
// periwinkle (0.4, 0.49, 0.92), and cosmicCyan.opacity(0.8) fills.

enum SpaceTheme {
    static let deepNavy = Color(red: 0.04, green: 0.04, blue: 0.14)
    static let spacePurple = Color(red: 0.12, green: 0.04, blue: 0.28)
    static let nebulaPink = Color(red: 0.4, green: 0.1, blue: 0.5)
    static let starGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let cosmicCyan = Color(red: 0.2, green: 0.8, blue: 1.0)
    static let planetGreen = Color(red: 0.2, green: 0.85, blue: 0.4)
    static let warningOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    /// Galaxy void — always the first-run / live-app base. Never cream.
    static let galaxyBackground = deepNavy
    /// Kid primary CTA fill. Pair with deepNavy label. Solid, never 0.8 opacity.
    static let goldCTA = starGold
    /// Parent primary CTA fill. Pair with deepNavy label. Solid cyan.
    static let parentCTA = cosmicCyan
    /// Translucent galaxy surface. Use instead of systemGray / white cards.
    static let cardFill = Color.white.opacity(0.06)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)

    static var spaceGradient: LinearGradient {
        LinearGradient(
            colors: [deepNavy, spacePurple, deepNavy],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func planetColor(hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b)
    }
}

enum SGColor {
    static let void = SpaceTheme.deepNavy
    static let nebula = SpaceTheme.spacePurple
    static let bloom = SpaceTheme.nebulaPink
    static let glow = SpaceTheme.cosmicCyan
    static let gold = SpaceTheme.starGold
    static let leaf = SpaceTheme.planetGreen
    static let ember = SpaceTheme.warningOrange

    static let galaxyBackground = SpaceTheme.galaxyBackground
    static let goldCTA = SpaceTheme.goldCTA
    static let parentCTA = SpaceTheme.parentCTA

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let textMuted = Color.white.opacity(0.38)
    static let textOnCTA = SpaceTheme.deepNavy

    static let card = Color.white.opacity(0.06)
    static let cardStroke = Color.white.opacity(0.12)
    static let chipIdle = Color.white.opacity(0.08)
    static let scrim = Color.black.opacity(0.72)
}

enum SGFont {
    static func display(_ size: CGFloat = 36) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func title(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func headline() -> Font {
        .system(size: 17, weight: .bold, design: .rounded)
    }

    static func body() -> Font {
        .system(size: 16, weight: .medium, design: .rounded)
    }

    static func caption() -> Font {
        .system(size: 13, weight: .semibold, design: .rounded)
    }

    static func stat() -> Font {
        .system(size: 28, weight: .heavy, design: .rounded)
    }
}

enum SGMotion {
    static let step = Animation.spring(response: 0.45, dampingFraction: 0.82)
    static let press = Animation.spring(response: 0.25, dampingFraction: 0.7)
    static let pulse = Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)
    static let mascot = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
}

enum SGRadius {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12
    static let button: CGFloat = 28
}

enum SGOffer {
    static let trialDays = 7
    static let monthly = "$3.99"
    static let yearly = "$24.99"
    static let yearlySave = "Save 48%"
}

/// Root chrome for first-run screens. Background ignores safe area; content does not.
struct SGScreen<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            SpaceBackgroundView()
            VStack(spacing: 0) {
                content()
            }
        }
    }
}

struct SGDotBar: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == index ? SGColor.glow : Color.white.opacity(0.2))
                    .frame(width: i == index ? 28 : 8, height: 8)
                    .animation(SGMotion.step, value: index)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(index + 1) of \(count)")
    }
}

struct SGChip: View {
    let label: String
    var selected: Bool = false
    var action: (() -> Void)?

    var body: some View {
        let pill = Text(label)
            .font(SGFont.caption())
            .tracking(0.8)
            .foregroundStyle(selected ? SGColor.textOnCTA : Color.white.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selected ? SGColor.glow : SGColor.chipIdle)
            )

        if let action {
            Button(action: action) { pill }
                .buttonStyle(.plain)
        } else {
            pill
        }
    }
}
