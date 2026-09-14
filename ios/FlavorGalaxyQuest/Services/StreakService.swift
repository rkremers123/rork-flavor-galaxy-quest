import Foundation

nonisolated enum StreakMilestone: Int, CaseIterable, Sendable {
    case threeDays = 3
    case oneWeek = 7
    case twoWeeks = 14
    case oneMonth = 30

    var title: String {
        switch self {
        case .threeDays: return "On a Roll!"
        case .oneWeek: return "Week Warrior!"
        case .twoWeeks: return "Two Weeks Strong!"
        case .oneMonth: return "One Month Explorer!"
        }
    }

    var emoji: String {
        switch self {
        case .threeDays: return "✨"
        case .oneWeek: return "🔥"
        case .twoWeeks: return "⭐️"
        case .oneMonth: return "🏆"
        }
    }

    /// Illustrated mark when the xcasset exists; emoji otherwise.
    var imageName: String {
        switch self {
        case .threeDays: return "star_dust_particle"
        case .oneWeek: return "cosmetic_day7_badge"
        case .twoWeeks: return "cosmetic_week2_badge"
        case .oneMonth: return "cosmetic_month1_badge"
        }
    }

    var message: String {
        switch self {
        case .threeDays: return "Three days in a row! You're building a habit!"
        case .oneWeek: return "A full week of exploring! Your bravery is amazing!"
        case .twoWeeks: return "Two weeks of sensory adventures! You're unstoppable!"
        case .oneMonth: return "One whole month! You're a true Galaxy Explorer!"
        }
    }
}

struct StreakService {

    static func updateStreak(profile: ChildProfileModel) -> Bool {
        let sortedInteractions = profile.interactions.sorted { $0.timestamp > $1.timestamp }
        guard let lastInteraction = sortedInteractions.first else { return false }

        let calendar = Calendar.current
        let lastDate = calendar.startOfDay(for: lastInteraction.timestamp)
        let today = calendar.startOfDay(for: Date())
        let daysSinceLastAction = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0

        if daysSinceLastAction > 1 {
            if profile.currentStreak > 0 {
                profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
                profile.currentStreak = 0
                profile.streakBrokenDate = lastInteraction.timestamp
                return true
            }
        }
        return false
    }

    static func recordDailyAction(profile: ChildProfileModel) -> StreakMilestone? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = profile.lastActivityDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 0 {
                return nil
            } else if daysBetween == 1 {
                profile.currentStreak += 1
            } else {
                profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
                profile.currentStreak = 1
            }
        } else {
            profile.currentStreak = 1
        }

        profile.lastActivityDate = Date()
        profile.longestStreak = max(profile.longestStreak, profile.currentStreak)

        return checkMilestone(streak: profile.currentStreak)
    }

    static func checkMilestone(streak: Int) -> StreakMilestone? {
        StreakMilestone.allCases.first { $0.rawValue == streak }
    }

    static func canResumeStreak(profile: ChildProfileModel) -> Bool {
        guard let resumeDate = profile.lastStreakResumeDate else { return true }
        let calendar = Calendar.current
        let resumeMonth = calendar.component(.month, from: resumeDate)
        let currentMonth = calendar.component(.month, from: Date())
        return resumeMonth != currentMonth
    }

    static func resumeStreak(profile: ChildProfileModel) {
        guard canResumeStreak(profile: profile) else { return }
        profile.currentStreak = max(profile.currentStreak, 1)
        profile.lastStreakResumeDate = Date()
        profile.lastActivityDate = Date()
    }
}
