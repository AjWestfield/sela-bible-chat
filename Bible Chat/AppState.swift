//
//  AppState.swift
//  Bible Chat  ·  "Haven" recreation
//
//  Single source of truth for routing + persisted user progress.
//

import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {

    // Routing
    @Published var phase: AppPhase

    // User profile (captured during onboarding)
    @Published var name: String { didSet { save() } }
    @Published var faithLevel: FaithLevel? { didSet { save() } }
    @Published var motivation: Motivation? { didSet { save() } }
    @Published var challenge: String { didSet { save() } }

    // Entitlement + progress
    @Published var isSubscribed: Bool { didSet { save() } }
    @Published var streak: Int { didSet { save() } }
    @Published var journeyIndex: Int { didSet { save() } }   // current stop reached
    @Published var completedWeekdays: Set<Int> { didSet { save() } }
    @Published var conversations: [Conversation] = [] { didSet { saveConversations() } }

    // Saved / bookmarked scripture (persisted)
    @Published var savedVerses: Set<String> = [] { didSet { d.set(Array(savedVerses), forKey: Self.key("savedVerses")) } }
    @Published var bookmarks: Set<String> = [] { didSet { d.set(Array(bookmarks), forKey: Self.key("bookmarks")) } }

    // Transient UI
    @Published var nowPlaying: Story? = nil
    @Published var isPlaying: Bool = false
    @Published var presentedModal: AppModal? = nil

    private let d = UserDefaults.standard

    init() {
        let onboarded = Self.persistedBool("onboarded")
        let subscribed = Self.persistedBool("subscribed")
        phase = onboarded ? .main : .onboarding
        name = Self.persistedString("name") ?? ""
        challenge = Self.persistedString("challenge") ?? ""
        faithLevel = Self.persistedString("faith").flatMap(FaithLevel.init(rawValue:))
        motivation = Self.persistedString("motivation").flatMap(Motivation.init(rawValue:))
        isSubscribed = subscribed
        streak = Self.persistedInteger("streak")
        journeyIndex = Self.persistedInteger("journeyIndex")
        let days = Self.persistedArray("weekdays") as? [Int] ?? []
        completedWeekdays = Set(days)
        savedVerses = Set((Self.persistedArray("savedVerses") as? [String]) ?? [])
        bookmarks = Set((Self.persistedArray("bookmarks") as? [String]) ?? [])
        if let data = d.data(forKey: Self.key("conversations")),
           let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = decoded
        }

        #if DEBUG
        applyDebugScreen()
        #endif
    }

    #if DEBUG
    private func applyDebugScreen() {
        guard let s = DebugRoute.screen else { return }
        if name.isEmpty { name = "Aj" }
        if challenge.isEmpty { challenge = "financial freedom" }
        if faithLevel == nil { faithLevel = .curious }
        if motivation == nil { motivation = .meaning }
        switch s {
        case "onboarding": phase = .onboarding
        case "paywall":    phase = .paywall
        case "verseShare": isSubscribed = true; phase = .verseShare
        case "mainReview":
            isSubscribed = true; streak = 1; journeyIndex = 1
            completedWeekdays = [currentWeekdayIndex]
            conversations = [Conversation(title: "Daily Verse Jul 1", subtitle: "Today",
                messages: [ChatMessage(role: .haven, text: "Today's wisdom from Hebrews 13:8.")])]
            phase = .main
        default: // "main"
            isSubscribed = true; streak = 0; journeyIndex = 0
            completedWeekdays = []; conversations = []; phase = .main
        }
    }
    #endif

    private func save() {
        d.set(name, forKey: Self.key("name"))
        d.set(challenge, forKey: Self.key("challenge"))
        d.set(isSubscribed, forKey: Self.key("subscribed"))
        d.set(streak, forKey: Self.key("streak"))
        d.set(journeyIndex, forKey: Self.key("journeyIndex"))
        d.set(faithLevel?.rawValue, forKey: Self.key("faith"))
        d.set(motivation?.rawValue, forKey: Self.key("motivation"))
        d.set(Array(completedWeekdays), forKey: Self.key("weekdays"))
    }

    private func saveConversations() {
        if let data = try? JSONEncoder().encode(conversations) {
            d.set(data, forKey: Self.key("conversations"))
        }
    }

    // MARK: Scripture actions

    func isSaved(_ ref: String) -> Bool { savedVerses.contains(ref) }
    func toggleSaved(_ ref: String) {
        if savedVerses.contains(ref) { savedVerses.remove(ref) } else { savedVerses.insert(ref) }
    }
    func isBookmarked(_ ref: String) -> Bool { bookmarks.contains(ref) }
    func toggleBookmark(_ ref: String) {
        if bookmarks.contains(ref) { bookmarks.remove(ref) } else { bookmarks.insert(ref) }
    }

    /// Mock StoreKit restore: reports whether an active entitlement was found.
    /// (Real StoreKit `AppStore.sync()` / `Transaction.currentEntitlements` would set this.)
    @discardableResult
    func restorePurchases() -> Bool {
        // With no real StoreKit product we treat a previously-recorded purchase as the entitlement.
        return isSubscribed
    }

    // MARK: Flow transitions

    func finishOnboarding() {
        d.set(true, forKey: Self.key("onboarded"))
        phase = .paywall
    }

    func completePurchase() {
        isSubscribed = true
        phase = .verseShare
    }

    func enterMainApp() { phase = .main }

    func presentDailyPlan() {
        present(.dailyPlan)
    }

    func presentJourney() {
        present(.journey)
    }

    /// Presents defensively: if a previous present was dropped by UIKit
    /// (e.g. requested mid-dismissal), `presentedModal` can be stuck at the
    /// same value with no cover on screen — a same-value write would then be
    /// a no-op forever. Nil-then-set guarantees the cover binding sees a change.
    private func present(_ modal: AppModal) {
        if presentedModal == nil {
            presentedModal = modal
        } else {
            presentedModal = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
                self?.presentedModal = modal
            }
        }
    }

    /// Marks today's plan complete → bumps streak + weekday, advances journey when earned.
    func completeDailyPlan() {
        streak += 1
        completedWeekdays.insert(currentWeekdayIndex)
        if let stop = BibleData.journeyStops[safe: journeyIndex + 1],
           streak >= stop.streaksRequired {
            journeyIndex += 1
        }
    }

    // MARK: Derived

    var displayName: String { name.isEmpty ? "friend" : name }

    var currentWeekdayIndex: Int {
        (Calendar.current.component(.weekday, from: Date()) - 1) % 7
    }

    /// Next journey stop the user is travelling toward.
    var nextStop: JourneyStop {
        BibleData.journeyStops[safe: journeyIndex + 1] ?? BibleData.journeyStops.last!
    }
    var currentStop: JourneyStop {
        BibleData.journeyStops[safe: journeyIndex] ?? BibleData.journeyStops[0]
    }

    /// "Reset progress" convenience for demoing the full flow again.
    func resetForDemo() {
        d.removeObject(forKey: Self.key("onboarded"))
        d.removeObject(forKey: Self.legacyKey("onboarded"))
        d.set(false, forKey: Self.key("subscribed"))
        d.set(false, forKey: Self.legacyKey("subscribed"))
        name = ""; challenge = ""; faithLevel = nil; motivation = nil
        isSubscribed = false; streak = 0; journeyIndex = 0; completedWeekdays = []
        conversations = []
        phase = .onboarding
    }

    private static func key(_ suffix: String) -> String { "\(Brand.storagePrefix).\(suffix)" }
    private static func legacyKey(_ suffix: String) -> String { "haven.\(suffix)" }

    private static func persistedBool(_ suffix: String) -> Bool {
        let d = UserDefaults.standard
        return d.object(forKey: key(suffix)) == nil ? d.bool(forKey: legacyKey(suffix)) : d.bool(forKey: key(suffix))
    }

    private static func persistedInteger(_ suffix: String) -> Int {
        let d = UserDefaults.standard
        return d.object(forKey: key(suffix)) == nil ? d.integer(forKey: legacyKey(suffix)) : d.integer(forKey: key(suffix))
    }

    private static func persistedString(_ suffix: String) -> String? {
        let d = UserDefaults.standard
        return d.string(forKey: key(suffix)) ?? d.string(forKey: legacyKey(suffix))
    }

    private static func persistedArray(_ suffix: String) -> [Any]? {
        let d = UserDefaults.standard
        return d.array(forKey: key(suffix)) ?? d.array(forKey: legacyKey(suffix))
    }
}

// Safe subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
