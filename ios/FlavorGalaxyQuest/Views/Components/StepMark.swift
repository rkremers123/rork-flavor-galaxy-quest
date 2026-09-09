import SwiftUI
import UIKit

/// Illustrated sensory-step mark when the xcasset exists; SF Symbol otherwise (no emoji).
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
                Image(systemName: step.icon)
                    .resizable()
                    .scaledToFit()
                    .padding(size * 0.08)
            }
        }
        .frame(width: size, height: size)
        .foregroundStyle(tint ?? .primary)
        .accessibilityHidden(true)
    }
}
