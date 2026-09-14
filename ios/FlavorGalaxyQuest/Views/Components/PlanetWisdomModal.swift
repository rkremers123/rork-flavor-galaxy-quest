import SwiftUI
import UIKit

struct PlanetWisdom {
    let kidMessage: String
    let parentNote: String
    /// Ladder / chrome asset preferred when planet art is missing (no emoji).
    let markAssetName: String?
    let systemImage: String

    static func wisdom(for planet: JourneyPlanet) -> PlanetWisdom {
        switch planet {
        case .baseCamp:
            return PlanetWisdom(
                kidMessage: "You have a safe place to start. That's powerful! Your journey begins here.",
                parentNote: "Sensory regulation starts with safety. A calm, low-pressure environment helps kids explore without anxiety.",
                markAssetName: "planet_base_camp",
                systemImage: "house.fill"
            )
        case .sensoryGrove:
            return PlanetWisdom(
                kidMessage: "Looking is your superpower! You're learning with your eyes. That's exactly right.",
                parentNote: "The LOOK phase builds visual familiarity with food. No pressure to touch or taste — seeing is progress.",
                markAssetName: "step_look",
                systemImage: "eye.fill"
            )
        case .flavorMountains:
            return PlanetWisdom(
                kidMessage: "You touched it! That's brave! Your hands are explorers — and they just learned something new.",
                parentNote: "The TOUCH phase develops tactile tolerance. Touching food is a major milestone. You're rewiring sensory comfort.",
                markAssetName: "step_touch",
                systemImage: "hand.raised.fill"
            )
        case .crystalCaves:
            return PlanetWisdom(
                kidMessage: "Your nose knows! Smelling helps your tongue get ready for the next adventure.",
                parentNote: "The SMELL phase primes the olfactory system. Smell and taste are deeply connected — your child is building taste tolerance.",
                markAssetName: "step_smell",
                systemImage: "nose.fill"
            )
        case .tasteOcean:
            return PlanetWisdom(
                kidMessage: "You tasted it! That's huge courage. Your tongue just did something amazing.",
                parentNote: "The TASTE/LICK phase is the first real oral input. This is the biggest milestone — celebrate this hard.",
                markAssetName: "step_lick",
                systemImage: "mouth.fill"
            )
        case .stardustFields:
            return PlanetWisdom(
                kidMessage: "You swallowed it! You did it. You're a sensory master now — and you should feel so proud.",
                parentNote: "The SWALLOW phase is full acceptance. The food moved from tasting to consuming. This is neurological integration.",
                markAssetName: SensoryStep.ateImageName,
                systemImage: "fork.knife"
            )
        case .nebulaRidge:
            return PlanetWisdom(
                kidMessage: "Look at all the flavors you've tried! You're not picky — you're an adventurer. And adventurers are brave.",
                parentNote: "Multiple foods means reduced selectivity. Variety shows expanded sensory preferences. Your child's world just got bigger.",
                markAssetName: "cosmic_connector_star",
                systemImage: "sparkles"
            )
        case .harvestFestival:
            return PlanetWisdom(
                kidMessage: "You did it all. You're a Galaxy Master now. Print your certificate and show the world what you conquered!",
                parentNote: "Finishing the dinner-quest ladder is a real shift. Looking counted the whole way. Celebrate this with them — and keep the pressure low.",
                markAssetName: "badge_saturn",
                systemImage: "rosette"
            )
        }
    }
}

struct PlanetWisdomModal: View {
    let planet: JourneyPlanet
    let onContinue: () -> Void

    @State private var appeared = false
    @State private var showParentNote = false

    private var wisdom: PlanetWisdom { PlanetWisdom.wisdom(for: planet) }
    private var planetColor: Color { SpaceTheme.planetColor(hex: planet.accentColor) }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    planetColor.opacity(0.25),
                    SpaceTheme.deepNavy.opacity(0.97),
                    SpaceTheme.deepNavy
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                planetHero
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1.0 : 0.6)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: appeared)

                Spacer().frame(height: 32)

                kidMessageSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 30)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4), value: appeared)

                Spacer().frame(height: 24)

                parentNoteSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.6), value: appeared)

                Spacer()

                continueButton
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.8), value: appeared)

                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    private var planetHero: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [planetColor.opacity(0.35), planetColor.opacity(0.05), .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 180, height: 180)

            Group {
                if UIImage(named: planet.imageName) != nil {
                    Image(planet.imageName)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                } else if let mark = wisdom.markAssetName, UIImage(named: mark) != nil {
                    Image(mark)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                } else {
                    Image(systemName: wisdom.systemImage)
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }

            ForEach(0..<6, id: \.self) { i in
                let angle = Double(i) * 60
                Group {
                    if UIImage(named: "star_dust_particle") != nil {
                        Image("star_dust_particle")
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .opacity(0.7)
                    } else {
                        Image(systemName: "sparkle")
                            .font(.system(size: 10))
                            .foregroundStyle(planetColor.opacity(0.5))
                    }
                }
                .offset(y: -80)
                .rotationEffect(.degrees(angle))
                .scaleEffect(appeared ? 1.0 : 0.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.3 + Double(i) * 0.06), value: appeared)
            }
        }
    }

    private var kidMessageSection: some View {
        VStack(spacing: 12) {
            Text(planet.name)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text("Complete!")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(planetColor)

            Text(wisdom.kidMessage)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.95))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var parentNoteSection: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    showParentNote.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(planetColor.opacity(0.7))

                    Text("Why This Matters")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))

                    Spacer()

                    Image(systemName: showParentNote ? "chevron.up" : "chevron.down")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            if showParentNote {
                Text(wisdom.parentNote)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var continueButton: some View {
        Button {
            onContinue()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
                Text("Continue to Journey Map")
                    .font(.system(.headline, design: .rounded, weight: .bold))
            }
            .foregroundStyle(SpaceTheme.deepNavy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: [SpaceTheme.cosmicCyan, SpaceTheme.cosmicCyan.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            )
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: appeared)
    }
}
