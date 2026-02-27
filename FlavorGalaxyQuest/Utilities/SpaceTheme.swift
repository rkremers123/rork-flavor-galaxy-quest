import SwiftUI

enum SpaceTheme {
    static let deepNavy = Color(red: 0.04, green: 0.04, blue: 0.14)
    static let spacePurple = Color(red: 0.12, green: 0.04, blue: 0.28)
    static let nebulaPink = Color(red: 0.4, green: 0.1, blue: 0.5)
    static let starGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let cosmicCyan = Color(red: 0.2, green: 0.8, blue: 1.0)
    static let planetGreen = Color(red: 0.2, green: 0.85, blue: 0.4)
    static let warningOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

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
