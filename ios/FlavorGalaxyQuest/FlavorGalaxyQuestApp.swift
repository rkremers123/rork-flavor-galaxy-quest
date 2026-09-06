import SwiftUI
import SwiftData
import RevenueCat

@main
struct FlavorGalaxyQuestApp: App {
    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        let apiKey = Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY
        #else
        let apiKey = Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
        #endif
        // Empty scaffold keys would crash Purchases.configure — wait for real RevenueCat keys.
        if !apiKey.isEmpty {
            Purchases.configure(withAPIKey: apiKey)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            ChildProfileModel.self,
            QuestProgressModel.self,
            SensoryInteractionModel.self,
            BridgeRecordModel.self,
            CustomFoodModel.self,
            RegressionModel.self
        ])
    }
}
