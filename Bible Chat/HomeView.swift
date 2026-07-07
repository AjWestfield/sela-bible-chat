//
//  HomeView.swift
//  Bible Chat  ·  "Haven" recreation
//
//  The Home tab: daily verse, today's journey, chat topics, screen-time,
//  and recent conversations. Also the entry point for the Daily Plan flow
//  and the Chat experience.
//

import SwiftUI

// MARK: - Chat seed (how a ChatView is opened)

enum ChatSeed {
    case topic(ChatTopic)
    case dailyVerse(Verse)
    case existing(Conversation)
}

// MARK: - Home

struct HomeView: View {
    @EnvironmentObject private var app: AppState

    @State private var chatSeed: ChatSeed? = nil
    @State private var showScreenTimeAlert = false

    private var todayLabel: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM d"
        return f.string(from: Date())
    }

    private var reviewMode: Bool {
        app.completedWeekdays.contains(app.currentWeekdayIndex)
    }

    private var daysUntilStop: Int {
        max(0, app.nextStop.streaksRequired - app.streak)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    header
                    dailyVerseCard
                    journeySection
                    chatSection
                    screenTimeSection
                    if !app.conversations.isEmpty { recentConversations }
                }
                .padding(.horizontal, Theme.Space.screen)
                .padding(.top, 6)
                .padding(.bottom, 96)
            }
            .background(Theme.paper.ignoresSafeArea())
            // Hide the (empty) navigation bar. Without this, its transparent bar
            // sits over the top of the scroll content and intercepts taps meant
            // for the header's + button, so the button looked dead.
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(item: chatSeedItem) { item in
                ChatView(seed: item.seed).environmentObject(app)
            }
            #if DEBUG
            .onAppear {
                if ProcessInfo.processInfo.environment["HAVEN_TAP_PLUS"] == "1" {
                    app.presentJourney()
                }
            }
            #endif
        }
    }

    // Wrap seed so fullScreenCover(item:) can identify it.
    private var chatSeedItem: Binding<ChatSeedItem?> {
        Binding(
            get: { chatSeed.map(ChatSeedItem.init) },
            set: { chatSeed = $0?.seed }
        )
    }

    // MARK: Header

    private var header: some View {
        HStack {
            HStack(spacing: 10) {
                BrandMark(size: 34)
                VStack(alignment: .leading, spacing: 0) {
                    Text(Brand.appName).font(.havenTitle).foregroundStyle(Theme.ink)
                    Text("Scripture for today")
                        .font(.havenUI(12, .medium))
                        .foregroundStyle(Theme.sage)
                        .textCase(.uppercase)
                }
            }
            Spacer()
            plusButton
        }
    }

    /// Opens the "My Journey" settings sheet (profile, preferences, subscription…).
    private var plusButton: some View {
        Button {
            app.presentJourney()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Theme.inkSoft)
                .frame(width: 52, height: 52)
                .background(Theme.cardSoft, in: Circle())
                .overlay(Circle().stroke(Theme.hairline, lineWidth: 1))
                .shadow(color: .black.opacity(0.05), radius: 7, y: 3)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("My Journey")
        .accessibilityIdentifier("home-plus-button")
    }

    // MARK: Daily verse card

    private var dailyVerseCard: some View {
        ZStack {
            ArtworkView(art: .village)
            LinearGradient(
                colors: [.black.opacity(0.55), .black.opacity(0.30), .black.opacity(0.55)],
                startPoint: .top, endPoint: .bottom)

            VStack(spacing: 12) {
                Text("Daily Verse • \(todayLabel)")
                    .font(.havenCaption)
                    .foregroundStyle(.white.opacity(0.85))

                Text("“\(BibleData.dailyVerse.text)”")
                    .font(.haven(23, .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text(BibleData.dailyVerse.reference)
                    .font(.haven(17))
                    .foregroundStyle(.white.opacity(0.85))

                HStack(spacing: 12) {
                    Button {
                        chatSeed = .dailyVerse(BibleData.dailyVerse)
                    } label: {
                        HStack(spacing: 8) {
                            Text("Interpret").font(.haven(19, .medium))
                            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.35), lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    ShareLink(item: "“\(BibleData.dailyVerse.text)” — \(BibleData.dailyVerse.reference)") {
                        HStack(spacing: 8) {
                            Text("Share").font(.haven(19, .medium))
                            Image(systemName: "square.and.arrow.up").font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.35), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 22)
        }
        .frame(height: 232)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        .shadow(color: .black.opacity(0.10), radius: 12, y: 5)
    }

    // MARK: Journey

    private var journeySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Text("Today's journey").font(.havenHeading).foregroundStyle(Theme.ink)
                Spacer()
                StreakPill(count: app.streak)
            }
            Text("\(daysUntilStop) day\(daysUntilStop == 1 ? "" : "s") until \(app.nextStop.name)")
                .font(.havenBody)
                .foregroundStyle(Theme.inkSoft)
                .offset(y: -6)

            WeekdayStrip(todayIndex: app.currentWeekdayIndex, completed: app.completedWeekdays)
                .padding(.top, 2)

            HavenWhitePill(title: reviewMode ? "Review" : "Begin") {
                app.presentDailyPlan()
            }
            .padding(.top, 6)
        }
    }

    // MARK: Chat topics

    private var chatSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Chat with \(Brand.companionName)").font(.havenHeading).foregroundStyle(Theme.ink)
                Spacer()
                HStack(spacing: 6) {
                    ForEach(0..<BibleData.chatTopics.count, id: \.self) { i in
                        Circle()
                            .fill(i == 0 ? Theme.brown : Theme.inkFaint.opacity(0.45))
                            .frame(width: 7, height: 7)
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(BibleData.chatTopics) { topic in
                        topicCard(topic)
                    }
                }
                .padding(.trailing, 4)
            }
        }
    }

    private func topicCard(_ topic: ChatTopic) -> some View {
        Button {
            chatSeed = .topic(topic)
        } label: {
            ZStack(alignment: .bottomLeading) {
                ArtworkView(art: topic.artwork)
                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center, endPoint: .bottom)
                Text(topic.title)
                    .font(.haven(20, .semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .padding(14)
            }
            .frame(width: 170, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.tile))
        }
        .buttonStyle(.plain)
    }

    // MARK: Screen time

    private var screenTimeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Manage screen time").font(.havenHeading).foregroundStyle(Theme.ink)
            Button {
                showScreenTimeAlert = true
            } label: {
                ZStack(alignment: .leading) {
                    ArtworkView(art: .lockApps)
                    LinearGradient(colors: [.black.opacity(0.30), .black.opacity(0.15)],
                                   startPoint: .leading, endPoint: .trailing)
                    HStack(spacing: 14) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Lock apps till you pray")
                            .font(.haven(21, .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 22)
                }
                .frame(height: 90)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.tile))
            }
            .buttonStyle(.plain)
            .alert("Screen Time", isPresented: $showScreenTimeAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Lock distracting apps until you complete today's prayer. Coming soon.")
            }
        }
    }

    // MARK: Recent conversations

    private var recentConversations: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent conversations").font(.havenHeading).foregroundStyle(Theme.ink)
            VStack(spacing: 0) {
                ForEach(app.conversations) { convo in
                    Button {
                        chatSeed = .existing(convo)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(convo.title)
                                    .font(.haven(19, .medium))
                                    .foregroundStyle(Theme.ink)
                                    .lineLimit(1)
                                Text(convo.subtitle)
                                    .font(.havenCaption)
                                    .foregroundStyle(Theme.inkFaint)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.inkFaint)
                        }
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                    if convo.id != app.conversations.last?.id {
                        Divider().overlay(Theme.hairline)
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        }
    }
}

private struct ChatSeedItem: Identifiable {
    let id = UUID()
    let seed: ChatSeed
}

#Preview {
    HomeView().environmentObject(AppState())
}
