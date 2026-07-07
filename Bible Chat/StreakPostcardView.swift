//
//  StreakPostcardView.swift
//  Bible Chat  ·  "Haven" recreation
//
//  Reward flow shown after a Daily Plan is completed:
//  streak celebration → congratulations → collectible postcard reveal.
//  Reads AppState AFTER completeDailyPlan(), so currentStop is the stop just reached.
//

import SwiftUI

struct StreakPostcardView: View {
    @EnvironmentObject private var app: AppState
    var onFinish: () -> Void

    private enum Stage { case streak, congrats, reveal }
    @State private var stage: Stage = StreakPostcardView.initialStage

    private static var initialStage: Stage {
        #if DEBUG
        switch DebugRoute.postcardStage {
        case "congrats": return .congrats
        case "reveal":   return .reveal
        default:         return .streak
        }
        #else
        return .streak
        #endif
    }

    private var reachedStop: JourneyStop { app.currentStop }
    private var upcomingStop: JourneyStop { app.nextStop }
    private var moreStreaks: Int { max(1, upcomingStop.streaksRequired - app.streak) }

    var body: some View {
        ZStack {
            Theme.amber.ignoresSafeArea()
            switch stage {
            case .streak:   streakStage
            case .congrats: congratsStage
            case .reveal:   revealStage
            }
        }
        .animation(.easeInOut(duration: 0.35), value: stage)
    }

    // MARK: Stage 1 — streak

    private var streakStage: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 4) {
                Text("\(app.streak)").font(.haven(90, .bold)).foregroundStyle(Theme.brownDeep)
                Text("day streak").font(.havenHeading).foregroundStyle(Theme.brownDeep)
            }
            WeekdayStrip(todayIndex: app.currentWeekdayIndex, completed: app.completedWeekdays)
                .padding(.horizontal, 30)
            HStack(spacing: 8) {
                Text("You've reached a new stop!").font(.haven(17, .medium))
                Text("\(reachedStop.name)").font(.haven(17, .semibold))
                Text("🔥")
            }
            .foregroundStyle(Color(hex: "#FBEED2"))
            .padding(.horizontal, 18).padding(.vertical, 12)
            .background(Theme.brown, in: Capsule())

            Text("Tip: Come back tomorrow to keep your streak going. Daily prayer will strengthen your bond with faith.")
                .font(.havenCaption).foregroundStyle(Theme.brownDeep.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            HavenWhitePill(title: "Continue") { stage = .congrats }
                .padding(.horizontal, Theme.Space.screen).padding(.bottom, 24)
        }
    }

    // MARK: Stage 2 — congratulations (locked postcard)

    private var congratsStage: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 40)
            Text("Congratulations!").font(.havenTitle).foregroundStyle(Theme.brownDeep)
            Text("You've reached the \(reachedStop.name) and earned a new postcard.")
                .font(.havenBody).foregroundStyle(Theme.brownDeep)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 40)

            Button { stage = .reveal } label: {
                ZStack {
                    ArtworkView(art: reachedStop.artwork).blur(radius: 22)
                    Color.black.opacity(0.35)
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill").font(.system(size: 34)).foregroundStyle(.white)
                        Text("Tap To Unveil").font(.haven(20, .medium)).foregroundStyle(.white)
                    }
                }
                .frame(height: 360)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                .overlay(RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(.white.opacity(0.6), lineWidth: 6))
                .padding(.horizontal, 40)
            }
            .buttonStyle(.plain)

            Spacer()
            journeyBanner
            HavenWhitePill(title: "Continue") { stage = .reveal }
                .padding(.horizontal, Theme.Space.screen).padding(.bottom, 24)
        }
    }

    // MARK: Stage 3 — postcard reveal

    private var revealStage: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 30)
            Text("Congratulations!").font(.havenTitle).foregroundStyle(Theme.brownDeep)
            Text("You've reached the \(reachedStop.name) and earned a new postcard.")
                .font(.havenCaption).foregroundStyle(Theme.brownDeep)
                .multilineTextAlignment(.center).padding(.horizontal, 44)

            postcard.padding(.horizontal, 34)

            Spacer()
            journeyBanner
            HavenWhitePill(title: "Continue") { onFinish() }
                .padding(.horizontal, Theme.Space.screen).padding(.bottom, 24)
        }
    }

    private var postcard: some View {
        ZStack {
            ArtworkView(art: reachedStop.artwork)
            LinearGradient(colors: [.black.opacity(0.15), .black.opacity(0.55)],
                           startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Greetings from,").font(.haven(18)).italic().foregroundStyle(.white)
                    Text(reachedStop.name).font(.haven(34, .bold)).foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                HStack(alignment: .top, spacing: 10) {
                    Rectangle().fill(.white).frame(width: 3)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(reachedStop.verse).font(.haven(16)).italic().foregroundStyle(.white)
                        Text(reachedStop.reference).font(.haven(15, .medium)).foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
            .padding(20)
        }
        .aspectRatio(0.7, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: 8))
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
    }

    private var journeyBanner: some View {
        VStack(spacing: 0) {
            Text("Unlock your next stop by completing \(moreStreaks) more streak\(moreStreaks == 1 ? "" : "s")!")
                .font(.haven(15, .medium)).foregroundStyle(Color(hex: "#FBEED2"))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity).padding(.vertical, 10).padding(.horizontal, 12)
                .background(Theme.brown)
            HStack(spacing: 8) {
                Label(reachedStop.name, systemImage: "location.fill")
                    .font(.haven(16, .medium)).foregroundStyle(Theme.ink)
                    .lineLimit(1).layoutPriority(1)
                Rectangle().fill(Theme.hairline).frame(maxWidth: .infinity).frame(height: 1)
                Label(upcomingStop.name, systemImage: "mappin")
                    .font(.haven(16, .medium)).foregroundStyle(Theme.ink)
                    .lineLimit(1).layoutPriority(1)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, Theme.Space.screen)
    }
}

#Preview {
    StreakPostcardView(onFinish: {}).environmentObject(AppState())
}
