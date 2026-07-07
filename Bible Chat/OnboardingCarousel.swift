import SwiftUI

/// Step 1 — swipeable marketing carousel with an Apple sign-in footer.
struct OnboardingCarousel: View {
    let onContinue: () -> Void
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.openURL) private var openURL
    @State private var page = OnboardingCarousel.initialPage

    private let slides = [
        CarouselSlide(title: "Welcome to Sela", subtitle: "Daily Scripture, prayer, and faithful guidance."),
        CarouselSlide(title: "Build a Scripture rhythm", subtitle: "Small daily steps that are easy to return to."),
        CarouselSlide(title: "Guided Bible reading", subtitle: "Helpful context for each passage."),
        CarouselSlide(title: "Lock Screen Scripture", subtitle: "Keep one verse visible throughout the day."),
        CarouselSlide(title: "Bible answers", subtitle: "Gentle guidance when you need direction.")
    ]

    private static var initialPage: Int {
        #if DEBUG
        if let raw = DebugRoute.carouselPage, let page = Int(raw) {
            return min(max(page, 0), 4)
        }
        #endif
        return 0
    }

    var body: some View {
        ZStack {
            ArtworkView(art: .meadow)
                .ignoresSafeArea()
            LinearGradient(
                colors: [
                    Color.black.opacity(0.42),
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.34)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(slides.indices, id: \.self) { i in
                        CarouselPage(index: i, slide: slides[i])
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: page) { _, _ in
                    Haptics.selection(enabled: settings.haptics)
                }

                footer
            }
        }
    }

    /// Terms/Privacy caption with tappable underlined links.
    private var termsCaption: some View {
        VStack(spacing: 2) {
            Text("By clicking \"Continue\" you agree to our")
            HStack(spacing: 4) {
                Button {
                    openURL(URL(string: "https://example.com/terms")!)
                } label: {
                    Text("Terms of Service").underline()
                }
                .buttonStyle(.plain)

                Text("and")

                Button {
                    openURL(URL(string: "https://example.com/privacy")!)
                } label: {
                    Text("Privacy Policy").underline()
                }
                .buttonStyle(.plain)
            }
        }
        .font(.haven(14))
        .foregroundStyle(.white.opacity(0.82))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }

    private var footer: some View {
        VStack(spacing: 18) {
            // Paging dots
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { i in
                    Circle()
                        .fill(.white.opacity(i == page ? 0.95 : 0.4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 4)

            // Continue with Apple
            Button(action: onContinue) {
                HStack(spacing: 12) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 22, weight: .medium))
                    Text("Continue with Apple")
                        .font(.havenUI(21, .semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    Capsule().fill(.white)
                )
            }
            .padding(.horizontal, Theme.Space.screen)

            // Continue without signing in
            Button(action: onContinue) {
                Text("Continue without signing in")
                    .font(.haven(19, .semibold))
                    .foregroundStyle(.white)
                    .underline()
            }

            // Terms caption
            termsCaption
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Individual page

private struct CarouselSlide {
    let title: String
    let subtitle: String
}

private struct CarouselPage: View {
    let index: Int
    let slide: CarouselSlide

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(slide.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.88)
                    .lineSpacing(2)
                    .allowsTightening(true)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: .black.opacity(0.35), radius: 10, y: 4)

                Text(slide.subtitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.86))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: .black.opacity(0.28), radius: 8, y: 3)
            }
                .frame(maxWidth: 340)
                .padding(.horizontal, 28)
                .padding(.top, 30)

            Spacer(minLength: index == 3 ? 16 : 24)

            Group {
                switch index {
                case 1: reviewsContent
                default: PhoneMockup(index: index)
                }
            }

            Spacer(minLength: 12)
        }
    }

    // Page 2 — reviews
    private var reviewsContent: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Theme.gold)
                Text("Designed for daily spiritual steadiness")
                    .font(.haven(18, .semibold))
                    .foregroundStyle(.white)
            }
            .shadow(color: .black.opacity(0.3), radius: 6, y: 2)

            ReviewCard(
                quote: "Sela has changed my mornings. Scripture feels closer, quieter, and easier to return to.",
                author: "Sarah M."
            )
            ReviewCard(
                quote: "The daily verses and prayers speak right to what I'm going through. Truly a blessing.",
                author: "David R."
            )
        }
        .padding(.horizontal, 26)
    }
}

private struct ReviewCard: View {
    let quote: String
    let author: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.gold)
                }
            }
            Text(quote)
                .font(.haven(17))
                .foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(author)
                .font(.haven(14, .semibold))
                .foregroundStyle(Theme.inkSoft)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .fill(Theme.paper)
        )
        .shadow(color: .black.opacity(0.18), radius: 14, y: 8)
    }
}

// MARK: - Phone mockup (elegant device frame)

private struct PhoneMockup: View {
    let index: Int

    var body: some View {
        if index == 3 {
            LockScreenPreview()
        } else {
            framedPhone
        }
    }

    private var framedPhone: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 46, style: .continuous)
                .fill(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 26, y: 16)

            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(Theme.paper)
                .padding(6)
                .overlay(alignment: .top) {
                    // Notch / dynamic island
                    Capsule()
                        .fill(Color.black)
                        .frame(width: 96, height: 26)
                        .padding(.top, 16)
                }
                .overlay {
                    screenContent
                        .padding(6)
                        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                }
        }
        .frame(width: index == 4 ? 230 : 240, height: index == 4 ? 430 : 460)
    }

    @ViewBuilder private var screenContent: some View {
        switch index {
        case 2:
            // Read the bible with guidance
            VStack(spacing: 14) {
                Spacer().frame(height: 44)
                ArtworkView(art: .river)
                    .frame(height: 130)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(alignment: .bottomLeading) {
                        Text("Genesis 1")
                            .font(.haven(15, .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                    }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<5, id: \.self) { r in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Theme.ink.opacity(0.12))
                            .frame(height: 9)
                            .frame(maxWidth: r == 4 ? 120 : .infinity, alignment: .leading)
                    }
                }
                Spacer()
            }
            .padding(14)
        case 4:
            // Personalized advice — chat
            VStack(spacing: 10) {
                Spacer().frame(height: 44)
                chatBubble("How do I find peace when I'm anxious?", mine: true)
                chatBubble("\"Do not be anxious about anything...\" Philippians 4:6 reminds us to bring our worries to God in prayer.", mine: false)
                Spacer()
                HStack {
                    Text("Ask me anything...")
                        .font(.haven(13))
                        .foregroundStyle(Theme.inkFaint)
                    Spacer()
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.brown)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(Capsule().fill(Theme.cardSoft))
            }
            .padding(14)
        default:
            // Welcome — Sela home preview
            VStack(spacing: 12) {
                Spacer().frame(height: 44)
                Text(Brand.appName)
                    .font(.haven(20, .bold))
                    .foregroundStyle(Theme.brown)
                ArtworkView(art: .darkCreation)
                    .frame(height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay {
                        VStack(spacing: 4) {
                            Text("\"Cast all your anxiety on him\"")
                                .font(.haven(13))
                            Text("1 Peter 5:7")
                                .font(.haven(11))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                    }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    miniTile(.goldenField, "Life challenges")
                    miniTile(.village, "Questions of faith")
                    miniTile(.cross, "Community")
                    miniTile(.service, "Worship")
                }
                Spacer()
            }
            .padding(14)
        }
    }

    private func chatBubble(_ text: String, mine: Bool) -> some View {
        HStack {
            if mine { Spacer(minLength: 30) }
            Text(text)
                .font(.haven(13))
                .foregroundStyle(mine ? .white : Theme.ink)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(mine ? Theme.brown : Theme.cardSoft)
                )
            if !mine { Spacer(minLength: 30) }
        }
    }

    private func miniTile(_ art: HavenArtwork, _ label: String) -> some View {
        VStack(spacing: 4) {
            ArtworkView(art: art)
                .frame(height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            Text(label)
                .font(.haven(11, .medium))
                .foregroundStyle(Theme.ink)
        }
    }
}

private struct LockScreenPreview: View {
    var body: some View {
        ZStack {
            ArtworkView(art: .river)

            LinearGradient(
                colors: [
                    Color.black.opacity(0.30),
                    Color.black.opacity(0.06),
                    Color.black.opacity(0.38)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                Capsule()
                    .fill(.black.opacity(0.88))
                    .frame(width: 86, height: 24)
                    .padding(.top, 18)

                Spacer().frame(height: 24)

                Text("Wednesday, March 12")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.92))

                Text("10:41")
                    .font(.system(size: 64, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 2)

                Spacer()

                VStack(alignment: .leading, spacing: 9) {
                    Text("Daily Verse")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.inkSoft)

                    Text("\"Cast all your anxiety on him because he cares for you.\"")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.ink)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("1 Peter 5:7")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.inkSoft)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Theme.paper.opacity(0.94))
                )
                .padding(.horizontal, 18)

                Spacer().frame(height: 30)
            }
        }
        .frame(width: 252, height: 430)
        .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .strokeBorder(.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.30), radius: 24, y: 16)
    }
}

#Preview {
    OnboardingCarousel(onContinue: {})
        .environmentObject(AppState())
}
