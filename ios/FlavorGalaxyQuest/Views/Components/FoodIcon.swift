import SwiftUI
import UIKit

/// Illustrated food art when the xcasset exists; SF Symbol otherwise.
/// Custom (non-catalog) foods fall back to `food_custom_gem`, then fork.knife.
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
                Image(systemName: "fork.knife")
                    .font(.system(size: max(11, size * 0.62), weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
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
