import SwiftUI
import UIKit

/// Illustrated food art when the xcasset exists; emoji otherwise.
/// Custom (non-catalog) foods fall back to `food_custom_gem`, then emoji.
struct FoodIcon: View {
    let food: FoodItem
    var size: CGFloat = 24

    var body: some View {
        Group {
            if let asset = resolvedAssetName {
                Image(asset)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                Text(food.emoji)
                    .font(.system(size: max(12, size * 0.78)))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var resolvedAssetName: String? {
        if UIImage(named: food.iconName) != nil {
            return food.iconName
        }
        let inCatalog = FoodDatabase.food(byId: food.id) != nil
            || FoodDatabase.food(byName: food.name) != nil
        if !inCatalog, UIImage(named: FoodItem.customGemIconName) != nil {
            return FoodItem.customGemIconName
        }
        return nil
    }
}
