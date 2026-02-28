import SwiftData
import Foundation

nonisolated enum RegressionStatus: String, Codable, Sendable {
    case active
    case resolved
}

@Model
class RegressionModel {
    var id: UUID = UUID()
    var foodId: UUID = UUID()
    var foodName: String = ""
    var regressionDate: Date = Date()
    var masterDate: Date = Date()
    var parentNotes: String = ""
    var statusRawValue: String = RegressionStatus.active.rawValue
    var resolvedDate: Date?

    var textureRawValue: String = ""
    var flavorRawValue: String = ""
    var temperatureRawValue: String = ""

    var profile: ChildProfileModel?

    init() {}

    init(foodId: UUID, foodName: String, regressionDate: Date, masterDate: Date, texture: FoodTexture, flavor: FoodFlavor, temperature: FoodTemperature, notes: String = "") {
        self.id = UUID()
        self.foodId = foodId
        self.foodName = foodName
        self.regressionDate = regressionDate
        self.masterDate = masterDate
        self.parentNotes = notes
        self.textureRawValue = texture.rawValue
        self.flavorRawValue = flavor.rawValue
        self.temperatureRawValue = temperature.rawValue
        self.statusRawValue = RegressionStatus.active.rawValue
    }

    var status: RegressionStatus {
        get { RegressionStatus(rawValue: statusRawValue) ?? .active }
        set { statusRawValue = newValue.rawValue }
    }

    var texture: FoodTexture {
        FoodTexture(rawValue: textureRawValue) ?? .soft
    }

    var flavor: FoodFlavor {
        FoodFlavor(rawValue: flavorRawValue) ?? .bland
    }

    var temperature: FoodTemperature {
        FoodTemperature(rawValue: temperatureRawValue) ?? .roomTemp
    }

    var daysToRegress: Int {
        Calendar.current.dateComponents([.day], from: masterDate, to: regressionDate).day ?? 0
    }

    var daysSinceRegression: Int {
        Calendar.current.dateComponents([.day], from: regressionDate, to: Date()).day ?? 0
    }
}
