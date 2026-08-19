import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let subscription: SubscriptionManager
    private enum OfferPlan {
        case monthly
        case yearly
    }

    @State private var selectedPackage: Package?
    @State private var availablePackages: [Package] = []
    @State private var selectedPlan: OfferPlan = .yearly

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.04, blue: 0.12),
                        Color(red: 0.12, green: 0.06, blue: 0.25),
                        Color(red: 0.04, green: 0.04, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        featuresSection
                        packagesSection
                        ctaSection
                        legalSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)

                if subscription.isLoading || subscription.isPurchasing {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            .alert("Error", isPresented: Binding(
                get: { subscription.showError },
                set: { subscription.showError = $0 }
            )) {
                Button("OK") {}
            } message: {
                Text(subscription.errorMessage ?? "Something went wrong.")
            }
        }
        .task {
            await subscription.fetchOfferings()
            if let current = subscription.offerings?.current {
                availablePackages = current.availablePackages
                selectedPackage = current.annual ?? current.monthly ?? current.availablePackages.first
                if selectedPackage?.packageType == .monthly {
                    selectedPlan = .monthly
                } else {
                    selectedPlan = .yearly
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.4, green: 0.3, blue: 0.9).opacity(0.6),
                                Color(red: 0.2, green: 0.1, blue: 0.5).opacity(0.3),
                                .clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 60
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [SpaceTheme.cosmicCyan, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("Keep Your Adventure Going")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            Text("Unlock the full Sensory Galaxy experience\nwith powerful tools for you and your explorer")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            featureRow(
                icon: "wand.and.stars",
                color: SpaceTheme.cosmicCyan,
                title: "Smart Recommendations",
                subtitle: "AI-powered food suggestions based on success patterns"
            )
            Divider().overlay(.white.opacity(0.06)).padding(.leading, 52)
            featureRow(
                icon: "chart.bar.fill",
                color: .purple,
                title: "Deep Analytics",
                subtitle: "Texture, flavor & temperature profile visualizations"
            )
            Divider().overlay(.white.opacity(0.06)).padding(.leading, 52)
            featureRow(
                icon: "magnifyingglass",
                color: .orange,
                title: "Pattern Detection",
                subtitle: "Detect regressions and sensory avoidance trends"
            )
            Divider().overlay(.white.opacity(0.06)).padding(.leading, 52)
            featureRow(
                icon: "doc.text.fill",
                color: SpaceTheme.planetGreen,
                title: "Therapist Export",
                subtitle: "Share progress data as PDF with your OT or SLP"
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.callout)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var packagesSection: some View {
        VStack(spacing: 10) {
            offerRow(
                title: "Monthly",
                price: monthlyPriceLabel,
                detail: "Cancel anytime",
                badge: nil,
                plan: .monthly
            )
            offerRow(
                title: "Yearly",
                price: yearlyPriceLabel,
                detail: "Best value · \(SGOffer.yearlySave)",
                badge: SGOffer.yearlySave,
                plan: .yearly
            )
        }
    }

    private func offerRow(title: String, price: String, detail: String, badge: String?, plan: OfferPlan) -> some View {
        let isSelected = selectedPlan == plan
        return Button {
            withAnimation(.spring(duration: 0.25)) {
                selectedPlan = plan
                selectedPackage = storePackage(for: plan)
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? SpaceTheme.cosmicCyan : .white.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(SpaceTheme.cosmicCyan)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(.white)

                        if let badge {
                            Text(badge.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(SpaceTheme.planetGreen)
                                )
                        }
                    }

                    Text(detail)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Text(price)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? SpaceTheme.cosmicCyan.opacity(0.08) : .white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isSelected ? SpaceTheme.cosmicCyan.opacity(0.4) : .white.opacity(0.06),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
        }
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            Button {
                guard let package = storePackage(for: selectedPlan) else { return }
                Task {
                    let success = await subscription.purchase(package: package)
                    if success {
                        dismiss()
                    }
                }
            } label: {
                VStack(spacing: 4) {
                    Text("Start \(SGOffer.trialDays)-day free trial")
                        .font(.system(.headline, design: .rounded))
                    Text(ctaSubtitleText)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [SpaceTheme.cosmicCyan, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 14))
            }
            .disabled(subscription.isPurchasing)

            Button {
                Task {
                    await subscription.restorePurchases()
                    if subscription.isPremium {
                        dismiss()
                    }
                }
            } label: {
                Text("Restore Purchases")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private var legalSection: some View {
        VStack(spacing: 6) {
            Text("Start with a \(SGOffer.trialDays)-day free trial. Then \(SGOffer.monthly)/month or \(SGOffer.yearly)/year.")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)

            Text("Payment will be charged to your Apple ID account. Subscription auto-renews unless canceled at least 24 hours before the end of the current period.")
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.white.opacity(0.25))
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Button("Terms of Use") {}
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.3))
                Button("Privacy Policy") {}
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(.bottom, 8)
    }

    private var monthlyPackage: Package? {
        availablePackages.first { $0.packageType == .monthly }
    }

    private var yearlyPackage: Package? {
        availablePackages.first { $0.packageType == .annual }
    }

    private var monthlyPriceLabel: String {
        monthlyPackage?.storeProduct.localizedPriceString ?? SGOffer.monthly
    }

    private var yearlyPriceLabel: String {
        yearlyPackage?.storeProduct.localizedPriceString ?? SGOffer.yearly
    }

    private var ctaSubtitleText: String {
        switch selectedPlan {
        case .monthly:
            return "then \(monthlyPriceLabel)/month"
        case .yearly:
            return "then \(yearlyPriceLabel)/year"
        }
    }

    private func storePackage(for plan: OfferPlan) -> Package? {
        switch plan {
        case .monthly:
            return monthlyPackage
        case .yearly:
            return yearlyPackage
        }
    }
}
