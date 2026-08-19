import Foundation
import CryptoKit

struct PersistenceService {
    private static let onboardedKey = "has_onboarded"
    private static let parentPINHashKey = "parent_pin_hash"
    private static let pinSalt = "sg-parent-pin-v1:"

    static var hasOnboarded: Bool {
        get { UserDefaults.standard.bool(forKey: onboardedKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardedKey) }
    }

    static var hasParentPIN: Bool {
        guard let value = UserDefaults.standard.string(forKey: parentPINHashKey) else { return false }
        return !value.isEmpty
    }

    static func setParentPIN(_ pin: String) {
        guard pin.count == 4, pin.allSatisfy(\.isNumber) else { return }
        UserDefaults.standard.set(hashPIN(pin), forKey: parentPINHashKey)
    }

    static func verifyParentPIN(_ pin: String) -> Bool {
        guard let stored = UserDefaults.standard.string(forKey: parentPINHashKey), !stored.isEmpty else {
            return false
        }
        return stored == hashPIN(pin)
    }

    static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: onboardedKey)
        UserDefaults.standard.removeObject(forKey: parentPINHashKey)
    }

    private static func hashPIN(_ pin: String) -> String {
        let data = Data((pinSalt + pin).utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
