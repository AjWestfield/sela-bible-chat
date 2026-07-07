//
//  SettingsStore.swift
//  Bible Chat  ·  "Sela" recreation
//
//  Persisted user settings surfaced by the "My Journey" menu (the + button).
//  Also exposes dark-mode-adaptive colors so the settings module can flip
//  between light vellum and dark, matching the reference recording.
//

import SwiftUI
import Combine
import UserNotifications

@MainActor
final class SettingsStore: ObservableObject {
    @Published var bibleVersion: BibleVersion { didSet { d.set(bibleVersion.rawValue, forKey: Self.k("bibleVersion")) } }
    @Published var language: String { didSet { d.set(language, forKey: Self.k("language")) } }
    @Published var darkMode: Bool { didSet { d.set(darkMode, forKey: Self.k("darkMode")) } }
    @Published var haptics: Bool { didSet { d.set(haptics, forKey: Self.k("haptics")) } }
    @Published var audio: Bool { didSet { d.set(audio, forKey: Self.k("audio")) } }
    @Published var charm: Charm { didSet { d.set(charm.rawValue, forKey: Self.k("charm")) } }
    @Published var age: String { didSet { d.set(age, forKey: Self.k("age")) } }

    // Notification preferences (persisted; drive UNUserNotificationCenter scheduling)
    @Published var notifDailyVerse: Bool { didSet { d.set(notifDailyVerse, forKey: Self.k("notifDailyVerse")); syncNotifications() } }
    @Published var notifPrayer: Bool { didSet { d.set(notifPrayer, forKey: Self.k("notifPrayer")); syncNotifications() } }
    @Published var notifStreak: Bool { didSet { d.set(notifStreak, forKey: Self.k("notifStreak")); syncNotifications() } }
    @Published var notifDevotionals: Bool { didSet { d.set(notifDevotionals, forKey: Self.k("notifDevotionals")); syncNotifications() } }

    let userID: String

    private let d = UserDefaults.standard
    private static func k(_ s: String) -> String { "\(Brand.storagePrefix).settings.\(s)" }

    init() {
        let d = UserDefaults.standard
        bibleVersion = BibleVersion(rawValue: d.string(forKey: Self.k("bibleVersion")) ?? "") ?? .niv
        language = d.string(forKey: Self.k("language")) ?? "English"
        darkMode = d.bool(forKey: Self.k("darkMode"))
        haptics = d.object(forKey: Self.k("haptics")) == nil ? true : d.bool(forKey: Self.k("haptics"))
        audio = d.object(forKey: Self.k("audio")) == nil ? true : d.bool(forKey: Self.k("audio"))
        charm = Charm(rawValue: d.string(forKey: Self.k("charm")) ?? "") ?? .silverOrnate
        age = d.string(forKey: Self.k("age")) ?? ""
        func flag(_ s: String) -> Bool { d.object(forKey: Self.k(s)) == nil ? true : d.bool(forKey: Self.k(s)) }
        notifDailyVerse = flag("notifDailyVerse")
        notifPrayer = flag("notifPrayer")
        notifStreak = flag("notifStreak")
        notifDevotionals = flag("notifDevotionals")
        if let id = d.string(forKey: Self.k("userID")) {
            userID = id
        } else {
            let id = UUID().uuidString
            d.set(id, forKey: Self.k("userID"))
            userID = id
        }
    }

    // MARK: Dark-mode adaptive palette (settings module only)
    var colorScheme: ColorScheme { darkMode ? .dark : .light }
    var surface: Color        { darkMode ? Color(hex: "#141210") : Theme.paper }
    var elevated: Color       { darkMode ? Color(hex: "#221E19") : Theme.card }
    var textPrimary: Color    { darkMode ? Color(hex: "#F3ECDF") : Theme.ink }
    var textSecondary: Color  { darkMode ? Color(hex: "#B8AA95") : Theme.inkSoft }
    var textFaint: Color      { darkMode ? Color(hex: "#7F7566") : Theme.inkFaint }
    var divider: Color        { darkMode ? Color.white.opacity(0.10) : Theme.hairline }
    var charmTile: Color      { darkMode ? Color(hex: "#2A2420") : Color(hex: "#F2E5D9") }

    // MARK: Local notification scheduling
    /// Requests authorization (once) and (re)schedules the enabled daily reminders.
    func syncNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            Task { @MainActor in self.rescheduleNotifications() }
        }
    }

    private func rescheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        func schedule(_ id: String, _ title: String, _ body: String, hour: Int, minute: Int) {
            var c = DateComponents(); c.hour = hour; c.minute = minute
            let content = UNMutableNotificationContent()
            content.title = title; content.body = body; content.sound = .default
            let req = UNNotificationRequest(identifier: id,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: c, repeats: true))
            center.add(req)
        }
        if notifDailyVerse { schedule("dailyVerse", Brand.appName, "Your daily verse is ready.", hour: 8, minute: 0) }
        if notifPrayer { schedule("prayer", "Time to pray", "Take a moment for prayer with \(Brand.companionName).", hour: 20, minute: 0) }
        if notifStreak { schedule("streak", "Keep your streak", "Complete today's plan to keep your journey going.", hour: 19, minute: 0) }
        if notifDevotionals { schedule("devotionals", "New devotional", "A new devotional is waiting for you.", hour: 9, minute: 30) }
    }
}
