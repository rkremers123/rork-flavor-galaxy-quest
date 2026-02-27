import Foundation

@Observable
@MainActor
class SubscriptionManager {
    var isPaidTier: Bool = false
    var isTrialActive: Bool = false
    var trialExpirationDate: Date?

    static let shared = SubscriptionManager()

    private init() {
        isPaidTier = UserDefaults.standard.bool(forKey: "isPaidTier")
    }

    var hasAccess: Bool {
        isPaidTier || isTrialActive
    }

    func startFreeTrial() {
        isTrialActive = true
        trialExpirationDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        UserDefaults.standard.set(true, forKey: "isTrialActive")
    }

    func upgradeToPaid() {
        isPaidTier = true
        UserDefaults.standard.set(true, forKey: "isPaidTier")
    }

    func restorePurchases() {
        isPaidTier = UserDefaults.standard.bool(forKey: "isPaidTier")
    }
}
