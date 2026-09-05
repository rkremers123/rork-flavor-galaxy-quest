import SwiftUI
import UIKit

struct SensoryEducationModal: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    stepsSection
                    ladderSection
                    bottomCallout
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Got it") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Understanding the Sensory Journey")
                .font(.title2.bold())

            Text("Your child's brain learns in small steps, not giant leaps. Before eating is even possible, they need to feel safe with the food first.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Before eating, they need to:")
                .font(.subheadline.weight(.semibold))

            VStack(spacing: 0) {
                stepRow(step: .look, color: .cyan, title: "LOOK", timeline: "Day 1–3", description: "Get used to seeing it without fear")
                Divider().padding(.leading, 52)
                stepRow(step: .touch, color: .blue, title: "TOUCH", timeline: "Day 3–7", description: "Hands explore the texture safely")
                Divider().padding(.leading, 52)
                stepRow(step: .smell, color: .purple, title: "SMELL", timeline: "Day 5–10", description: "Nose gets familiar with the aroma")
                Divider().padding(.leading, 52)
                stepRow(step: .lick, color: .orange, title: "LICK", timeline: "Day 7–14", description: "Mouth says 'hello' — a tiny contact")
                Divider().padding(.leading, 52)
                stepRow(step: .taste, color: .green, title: "TASTE", timeline: "Day 10–21", description: "A small bite — spitting out is OK!")
                Divider().padding(.leading, 52)
                stepRow(ateMark: true, color: .green, title: "SWALLOW", timeline: "Day 14+", description: "Eating happens naturally over time")
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private func stepRow(
        step: SensoryStep? = nil,
        ateMark: Bool = false,
        color: Color,
        title: String,
        timeline: String,
        description: String
    ) -> some View {
        HStack(spacing: 12) {
            Group {
                if ateMark {
                    if UIImage(named: SensoryStep.ateImageName) != nil {
                        Image(SensoryStep.ateImageName)
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.callout)
                            .foregroundStyle(color)
                            .frame(width: 28)
                    }
                } else if let step {
                    StepMark(step: step, size: 28, tint: color)
                } else {
                    Image(systemName: "circle")
                        .font(.callout)
                        .foregroundStyle(color)
                        .frame(width: 28)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text(timeline)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(.tertiarySystemFill)))
                }
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 10)
    }

    /// Dinner-quest ladder framing — inspired by SOS, not an official SOS program.
    private var ladderSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Inspired by the SOS dinner ladder")
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: 8) {
                credentialRow("LOOK, TOUCH, SMELL, LICK, TASTE — looking counts")
                credentialRow("Built for sensory picky eating, including autism & SPD")
                credentialRow("Not an official SOS program or a medical device")
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func credentialRow(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.green)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var bottomCallout: some View {
        VStack(spacing: 6) {
            Text("Each step is a WIN.")
                .font(.headline)
            Text("Eating is the bonus.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.green.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
