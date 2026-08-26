import SwiftUI

struct JourneyMapView: View {
    let currentPlanet: JourneyPlanet
    let progress: Double
    let explorerType: ExplorerType
    let foodsExplored: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerRow
            planetScroll
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var headerRow: some View {
        HStack {
            Text("Explorer's Journey")
                .font(.system(.subheadline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            Text("\(foodsExplored) foods explored")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var planetScroll: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(JourneyPlanet.allCases, id: \.self) { planet in
                    planetNode(planet)
                }
            }
        }
        .contentMargins(.horizontal, 4)
        .scrollIndicators(.hidden)
    }

    private func planetNode(_ planet: JourneyPlanet) -> some View {
        let isReached = planet.rawValue <= currentPlanet.rawValue
        let isCurrent = planet == currentPlanet

        return HStack(spacing: 0) {
            VStack(spacing: 6) {
                planetCircle(planet: planet, isReached: isReached, isCurrent: isCurrent)

                Text(planet.name)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(isReached ? .white : .white.opacity(0.35))
                    .lineLimit(1)

                Text(planet.subtitle)
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
                    .lineLimit(1)
            }
            .frame(width: 72)

            if planet != .harvestFestival {
                connector(planet: planet)
            }
        }
    }

    private func planetCircle(planet: JourneyPlanet, isReached: Bool, isCurrent: Bool) -> some View {
        let fillColor: Color = isReached ? planetColor(for: planet) : .white.opacity(0.06)
        let strokeColor: Color = isCurrent ? SpaceTheme.starGold : .clear
        let shadowColor: Color = isCurrent ? SpaceTheme.starGold.opacity(0.4) : .clear

        return ZStack {
            Circle()
                .fill(fillColor)
                .frame(width: 48, height: 48)
                .overlay(Circle().stroke(strokeColor, lineWidth: 2.5))
                .shadow(color: shadowColor, radius: 8)

            Image(planet.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .opacity(isReached ? 1.0 : 0.3)

            if isCurrent {
                Image(explorerType.boardImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)
                    .offset(y: -30)
            }
        }
    }

    private func connector(planet: JourneyPlanet) -> some View {
        let nextReached = (planet.rawValue + 1) <= currentPlanet.rawValue
        let isTransitioning = planet == currentPlanet

        return ZStack {
            Capsule()
                .fill(.white.opacity(0.1))
                .frame(width: 28, height: 3)

            if nextReached {
                Capsule()
                    .fill(SpaceTheme.cosmicCyan)
                    .frame(width: 28, height: 3)
            } else if isTransitioning {
                Capsule()
                    .fill(SpaceTheme.cosmicCyan)
                    .frame(width: 28 * progress, height: 3)
                    .frame(width: 28, alignment: .leading)
            }
        }
        .frame(width: 28)
    }

    private func planetColor(for planet: JourneyPlanet) -> Color {
        SpaceTheme.planetColor(hex: planet.accentColor).opacity(0.35)
    }
}
