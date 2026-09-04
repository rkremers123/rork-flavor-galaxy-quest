import SwiftUI
import UIKit

/// Illustrated sensory-step mark when the xcasset exists; emoji (then SF Symbol) otherwise.
struct StepMark: View {
    let step: SensoryStep
    var size: CGFloat = 22
    var tint: Color? = nil

    var body: some View {
        Group {
            if UIImage(named: step.imageName) != nil {
                Image(step.imageName)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                Text(step.emoji)
                    .font(.system(size: max(10, size * 0.78)))
            }
        }
        .frame(width: size, height: size)
        .foregroundStyle(tint ?? .primary)
        .accessibilityHidden(true)
    }
}
