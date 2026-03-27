import SwiftUI

struct ParentOnboardingView: View {
    let onCreateProfile: () -> Void
    let onSkip: () -> Void

    @State private var currentSlide: Int = 0
    @State private var appeared: Bool = false

    private let totalSlides = 4

    private let accentPurple = Color(red: 0.4, green: 0.49, blue: 0.92)
    private let deepPurple = Color(red: 0.46, green: 0.29, blue: 0.64)

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                TabView(selection: $currentSlide) {
                    slide1.tag(0)
                    slide2.tag(1)
                    slide3.tag(2)
                    slide4.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(duration: 0.4), value: currentSlide)

                bottomBar
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) { appeared = true }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.97, blue: 1.0),
                Color(red: 0.94, green: 0.93, blue: 1.0),
                Color(red: 0.96, green: 0.95, blue: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var bottomBar: some View {
        VStack(spacing: 16) {
            dotIndicator

            if currentSlide == totalSlides - 1 {
                VStack(spacing: 12) {
                    Button(action: onCreateProfile) {
                        Text("Create Child Profile")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [accentPurple, deepPurple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(.rect(cornerRadius: 14))
                    }

                    Button(action: onSkip) {
                        Text("Skip for Now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(accentPurple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray6))
                            .clipShape(.rect(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 24)
            } else {
                Button {
                    withAnimation(.spring(duration: 0.35)) { currentSlide += 1 }
                } label: {
                    HStack(spacing: 6) {
                        Text("Next")
                            .font(.system(size: 17, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(accentPurple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(accentPurple.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 14))
                }
                .padding(.horizontal, 24)
            }
        }
    }

    private var dotIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSlides, id: \.self) { index in
                Capsule()
                    .fill(index == currentSlide ? accentPurple : Color(.systemGray4))
                    .frame(width: index == currentSlide ? 24 : 8, height: 8)
                    .animation(.spring(duration: 0.3), value: currentSlide)
            }
        }
    }

    // MARK: - Slide 1: Problem Validation

    private var slide1: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                slide1Visual
                    .padding(.bottom, 32)

                VStack(spacing: 16) {
                    Text("Your Child Isn't Picky.\nThey're Sensory-Sensitive.")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(accentPurple)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)

                    Text("It's neurological. It's real.\nAnd there's a science-backed way to help.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(deepPurple)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 15)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

                VStack(alignment: .leading, spacing: 16) {
                    bodyText("Selective eating isn't a behavior problem or stubbornness\u{2014}it's a sensory processing difference. Your child's nervous system is working harder to process textures, tastes, and temperatures.")

                    bodyText("The good news? Sensory sensitivity is rewirable. With patience and the right approach, kids can expand their food world.")

                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(red: 1.0, green: 0.4, blue: 0.5))
                        Text("You're not alone. About 1 in 3 children experience selective eating. And you're here. That's the first step.")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(red: 0.25, green: 0.25, blue: 0.3))
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .background(Color(red: 1.0, green: 0.4, blue: 0.5).opacity(0.06))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
    }

    private var slide1Visual: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accentPurple.opacity(0.15), accentPurple.opacity(0.03)],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)

            VStack(spacing: 12) {
                ZStack {
                    ForEach(0..<5, id: \.self) { i in
                        let emojis = ["🍎", "🥦", "🧀", "🍗", "🥕"]
                        let angles: [Double] = [-40, -20, 0, 20, 40]
                        let offsets: [CGFloat] = [-50, -25, 0, 25, 50]
                        Text(emojis[i])
                            .font(.system(size: 36))
                            .rotationEffect(.degrees(angles[i]))
                            .offset(x: offsets[i], y: abs(offsets[i]) * 0.3)
                    }
                }
                .padding(.bottom, 8)

                Text("👦")
                    .font(.system(size: 56))
            }
        }
        .frame(height: 200)
    }

    // MARK: - Slide 2: The Science (SOS)

    private var slide2: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text("Gentle Progress,\nNot Forced Eating")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(accentPurple)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                Text("5 Sensory Phases. No Pressure.")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(deepPurple)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 28)

                slide2Phases
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                VStack(alignment: .leading, spacing: 16) {
                    bodyText("We use the Sequential Oral Sensory (SOS) Approach\u{2014}a clinically-validated method used by speech therapists and occupational therapists worldwide.")

                    bodyText("Each phase takes time (3\u{2013}10 days). We don't rush. Your child's nervous system needs time to integrate each new sensation. That's not slow\u{2014}that's smart.")

                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(red: 0.2, green: 0.75, blue: 0.4))
                        Text("The result? Real progress. Real food acceptance. Real confidence.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(red: 0.2, green: 0.75, blue: 0.4))
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .background(Color(red: 0.2, green: 0.75, blue: 0.4).opacity(0.06))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
    }

    private var slide2Phases: some View {
        VStack(spacing: 0) {
            phaseRow(emoji: "👀", label: "LOOK", desc: "Getting used to seeing the food", color: Color(red: 0.3, green: 0.6, blue: 1.0), isFirst: true)
            phaseConnector(color: Color(red: 0.3, green: 0.6, blue: 1.0))
            phaseRow(emoji: "🤲", label: "TOUCH", desc: "Feeling textures with hands", color: Color(red: 0.3, green: 0.8, blue: 0.6))
            phaseConnector(color: Color(red: 0.3, green: 0.8, blue: 0.6))
            phaseRow(emoji: "👃", label: "SMELL", desc: "Exploring aromas", color: Color(red: 0.95, green: 0.75, blue: 0.2))
            phaseConnector(color: Color(red: 0.95, green: 0.75, blue: 0.2))
            phaseRow(emoji: "👅", label: "LICK", desc: "Trying small tastes", color: Color(red: 1.0, green: 0.55, blue: 0.2))
            phaseConnector(color: Color(red: 1.0, green: 0.55, blue: 0.2))
            phaseRow(emoji: "🤤", label: "TASTE", desc: "Eating and enjoying", color: Color(red: 0.9, green: 0.3, blue: 0.35), isLast: true)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
    }

    private func phaseRow(emoji: String, label: String, desc: String, color: Color, isFirst: Bool = false, isLast: Bool = false) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(emoji)
                    .font(.system(size: 22))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(color)
                    .tracking(1)
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.45))
            }

            Spacer()
        }
    }

    private func phaseConnector(color: Color) -> some View {
        HStack {
            Rectangle()
                .fill(color.opacity(0.2))
                .frame(width: 2, height: 12)
                .padding(.leading, 21)
            Spacer()
        }
    }

    // MARK: - Slide 3: Gamification

    private var slide3: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text("They're Not a Problem.\nThey're an Explorer.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(accentPurple)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                Text("A game that looks like an adventure,\nnot like therapy.")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(deepPurple)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 28)

                slide3JourneyPreview
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                VStack(alignment: .leading, spacing: 14) {
                    bodyText("Kids don't get excited about \"eating more foods.\" They get excited about progress they can see and celebrate.")

                    featureBullet(emoji: "🚀", text: "Pick an explorer character and name them")
                    featureBullet(emoji: "🌌", text: "Journey through 8 planets, each a sensory milestone")
                    featureBullet(emoji: "⭐", text: "Earn points, unlock cosmetics, celebrate level-ups")
                    featureBullet(emoji: "🎯", text: "See the entire adventure on the journey map")

                    bodyText("The magic? It feels like a game because it IS a game. But underneath, the SOS protocol is rewiring their sensory system.")

                    HStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(red: 1.0, green: 0.75, blue: 0.0))
                        Text("When they finish, they print a certificate. They see proof. They feel pride.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(red: 0.35, green: 0.3, blue: 0.2))
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .background(Color(red: 1.0, green: 0.75, blue: 0.0).opacity(0.08))
                    .clipShape(.rect(cornerRadius: 12))
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: 40)
            }
        }
    }

    private var slide3JourneyPreview: some View {
        VStack(spacing: 0) {
            let planets: [(String, String, Color, Bool)] = [
                ("🏕️", "Base Camp", Color(red: 0.3, green: 0.65, blue: 1.0), true),
                ("🔭", "Curiosity Cove", Color(red: 0.3, green: 0.8, blue: 0.6), true),
                ("🪨", "Texture Trails", Color(red: 0.6, green: 0.5, blue: 0.9), false),
                ("💨", "Aroma Airship", Color(red: 0.95, green: 0.75, blue: 0.2), false),
            ]

            ForEach(Array(planets.enumerated()), id: \.offset) { index, planet in
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(planet.3 ? planet.2.opacity(0.15) : Color(.systemGray5))
                            .frame(width: 48, height: 48)
                        Text(planet.0)
                            .font(.system(size: 24))
                            .grayscale(planet.3 ? 0 : 0.8)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(planet.1)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(planet.3 ? Color(red: 0.15, green: 0.15, blue: 0.2) : Color(.systemGray3))
                        if planet.3 && index == 0 {
                            Text("Completed!")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color(red: 0.2, green: 0.75, blue: 0.4))
                        } else if planet.3 && index == 1 {
                            Text("In Progress...")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(planet.2)
                        } else {
                            Text("Locked")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color(.systemGray4))
                        }
                    }

                    Spacer()

                    if planet.3 && index == 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color(red: 0.2, green: 0.75, blue: 0.4))
                    } else if !planet.3 {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.systemGray4))
                    }
                }
                .padding(.vertical, 10)

                if index < planets.count - 1 {
                    HStack {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(width: 2, height: 8)
                            .padding(.leading, 23)
                        Spacer()
                    }
                }
            }

            HStack(spacing: 6) {
                Text("+ 4 more planets")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color(.systemGray3))
                Image(systemName: "ellipsis")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(.systemGray4))
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
    }

    // MARK: - Slide 4: Victory & Parent Tools

    private var slide4: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                Text("Print It. Frame It. Share It.")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(accentPurple)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                Text("You'll see exactly where they are\u{2014}\nand celebrate when they finish.")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(deepPurple)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 28)

                slide4CertificatePreview
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                VStack(alignment: .leading, spacing: 16) {
                    Text("This isn't just a game for your child. It's a dashboard for you.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(accentPurple)
                        .padding(.horizontal, 24)

                    featureCard(
                        icon: "chart.bar.fill",
                        iconColor: Color(red: 0.3, green: 0.6, blue: 1.0),
                        title: "Analytics Dashboard",
                        desc: "See sensory patterns emerge in real-time. Understand your child's unique sensory profile and get smart recommendations for what to try next."
                    )

                    featureCard(
                        icon: "lightbulb.fill",
                        iconColor: Color(red: 0.95, green: 0.75, blue: 0.2),
                        title: "Pattern Detection",
                        desc: "When regressions happen (and they will), the app detects them. No shame, just data."
                    )

                    featureCard(
                        icon: "medal.fill",
                        iconColor: Color(red: 1.0, green: 0.55, blue: 0.2),
                        title: "The Certificate",
                        desc: "Frame it. Hang it in your home. Share it with their doctor, therapist, or grandparents. This is proof of real progress."
                    )

                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(deepPurple)
                        Text("And you\u{2014}you get to be part of the journey every step of the way.")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(deepPurple)
                            .lineSpacing(3)
                    }
                    .padding(16)
                    .background(deepPurple.opacity(0.06))
                    .clipShape(.rect(cornerRadius: 12))
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: 40)
            }
        }
    }

    private var slide4CertificatePreview: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.95, blue: 0.8),
                                Color(red: 1.0, green: 0.9, blue: 0.7)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 0.85, green: 0.7, blue: 0.3), Color(red: 1.0, green: 0.85, blue: 0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )

                VStack(spacing: 8) {
                    Text("🌟")
                        .font(.system(size: 32))
                    Text("Galaxy Master Certificate")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 0.45, green: 0.35, blue: 0.15))
                    Text("Awarded to Your Explorer")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color(red: 0.55, green: 0.45, blue: 0.25))
                    HStack(spacing: 4) {
                        ForEach(["🏕️", "🔭", "🪨", "💨", "⛰️", "🌊", "🌴", "💜"], id: \.self) { emoji in
                            Text(emoji)
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 20)
            }
            .frame(height: 180)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
    }

    // MARK: - Reusable Components

    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15))
            .foregroundStyle(Color(red: 0.25, green: 0.25, blue: 0.3))
            .lineSpacing(4)
    }

    private func featureBullet(emoji: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(emoji)
                .font(.system(size: 18))
            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.25))
        }
        .padding(.horizontal, 4)
    }

    private func featureCard(icon: String, iconColor: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.2))
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.45))
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6).opacity(0.7))
        .clipShape(.rect(cornerRadius: 14))
        .padding(.horizontal, 24)
    }
}
