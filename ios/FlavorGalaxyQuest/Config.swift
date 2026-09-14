// Config.swift - Auto-generated at build time
// Keys are scaffolded from project env vars; values are injected by CI

import Foundation

enum Config {
    static let EXPO_PUBLIC_PROJECT_ID = ""
    static let EXPO_PUBLIC_RORK_API_BASE_URL = ""
    static let EXPO_PUBLIC_TEAM_ID = ""
    static let EXPO_PUBLIC_TOOLKIT_URL = ""
    static let EXPO_PUBLIC_REVENUECAT_TEST_API_KEY = ""
    static let EXPO_PUBLIC_REVENUECAT_IOS_API_KEY = ""

    static let allValues: [String: String] = [
        "EXPO_PUBLIC_PROJECT_ID": EXPO_PUBLIC_PROJECT_ID,
        "EXPO_PUBLIC_RORK_API_BASE_URL": EXPO_PUBLIC_RORK_API_BASE_URL,
        "EXPO_PUBLIC_TEAM_ID": EXPO_PUBLIC_TEAM_ID,
        "EXPO_PUBLIC_TOOLKIT_URL": EXPO_PUBLIC_TOOLKIT_URL,
        "EXPO_PUBLIC_REVENUECAT_TEST_API_KEY": EXPO_PUBLIC_REVENUECAT_TEST_API_KEY,
        "EXPO_PUBLIC_REVENUECAT_IOS_API_KEY": EXPO_PUBLIC_REVENUECAT_IOS_API_KEY,
    ]

    /// RevenueCat keys are still empty in this scaffold — do not promise a live trial purchase path.
    static var billingConfigured: Bool {
        !EXPO_PUBLIC_REVENUECAT_IOS_API_KEY.isEmpty
            || !EXPO_PUBLIC_REVENUECAT_TEST_API_KEY.isEmpty
    }
}
