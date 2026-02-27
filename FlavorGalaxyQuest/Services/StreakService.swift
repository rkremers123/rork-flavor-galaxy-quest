import Foundation

struct StreakService {

    static func updateStreak(profile: inout ChildProfile, interactions: [SensoryInteraction]) {
        guard let lastInteraction = interactions.sorted(by: { $0.timestamp > $1.timestamp }).first else {
            return
        }

        let calendar = Calendar.current
        let lastDate = calendar.startOfDay(for: lastInteraction.timestamp)
        let today = calendar.startOfDay(for: Date())
        let daysSinceLastAction = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0

        if daysSinceLastAction > 1 {
            if profile.currentStreak > 0 {
                profile.longestStreak = max(profile.longestStreak, profile.currentStreak)
                profile.currentStreak = 0
                profile.streakBrokenDate = lastInteraction.timestamp
            }
        }
    }

    static func recordDailyAction(profile: inout ChildProfile) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = profile.lastActivityDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysBetween == 0 {
                return
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
    }

    static func canResumeStreak(profile: ChildProfile) -> Bool {
        guard let resumeDate = profile.lastStreakResumeDate else { return true }
        let calendar = Calendar.current
        let resumeMonth = calendar.component(.month, from: resumeDate)
        let currentMonth = calendar.component(.month, from: Date())
        return resumeMonth != currentMonth
    }

    static func resumeStreak(profile: inout ChildProfile) {
        guard canResumeStreak(profile: profile) else { return }
        profile.currentStreak = max(profile.currentStreak, 1)
        profile.lastStreakResumeDate = Date()
        profile.lastActivityDate = Date()
    }
}
