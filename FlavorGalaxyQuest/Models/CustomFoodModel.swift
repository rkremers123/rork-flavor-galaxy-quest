import SwiftData
import Foundation

@Model
class CustomFoodModel {
    var foodId: UUID = UUID()
    var name: String = ""
    var textureRawValue: String = FoodTexture.soft.rawValue
    var flavorRawValue: String = FoodFlavor.bland.rawValue
    var temperatureRawValue: String = FoodTemperature.roomTemp.rawValue
    var createdDate: Date = Date()

    init() {}

    init(name: String, texture: FoodTexture, flavor: FoodFlavor, temperature: FoodTemperature) {
        self.foodId = UUID()
        self.name = name
        self.textureRawValue = texture.rawValue
        self.flavorRawValue = flavor.rawValue
        self.temperatureRawValue = temperature.rawValue
        self.createdDate = Date()
    }

    var texture: FoodTexture {
        get { FoodTexture(rawValue: textureRawValue) ?? .soft }
        set { textureRawValue = newValue.rawValue }
    }

    var flavor: FoodFlavor {
        get { FoodFlavor(rawValue: flavorRawValue) ?? .bland }
        set { flavorRawValue = newValue.rawValue }
    }

    var temperature: FoodTemperature {
        get { FoodTemperature(rawValue: temperatureRawValue) ?? .roomTemp }
        set { temperatureRawValue = newValue.rawValue }
    }

    func toFoodItem() -> FoodItem {
        FoodItem(
            id: foodId,
            name: name,
            emoji: "🍽️",
            texture: texture,
            flavor: flavor,
            temperature: temperature,
            aroma: .mild,
            category: .protein,
            planetColorHex: generateColorHex()
        )
    }

    private func generateColorHex() -> String {
        let colors = ["FF6B6B", "4ECDC4", "45B7D1", "96CEB4", "FFEAA7", "DDA0DD", "98D8C8", "F7DC6F", "BB8FCE", "85C1E9"]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }
}
