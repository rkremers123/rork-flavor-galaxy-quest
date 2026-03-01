import Foundation
import RevenueCat

@Observable
@MainActor
class SubscriptionManager {
    var isPremium: Bool = false
    var offerings: Offerings?
    var isLoading: Bool = false
    var isPurchasing: Bool = false
    var errorMessage: String?
    var showError: Bool = false

    static let shared = SubscriptionManager()

    private init() {}

    var hasAccess: Bool {
        isPremium
    }

    func fetchOfferings() async {
        isLoading = true
        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
    }

    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = customerInfo.entitlements["premium"]?.isActive == true
        } catch {
            isPremium = false
        }
    }

    func purchase(package: Package) async -> Bool {
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: package)
            if result.customerInfo.entitlements["premium"]?.isActive == true {
                isPremium = true
                isPurchasing = false
                return true
            }
        } catch {
            showError(error.localizedDescription)
        }
        isPurchasing = false
        return false
    }

    func restorePurchases() async {
        isLoading = true
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            isPremium = customerInfo.entitlements["premium"]?.isActive == true
            if !isPremium {
                showError("No active subscription found.")
            }
        } catch {
            showError(error.localizedDescription)
        }
        isLoading = false
    }

    private func showError(_ message: String) {
        errorMessage = message
        showError = true
    }
}
