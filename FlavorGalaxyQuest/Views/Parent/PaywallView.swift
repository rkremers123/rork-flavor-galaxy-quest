import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let subscription: SubscriptionManager
    let onUpgrade: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    pricingSection
                    disclaimerSection
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                Image(systemName: "brain.head.profile.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }

            Text("Unlock Sensory Intelligence")
                .font(.title2.bold())

            Text("Get personalized insights, smart recommendations, and therapist collaboration tools")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureRow(icon: "chart.bar.fill", color: .purple, title: "Sensory Analytics", description: "Texture, flavor & temperature profile visualizations")
            Divider().padding(.leading, 52)
            featureRow(icon: "sparkles", color: .blue, title: "Smart Recommendations", description: "AI-powered food suggestions based on success patterns")
            Divider().padding(.leading, 52)
            featureRow(icon: "checkmark.seal.fill", color: .green, title: "Success & Avoidance Zones", description: "See which sensory attributes work best")
            Divider().padding(.leading, 52)
            featureRow(icon: "doc.text.fill", color: .orange, title: "Therapist Reports", description: "Export progress data as PDF for your OT or SLP")
            Divider().padding(.leading, 52)
            featureRow(icon: "lightbulb.fill", color: .yellow, title: "Personalized Insights", description: "Data-driven guidance for next steps")
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func featureRow(icon: String, color: Color, title: String, description: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var pricingSection: some View {
        VStack(spacing: 12) {
            Button {
                onUpgrade()
                dismiss()
            } label: {
                VStack(spacing: 4) {
                    Text("Start 7-Day Free Trial")
                        .font(.headline)
                    Text("Then $4.99/month · Cancel anytime")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 14))
            }

            Button("Restore Purchases") {
                subscription.restorePurchases()
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
        }
    }

    private var disclaimerSection: some View {
        VStack(spacing: 6) {
            Text("The free tier includes the complete SOS protocol, food quests, and gamification. Premium adds analytics and intelligence tools.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Text("Payment will be charged to your Apple ID account. Subscription auto-renews unless canceled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 8)
    }
}
