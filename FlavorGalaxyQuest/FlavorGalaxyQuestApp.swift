import SwiftUI
import SwiftData

@main
struct FlavorGalaxyQuestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            ChildProfileModel.self,
            QuestProgressModel.self,
            SensoryInteractionModel.self,
            BridgeRecordModel.self
        ])
    }
}
