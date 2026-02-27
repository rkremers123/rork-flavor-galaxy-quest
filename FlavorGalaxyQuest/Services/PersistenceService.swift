import Foundation

struct PersistenceService {
    private static let profileKey = "child_profile"
    private static let onboardedKey = "has_onboarded"
    private static let questStatePrefix = "quest_state_"

    static func saveProfile(_ profile: ChildProfile) {
        guard let data = try? JSONEncoder().encode(profile) else { return }
        UserDefaults.standard.set(data, forKey: profileKey)
    }

    static func loadProfile() -> ChildProfile? {
        guard let data = UserDefaults.standard.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(ChildProfile.self, from: data)
    }

    static var hasOnboarded: Bool {
        get { UserDefaults.standard.bool(forKey: onboardedKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardedKey) }
    }

    static func saveQuestState(_ progress: QuestProgress, for foodId: UUID) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: questStatePrefix + foodId.uuidString)
    }

    static func loadQuestState(for foodId: UUID) -> QuestProgress? {
        guard let data = UserDefaults.standard.data(forKey: questStatePrefix + foodId.uuidString) else { return nil }
        return try? JSONDecoder().decode(QuestProgress.self, from: data)
    }

    static func resetAll() {
        UserDefaults.standard.removeObject(forKey: profileKey)
        UserDefaults.standard.removeObject(forKey: onboardedKey)
    }
}
