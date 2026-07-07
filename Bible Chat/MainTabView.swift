//
//  MainTabView.swift
//  Bible Chat  ·  "Haven" recreation
//
//  The signed-in shell: Home / Listen / Read with a floating serif tab bar
//  and a docked now-playing mini-player.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var settings: SettingsStore

    enum Tab: CaseIterable { case home, listen, read
        var title: String { self == .home ? "Home" : self == .listen ? "Listen" : "Read" }
        var icon: String {
            switch self { case .home: "house.fill"; case .listen: "headphones"; case .read: "book" }
        }
    }

    /// Every full-screen presentation flows through ONE cover. Multiple
    /// simultaneous `.fullScreenCover` modifiers in a single view tree are
    /// unreliable — SwiftUI silently drops all but one — which is exactly why a
    /// tapped "+" never presented My Journey. A single presenter fixes that.
    enum ActiveSheet: Identifiable, Equatable {
        case journey, dailyPlan, player, debug(String)
        var id: String {
            switch self {
            case .journey:      return "journey"
            case .dailyPlan:    return "dailyPlan"
            case .player:       return "player"
            case .debug(let n): return "debug-\(n)"
            }
        }
    }

    @State private var tab: Tab = MainTabView.initialTab
    @State private var sheet: ActiveSheet? = nil
    #if DEBUG
    @State private var dbgApplied = false
    #endif

    private static var initialTab: Tab {
        #if DEBUG
        switch DebugRoute.tab { case "listen": return .listen; case "read": return .read; default: return .home }
        #else
        return .home
        #endif
    }

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()

            Group {
                switch tab {
                case .home:   HomeView()
                case .listen: ListenView()
                case .read:   ReadView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: 0) { bottomChrome }
        }
        // THE single full-screen presenter for the whole shell.
        .fullScreenCover(item: $sheet) { s in sheetContent(s) }
        // Bridge the shared AppState journey / daily-plan signal into `sheet`.
        .onChange(of: app.presentedModal) { _, newValue in
            switch newValue {
            case .journey:   sheet = .journey
            case .dailyPlan: sheet = .dailyPlan
            case nil:        if sheet == .journey || sheet == .dailyPlan { sheet = nil }
            }
        }
        .onChange(of: sheet) { _, newValue in
            if newValue == nil, app.presentedModal != nil { app.presentedModal = nil }
        }
        #if DEBUG
        .onAppear {
            guard !dbgApplied else { return }
            dbgApplied = true
            switch DebugRoute.modal {
            case "player": app.nowPlaying = BibleData.creationStory; app.isPlaying = true; sheet = .player
            case "dailyplan": sheet = .debug("dailyplan")
            case "chat": sheet = .debug("chat")
            case "postcard": sheet = .debug("postcard")
            case "settings": sheet = .debug("menu")
            default: break
            }
            if let s = DebugRoute.settings {
                if DebugRoute.dark { settings.darkMode = true }
                sheet = .debug(s)
            }
        }
        #endif
    }

    @ViewBuilder private func sheetContent(_ s: ActiveSheet) -> some View {
        switch s {
        case .journey:
            MyJourneyView().environmentObject(app).environmentObject(settings)
        case .dailyPlan:
            DailyPlanView().environmentObject(app).environmentObject(settings)
        case .player:
            if let story = app.nowPlaying {
                AudioPlayerView(story: story).environmentObject(app).environmentObject(settings)
            }
        case .debug(let name):
            #if DEBUG
            debugDestination(name).environmentObject(app).environmentObject(settings)
            #else
            EmptyView()
            #endif
        }
    }

    #if DEBUG
    @ViewBuilder private func debugDestination(_ name: String) -> some View {
        switch name {
        case "menu":      MyJourneyView()
        case "dailyplan": DailyPlanView()
        case "chat":      ChatView(seed: .dailyVerse(BibleData.dailyVerse))
        case "postcard":  StreakPostcardView(onFinish: { sheet = nil })
        default:
            NavigationStack {
                switch name {
                case "editinfo":      EditInformationView()
                case "preferences":   PreferencesView()
                case "bibleversion":  BibleVersionPicker()
                case "charm":         CharmPicker()
                case "notifications": NotificationPreferencesView()
                default:              MyJourneyView()
                }
            }
            .preferredColorScheme(settings.colorScheme)
        }
    }
    #endif

    private var bottomChrome: some View {
        VStack(spacing: 10) {
            if let s = app.nowPlaying { MiniPlayerBar(story: s) { sheet = .player } }
            tabBar
        }
        .padding(.horizontal, 14)
        .padding(.top, 6)
    }

    private var tabBar: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { t in
                Button { tab = t } label: {
                    VStack(spacing: 4) {
                        Image(systemName: t.icon).font(.system(size: 22, weight: .medium))
                        Text(t.title).font(.haven(13, .medium))
                    }
                    .foregroundStyle(tab == t ? Theme.brown : Theme.inkFaint)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            Capsule().fill(Theme.card)
                .shadow(color: .black.opacity(0.08), radius: 14, y: 4)
        )
    }
}

/// Docked now-playing bar shown above the tab bar while audio is loaded.
struct MiniPlayerBar: View {
    @EnvironmentObject private var app: AppState
    let story: Story
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ArtworkView(art: story.artwork)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 2) {
                    Text(story.title).font(.haven(16, .semibold)).foregroundStyle(Theme.ink)
                        .lineLimit(1)
                    Text(Brand.audioSource).font(.havenCaption).foregroundStyle(Theme.inkSoft)
                }
                Spacer()
                Button {
                    app.isPlaying.toggle()
                } label: {
                    Image(systemName: app.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                }
                .buttonStyle(.plain)
            }
            .padding(10)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.gold).frame(height: 3).frame(maxWidth: 120)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10).offset(y: -2)
            }
            .shadow(color: .black.opacity(0.06), radius: 10, y: 3)
        }
        .buttonStyle(.plain)
    }
}
