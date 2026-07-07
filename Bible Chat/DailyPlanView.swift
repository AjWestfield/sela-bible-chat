//
//  DailyPlanView.swift
//  Bible Chat  ·  "Haven" recreation
//
//  The Daily Plan: a guided, conversational reflection —
//  mood check-in → personalized devotional → guided prayer → streak reward.
//

import SwiftUI

struct DailyPlanView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    private enum Stage { case mood, devotional, prayer }

    struct Beat: Identifiable {
        let id = UUID()
        enum Kind { case haven(String), user(String), devotionalCard, prayer(String) }
        let kind: Kind
    }

    @State private var transcript: [Beat] = []
    @State private var stage: Stage = .mood
    @State private var moodValue: Double = 2
    @State private var showDevotional = false
    @State private var showStreak = false
    @State private var reciteProgress: CGFloat = 0

    private var moodLabel: String { Mood(rawValue: Int(moodValue.rounded()))?.label ?? "neutral" }
    private var progress: CGFloat {
        switch stage { case .mood: 0.34; case .devotional: 0.67; case .prayer: 1.0 }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        ForEach(transcript) { beat in beatView(beat).id(beat.id) }
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding(.horizontal, Theme.Space.screen)
                    .padding(.vertical, 20)
                }
                .onChange(of: transcript.count) { _, _ in
                    withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                }
            }
            stageControl
        }
        .background(Theme.paper.ignoresSafeArea())
        .onAppear(perform: seed)
        .fullScreenCover(isPresented: $showDevotional) { devotionalReader }
        .fullScreenCover(isPresented: $showStreak) {
            StreakPostcardView {
                showStreak = false
                dismiss()
            }
            .environmentObject(app)
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(spacing: 10) {
            ZStack {
                Text("Daily Plan").font(.havenSubheading).foregroundStyle(Theme.ink)
                HStack {
                    CircleIconButton(systemName: "chevron.left") { dismiss() }
                    Spacer()
                }
            }
            .padding(.horizontal, Theme.Space.screen)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.hairline)
                    Capsule().fill(Theme.brown).frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 3)
            .animation(.easeInOut, value: progress)
        }
        .padding(.top, 8)
    }

    // MARK: Transcript beats

    @ViewBuilder
    private func beatView(_ beat: Beat) -> some View {
        switch beat.kind {
        case .haven(let text):
            VStack(alignment: .leading, spacing: 6) {
                Text("\(Brand.companionName):").font(.haven(19)).foregroundStyle(Theme.inkFaint)
                Text(text).font(.haven(21)).foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .user(let text):
            HStack { Spacer(minLength: 40); HavenChip(text: text) }
        case .devotionalCard:
            devotionalCard
        case .prayer(let text):
            Text(text).font(.haven(20)).foregroundStyle(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 4)
        }
    }

    private var devotionalCard: some View {
        Button { showDevotional = true } label: {
            ZStack {
                ArtworkView(art: BibleData.dailyBread.artwork)
                LinearGradient(colors: [.black.opacity(0.25), .black.opacity(0.6)],
                               startPoint: .top, endPoint: .bottom)
                VStack(spacing: 4) {
                    Text("Daily Devotional").font(.haven(22, .semibold)).foregroundStyle(.white)
                    Text("\(BibleData.dailyBread.minutes) Minutes").font(.havenCaption).foregroundStyle(.white.opacity(0.85))
                    HStack(spacing: 6) {
                        Text("Tap to open").font(.havenCaption)
                        Image(systemName: "book").font(.system(size: 13))
                    }.foregroundStyle(.white.opacity(0.85)).padding(.top, 4)
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        }
        .buttonStyle(.plain)
        .disabled(stage != .devotional)
    }

    // MARK: Bottom stage control

    @ViewBuilder
    private var stageControl: some View {
        switch stage {
        case .mood:
            VStack(spacing: 14) {
                Text("I'm feeling \(moodLabel)").font(.haven(22, .medium)).foregroundStyle(Theme.ink)
                ZStack {
                    Capsule().fill(LinearGradient(colors: [Theme.gold.opacity(0.4), Theme.brown.opacity(0.5)],
                                                  startPoint: .leading, endPoint: .trailing))
                        .frame(height: 8)
                    Slider(value: $moodValue, in: 0...4, step: 1).tint(.clear)
                }
                Text("slide to select").font(.havenCaption).foregroundStyle(Theme.inkFaint)
                HavenWhitePill(title: "Continue") { advanceFromMood() }
            }
            .padding(.horizontal, Theme.Space.screen).padding(.bottom, 18)
        case .prayer:
            reciteButton.padding(.bottom, 24)
        case .devotional:
            EmptyView()
        }
    }

    private var reciteButton: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().stroke(Theme.goldPale, lineWidth: 5).frame(width: 78, height: 78)
                Circle().trim(from: 0, to: reciteProgress)
                    .stroke(Theme.gold, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90)).frame(width: 78, height: 78)
                Circle().fill(LinearGradient(colors: [Theme.goldSoft, Theme.gold],
                                             startPoint: .top, endPoint: .bottom))
                    .frame(width: 62, height: 62)
                    .shadow(color: Theme.gold.opacity(0.6), radius: 10)
                Image(systemName: "hands.and.sparkles.fill").font(.system(size: 24)).foregroundStyle(.white)
            }
            .onLongPressGesture(minimumDuration: 2.2, maximumDistance: 60) {
                completeRecitation()
            } onPressingChanged: { pressing in
                withAnimation(.linear(duration: pressing ? 2.2 : 0.25)) {
                    reciteProgress = pressing ? 1 : 0
                }
            }
            Text("Tap and hold").font(.havenCaption).foregroundStyle(Theme.inkSoft)
        }
    }

    // MARK: Devotional reader sheet

    private var devotionalReader: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Daily Devotional").font(.havenSubheading).foregroundStyle(Theme.ink)
                HStack {
                    CircleIconButton(systemName: "chevron.left") { showDevotional = false }
                    Spacer()
                    ShareLink(item: BibleData.dailyBread.body) {
                        Image(systemName: "square.and.arrow.up").font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Theme.inkSoft)
                    }
                }
            }
            .padding(.horizontal, Theme.Space.screen).padding(.top, 14).padding(.bottom, 8)

            ScrollView {
                Text(BibleData.dailyBread.body)
                    .font(.haven(20)).foregroundStyle(Theme.ink)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Theme.Space.screen).padding(.vertical, 12)
            }

            HavenPrimaryButton(title: "I'm ready to continue to prayer") { advanceFromDevotional() }
                .padding(.horizontal, Theme.Space.screen).padding(.bottom, 18)
        }
        .background(Theme.paper.ignoresSafeArea())
    }

    // MARK: Flow

    private func seed() {
        guard transcript.isEmpty else { return }
        transcript = [.init(kind: .haven(
            "Welcome to your Daily Plan.\n\nOnce a day, take a moment to pause, reflect, and reconnect. Every day you show up, your faith grows a little stronger.\n\nHow is your relationship with God today?"))]
    }

    private func advanceFromMood() {
        transcript.append(.init(kind: .user("I'm feeling \(moodLabel)")))
        transcript.append(.init(kind: .haven(
            "I've prepared your personalized devotional, \(app.displayName). As we reflect today, let's consider today's topic on \(BibleData.dailyBread.topic).")))
        transcript.append(.init(kind: .devotionalCard))
        stage = .devotional
    }

    private func advanceFromDevotional() {
        guard stage == .devotional else { showDevotional = false; return }
        showDevotional = false
        transcript.append(.init(kind: .user("I'm ready to continue to prayer")))
        transcript.append(.init(kind: .haven("Let's begin our prayer.")))
        transcript.append(.init(kind: .prayer(BibleData.dailyBread.prayer)))
        stage = .prayer
    }

    private func completeRecitation() {
        transcript.append(.init(kind: .haven("Amen…")))
        app.completeDailyPlan()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showStreak = true }
    }
}

#Preview {
    DailyPlanView().environmentObject(AppState())
}
