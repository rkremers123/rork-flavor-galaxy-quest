import Foundation

nonisolated enum SensoryStep: Int, Codable, CaseIterable, Sendable, Hashable {
    case look = 0
    case touch = 1
    case smell = 2
    case lick = 3
    case taste = 4

    var label: String {
        switch self {
        case .look: "Look"
        case .touch: "Touch"
        case .smell: "Smell"
        case .lick: "Lick"
        case .taste: "Taste"
        }
    }

    /// Catalog name for the optional "ate / swallowed / brave bite" mark.
    /// Not a ladder step — distinct from `.lick` / `.taste` (see `imageName`).
    static let ateImageName = "step_ate"

    /// Asset catalog name for illustrated step marks (`step_look`, …).
    /// Lick is distinct from the optional `step_ate` asset (not a ladder step).
    var imageName: String {
        switch self {
        case .look: "step_look"
        case .touch: "step_touch"
        case .smell: "step_smell"
        case .lick: "step_lick"
        case .taste: "step_taste"
        }
    }

    /// Emoji fallback when the illustrated asset is missing.
    var emoji: String {
        switch self {
        case .look: "👀"
        case .touch: "✋"
        case .smell: "👃"
        case .lick: "👅"
        case .taste: "😋"
        }
    }

    var icon: String {
        switch self {
        case .look: "eye.fill"
        case .touch: "hand.raised.fill"
        case .smell: "nose.fill"
        case .lick: "mouth.fill"
        case .taste: "fork.knife"
        }
    }

    var missionTitle: String {
        switch self {
        case .look: "Planet Scanner"
        case .touch: "Surface Probe"
        case .smell: "Aroma Detector"
        case .lick: "Butterfly Lick"
        case .taste: "Brave Bite"
        }
    }

    var missionDescription: String {
        switch self {
        case .look: "Use your explorer eyes to scan this planet! What colors and shapes do you see?"
        case .touch: "Time to touch down! Poke it gently. Is it bumpy like a moon rock or smooth like a star?"
        case .smell: "Activate your Scent Scanner! Give it a big sniff. What space aromas do you detect?"
        case .lick: "Deploy the Butterfly Lick! Just a tiny lick, like a butterfly landing on a flower."
        case .taste: "You're SO brave, Explorer! Take a tiny nibble. Remember, you have your shield!"
        }
    }

    var paxEncouragement: String {
        switch self {
        case .look: "Looking counts — eyes on the plate is a real first step. No rush."
        case .touch: "Touch is brave — a poke or nudge means hands are exploring."
        case .smell: "Smell is progress — getting closer, still exploring, still real."
        case .lick: "Lick is real — tongue tip counts. Lick ≠ ate, and that's okay."
        case .taste: "Tiny taste! A nibble counts even if it came back out."
        }
    }

    /// Short headline for step-celebrate overlay (highest step reached).
    var celebrateTitle: String {
        switch self {
        case .look: "Looking counts"
        case .touch: "Touch is brave"
        case .smell: "Smell is progress"
        case .lick: "Lick is real"
        case .taste: "Tiny taste!"
        }
    }

    /// Parent-facing soft regression line when tonight dipped vs a prior success.
    static func softRegressionLine(foodName: String, prior: SensoryStep, current: SensoryStep) -> String? {
        guard current.rawValue < prior.rawValue else { return nil }
        return "Last success on \(foodName) dipped to \(current.label.lowercased()) (was \(prior.label.lowercased())) — still progress, keep it gentle."
    }

    var starDustReward: Int {
        switch self {
        case .look: 0
        case .touch: 10
        case .smell: 15
        case .lick: 25
        case .taste: 50
        }
    }

    var color: String {
        switch self {
        case .look: "00BFFF"
        case .touch: "FFD700"
        case .smell: "FF69B4"
        case .lick: "7B68EE"
        case .taste: "00FF7F"
        }
    }

    var isHighStakes: Bool {
        self == .lick || self == .taste
    }
}
