import SwiftUI
import UIKit

struct CertificateView: View {
    let childName: String
    let explorerType: ExplorerType
    let foodsExplored: Int
    let starDust: Int
    let daysActive: Int
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var showShareSheet = false
    @State private var renderedImage: UIImage?

    var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button { onDismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView {
                    VStack(spacing: 24) {
                        certificateCard
                            .scaleEffect(appeared ? 1.0 : 0.85)
                            .opacity(appeared ? 1 : 0)

                        HStack(spacing: 16) {
                            Button {
                                renderAndShare()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(SpaceTheme.deepNavy)
                                .padding(.horizontal, 28)
                                .padding(.vertical, 14)
                                .background(Capsule().fill(SpaceTheme.starGold))
                            }

                            Button { onDismiss() } label: {
                                Text("Close")
                                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 14)
                                    .background(Capsule().fill(.white.opacity(0.08)))
                            }
                        }
                        .opacity(appeared ? 1 : 0)
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                CertificateShareSheet(activityItems: [image])
            }
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8).delay(0.2)) {
                appeared = true
            }
        }
    }

    private var certificateCard: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                certificateBrandMark(size: 44)

                Group {
                    if UIImage(named: "wordmark_sensory_galaxy") != nil {
                        Image("wordmark_sensory_galaxy")
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(height: 18)
                    } else {
                        Text("SENSORY GALAXY")
                            .font(.system(.caption, design: .rounded, weight: .heavy))
                            .tracking(4)
                    }
                }
                .foregroundStyle(SpaceTheme.starGold)

                Rectangle()
                    .fill(SpaceTheme.starGold.opacity(0.3))
                    .frame(width: 120, height: 1)
            }

            VStack(spacing: 6) {
                Text("Explorer's Certificate")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                Text("This certifies that")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }

            VStack(spacing: 8) {
                Text(childName)
                    .font(.system(.title, design: .rounded, weight: .heavy))
                    .foregroundStyle(SpaceTheme.cosmicCyan)

                HStack(spacing: 8) {
                    Image(explorerType.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 36)
                    Text(explorerType.title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }

            VStack(spacing: 4) {
                Text("has completed the")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                Text("Sensory Galaxy Journey")
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .foregroundStyle(SpaceTheme.starGold)
            }

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 20)

            HStack(spacing: 20) {
                certStat(value: "\(foodsExplored)", label: "Foods\nExplored", icon: "globe.americas.fill")
                certStat(value: "\(starDust)", label: "Star Dust\nEarned", icon: "sparkles")
                certStat(value: "\(daysActive)", label: "Days\nActive", icon: "calendar")
            }

            Rectangle()
                .fill(.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 20)

            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(JourneyPlanet.allCases, id: \.self) { planet in
                        Image(planet.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .clipShape(Circle())
                    }
                }

                Text(Date.now.formatted(date: .long, time: .omitted))
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            SpaceTheme.deepNavy,
                            SpaceTheme.spacePurple.opacity(0.6),
                            SpaceTheme.deepNavy
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [SpaceTheme.starGold.opacity(0.5), SpaceTheme.cosmicCyan.opacity(0.3), SpaceTheme.starGold.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }

    private func certStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(SpaceTheme.starGold.opacity(0.6))
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    @MainActor
    private func renderAndShare() {
        let content = CertificateRenderContent(
            childName: childName,
            explorerType: explorerType,
            foodsExplored: foodsExplored,
            starDust: starDust,
            daysActive: daysActive
        )
        let renderer = ImageRenderer(content: content.frame(width: 400))
        renderer.scale = 3
        if let image = renderer.uiImage {
            renderedImage = image
            showShareSheet = true
        }
    }

    @ViewBuilder
    private func certificateBrandMark(size: CGFloat) -> some View {
        if UIImage(named: "badge_saturn") != nil {
            Image("badge_saturn")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: size, height: size)
        } else if UIImage(named: "wordmark_sensory_galaxy") != nil {
            Image("wordmark_sensory_galaxy")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(height: size * 0.4)
        } else {
            Text("🌌")
                .font(.system(size: size))
        }
    }
}

struct CertificateRenderContent: View {
    let childName: String
    let explorerType: ExplorerType
    let foodsExplored: Int
    let starDust: Int
    let daysActive: Int

    var body: some View {
        VStack(spacing: 16) {
            Group {
                if UIImage(named: "wordmark_sensory_galaxy") != nil {
                    Image("wordmark_sensory_galaxy")
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(height: 22)
                } else if UIImage(named: "badge_saturn") != nil {
                    HStack(spacing: 6) {
                        Image("badge_saturn")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                        Text("SENSORY GALAXY")
                            .font(.system(.headline, design: .rounded, weight: .heavy))
                    }
                } else {
                    Text("🌌 SENSORY GALAXY")
                        .font(.system(.headline, design: .rounded, weight: .heavy))
                }
            }

            Text("Explorer's Certificate")
                .font(.system(.title2, design: .rounded, weight: .bold))

            Text(childName)
                .font(.system(.title, design: .rounded, weight: .heavy))
                .foregroundStyle(.cyan)

            HStack(spacing: 6) {
                Image(explorerType.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
                Text(explorerType.title)
                    .font(.subheadline)
            }

            Text("Has completed the Sensory Galaxy Journey!")
                .font(.subheadline.weight(.medium))

            HStack(spacing: 24) {
                VStack {
                    Text("\(foodsExplored)").font(.title3.bold())
                    Text("Foods").font(.caption)
                }
                VStack {
                    Text("\(starDust)").font(.title3.bold())
                    Text("Star Dust").font(.caption)
                }
                VStack {
                    Text("\(daysActive)").font(.title3.bold())
                    Text("Days").font(.caption)
                }
            }

            HStack(spacing: 4) {
                ForEach(JourneyPlanet.allCases, id: \.self) { planet in
                    Image(planet.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .clipShape(Circle())
                }
            }

            Text(Date.now.formatted(date: .long, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .background(Color.white)
    }
}

struct CertificateShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
