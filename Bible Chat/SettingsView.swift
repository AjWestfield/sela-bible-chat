//
//  SettingsView.swift
//  Bible Chat  ·  "Sela" recreation
//
//  The "My Journey" menu opened by the Home + button, plus every sub-screen:
//  Your information, Preferences (Bible version / Language / Dark Mode /
//  Haptics / Audio / Charm), Notification preferences, Manage subscription,
//  Restore Purchases, Help & Support, Legal, Delete my account.
//

import SwiftUI
import UIKit
import StoreKit
import AuthenticationServices

// MARK: - Shared scaffold

/// Standard settings page: custom header (chevron + title) over an adaptive surface.
struct SettingsScreen<Content: View>: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text(title)
                    .font(.havenSubheading).foregroundStyle(settings.textPrimary)
                    .lineLimit(1).minimumScaleFactor(0.6).padding(.horizontal, 64)
                HStack {
                    CircleIconButton(systemName: "chevron.left") { dismiss() }
                        .accessibilityIdentifier("journey-back-button")
                    Spacer()
                }
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.top, 8).padding(.bottom, 10)

            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(settings.surface.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct SettingsRow: View {
    @EnvironmentObject private var settings: SettingsStore
    let title: String
    var value: String? = nil
    var tint: Color? = nil
    var chevron: Bool = true
    var body: some View {
        HStack(spacing: 10) {
            Text(title).font(.haven(21)).foregroundStyle(tint ?? settings.textPrimary)
            Spacer()
            if let value { Text(value).font(.haven(18)).foregroundStyle(settings.textFaint) }
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(settings.textFaint)
            }
        }
        .padding(.vertical, 17)
        .contentShape(Rectangle())
    }
}

private struct RowDivider: View {
    @EnvironmentObject private var settings: SettingsStore
    var body: some View { Rectangle().fill(settings.divider).frame(height: 1) }
}

// MARK: - My Journey (root)

struct MyJourneyView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    @State private var showDelete = false
    @State private var showRestore = false
    @State private var restoreMessage = ""
    @State private var copied = false

    private var displayName: String { app.name.isEmpty ? "Friend" : app.name }

    var body: some View {
        NavigationStack {
            SettingsScreen(title: "My Journey") {
                ScrollView {
                    VStack(spacing: 0) {
                        profile.padding(.top, 6).padding(.bottom, 14)

                        NavigationLink { EditInformationView() } label: { SettingsRow(title: "Your information") }
                        RowDivider()
                        NavigationLink { PreferencesView() } label: { SettingsRow(title: "Preferences") }
                        RowDivider()
                        NavigationLink { NotificationPreferencesView() } label: { SettingsRow(title: "Notification preferences") }
                        RowDivider()
                        NavigationLink { ManageSubscriptionView() } label: { SettingsRow(title: "Manage subscription") }
                        RowDivider()
                        Button {
                            let ok = app.restorePurchases()
                            restoreMessage = ok
                                ? "Your subscription has been restored."
                                : "No active subscription found."
                            showRestore = true
                        } label: { SettingsRow(title: "Restore Purchases") }.buttonStyle(.plain)
                        RowDivider()
                        NavigationLink { HelpSupportView() } label: { SettingsRow(title: "Help & Support") }
                        RowDivider()
                        NavigationLink { LegalView() } label: { SettingsRow(title: "Legal") }
                        RowDivider()
                        Button { showDelete = true } label: {
                            SettingsRow(title: "Delete my account", tint: Theme.rose, chevron: false)
                        }.buttonStyle(.plain)
                        RowDivider()

                        userIDFooter.padding(.top, 40)
                    }
                    .padding(.horizontal, Theme.Space.screen)
                    .padding(.bottom, 40)
                }
            }
            .preferredColorScheme(settings.colorScheme)
        }
        .alert("Delete my account?", isPresented: $showDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { app.resetForDemo(); dismiss() }
        } message: {
            Text("This permanently erases your \(Brand.appName) data on this device.")
        }
        .alert("Restore Purchases", isPresented: $showRestore) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage)
        }
    }

    private var profile: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .stroke(settings.textFaint.opacity(0.6), lineWidth: 1.5)
                    .frame(width: 118, height: 118)
                    .overlay(
                        Image(systemName: "cross.fill")
                            .font(.system(size: 42, weight: .light))
                            .foregroundStyle(settings.textFaint.opacity(0.7))
                    )
                Circle().fill(Theme.brown)
                    .frame(width: 34, height: 34)
                    .overlay(Image(systemName: "camera.fill").font(.system(size: 14)).foregroundStyle(.white))
                    .offset(x: 2, y: 2)
            }
            Text(displayName).font(.haven(22, .medium)).foregroundStyle(settings.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }

    private var userIDFooter: some View {
        Button {
            UIPasteboard.general.string = settings.userID
            withAnimation { copied = true }
        } label: {
            VStack(spacing: 5) {
                Text(copied ? "Copied to clipboard" : "User ID, tap to copy")
                    .font(.havenTiny).foregroundStyle(settings.textFaint)
                Text(settings.userID.uppercased())
                    .font(.haven(16)).foregroundStyle(settings.textFaint)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Your information

struct EditInformationView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var settings: SettingsStore

    @State private var editName = false
    @State private var editAge = false
    @State private var tempName = ""
    @State private var tempAge = ""
    @State private var showCreateAccount = false

    var body: some View {
        SettingsScreen(title: "Edit My Information") {
            ScrollView {
                VStack(spacing: 0) {
                    editableRow(label: "Name", value: app.name.isEmpty ? "—" : app.name) {
                        tempName = app.name; editName = true
                    }
                    RowDivider()
                    editableRow(label: "Age", value: settings.age.isEmpty ? "—" : settings.age) {
                        tempAge = settings.age; editAge = true
                    }
                    RowDivider()

                    Text("Account")
                        .font(.havenUI(13, .semibold)).tracking(1).textCase(.uppercase)
                        .foregroundStyle(settings.textFaint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 30).padding(.bottom, 4)

                    Button { showCreateAccount = true } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Create Account").font(.haven(21)).foregroundStyle(settings.textPrimary)
                                Text("Protect your data with Apple Sign In")
                                    .font(.havenCaption).foregroundStyle(settings.textFaint)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold)).foregroundStyle(settings.textFaint)
                        }
                        .padding(.vertical, 15).contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    RowDivider()
                }
                .padding(.horizontal, Theme.Space.screen)
            }
        }
        .alert("Your name", isPresented: $editName) {
            TextField("Name", text: $tempName)
            Button("Save") { app.name = tempName }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Your age", isPresented: $editAge) {
            TextField("Age", text: $tempAge)
            Button("Save") { settings.age = tempAge }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showCreateAccount) {
            CreateAccountSheet()
                .environmentObject(settings)
        }
    }

    private func editableRow(label: String, value: String, edit: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(label).font(.havenCaption).foregroundStyle(settings.textFaint)
                Text(value).font(.haven(21)).foregroundStyle(settings.textPrimary)
            }
            Spacer()
            Button(action: edit) {
                Image(systemName: "pencil").font(.system(size: 18, weight: .medium)).foregroundStyle(settings.textSecondary)
            }.buttonStyle(.plain)
        }
        .padding(.vertical, 15)
    }
}

// MARK: - Create Account sheet

private struct CreateAccountSheet: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(settings.textFaint)
                        .frame(width: 34, height: 34)
                        .background(settings.elevated, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.top, 18)

            Spacer(minLength: 12)

            VStack(spacing: 18) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 46, weight: .light))
                    .foregroundStyle(settings.textSecondary)

                Text("Protect your journey")
                    .font(.haven(26, .semibold)).foregroundStyle(settings.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Create an account to back up your saved verses, streaks, and journey so they follow you to any device.")
                    .font(.haven(18)).foregroundStyle(settings.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
            .padding(.horizontal, Theme.Space.screen)

            Spacer(minLength: 20)

            VStack(spacing: 12) {
                SignInWithAppleButton(.signUp) { _ in
                } onCompletion: { _ in
                    dismiss()
                }
                .signInWithAppleButtonStyle(settings.darkMode ? .white : .black)
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))

                Button { dismiss() } label: {
                    Text("Not now")
                        .font(.haven(18, .medium)).foregroundStyle(settings.textFaint)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(settings.surface.ignoresSafeArea())
        .preferredColorScheme(settings.colorScheme)
    }
}

// MARK: - Preferences

struct PreferencesView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        SettingsScreen(title: "Preferences") {
            ScrollView {
                VStack(spacing: 0) {
                    NavigationLink { BibleVersionPicker() } label: {
                        SettingsRow(title: "Bible version", value: settings.bibleVersion.rawValue)
                    }
                    RowDivider()
                    NavigationLink { LanguagePicker() } label: {
                        SettingsRow(title: "Language", value: settings.language)
                    }
                    RowDivider()
                    toggleRow("Dark Mode", $settings.darkMode)
                    RowDivider()
                    toggleRow("Haptics and vibration", $settings.haptics)
                    RowDivider()
                    toggleRow("Audio", $settings.audio)
                    RowDivider()
                    NavigationLink { CharmPicker() } label: { SettingsRow(title: "Charm") }
                    RowDivider()
                }
                .padding(.horizontal, Theme.Space.screen)
            }
        }
    }

    private func toggleRow(_ title: String, _ binding: Binding<Bool>) -> some View {
        HStack {
            Text(title).font(.haven(21)).foregroundStyle(settings.textPrimary)
            Spacer()
            Toggle("", isOn: binding).labelsHidden().tint(.green)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Bible version carousel

struct BibleVersionPicker: View {
    @EnvironmentObject private var settings: SettingsStore
    @State private var index = 0

    private var pageVersion: BibleVersion { BibleVersion.allCases[safe: index] ?? .kjv }

    var body: some View {
        SettingsScreen(title: "Bible Version") {
            VStack(spacing: 0) {
                TabView(selection: $index) {
                    ForEach(Array(BibleVersion.allCases.enumerated()), id: \.offset) { i, v in
                        versionPage(v).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<BibleVersion.allCases.count, id: \.self) { i in
                        Circle().fill(i == index ? Theme.brown : settings.textFaint.opacity(0.4))
                            .frame(width: 7, height: 7)
                    }
                }
                .padding(.top, 6)

                Spacer(minLength: 20)
                bottomButton.padding(.horizontal, Theme.Space.screen).padding(.bottom, 24)
            }
        }
        .onAppear { index = BibleVersion.allCases.firstIndex(of: settings.bibleVersion) ?? 0 }
    }

    private func versionPage(_ v: BibleVersion) -> some View {
        VStack(spacing: 20) {
            Spacer(minLength: 10)
            BookCover(version: v).frame(height: 360).padding(.horizontal, 70)
            Flourish(tint: settings.textSecondary)
            VStack(spacing: 8) {
                Text(v.fullName).font(.haven(28, .semibold)).foregroundStyle(settings.textSecondary)
                    .multilineTextAlignment(.center)
                Text(v.descriptor).font(.haven(18)).foregroundStyle(settings.textFaint)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            Spacer(minLength: 10)
        }
    }

    @ViewBuilder private var bottomButton: some View {
        if pageVersion == settings.bibleVersion {
            HStack(spacing: 10) {
                Image(systemName: "checkmark").font(.system(size: 20, weight: .bold))
                Text("Currently using \(pageVersion.rawValue)").font(.haven(22, .semibold))
            }
            .foregroundStyle(settings.textSecondary)
            .frame(maxWidth: .infinity).padding(.vertical, 12)
        } else {
            HavenWhitePill(title: "Use \(pageVersion.rawValue)") { settings.bibleVersion = pageVersion }
        }
    }
}

struct LanguagePicker: View {
    @EnvironmentObject private var settings: SettingsStore
    private let languages = ["English", "Español", "Français", "Deutsch", "Português"]
    var body: some View {
        SettingsScreen(title: "Language") {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(languages, id: \.self) { lang in
                        Button { settings.language = lang } label: {
                            HStack {
                                Text(lang).font(.haven(21)).foregroundStyle(settings.textPrimary)
                                Spacer()
                                if settings.language == lang {
                                    Image(systemName: "checkmark").font(.system(size: 17, weight: .bold))
                                        .foregroundStyle(Theme.brown)
                                }
                            }
                            .padding(.vertical, 17).contentShape(Rectangle())
                        }.buttonStyle(.plain)
                        RowDivider()
                    }
                }
                .padding(.horizontal, Theme.Space.screen)
            }
        }
    }
}

// MARK: - Charm picker

struct CharmPicker: View {
    @EnvironmentObject private var settings: SettingsStore
    private let cols = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        SettingsScreen(title: "Charm") {
            ScrollView {
                Text("Select your charm")
                    .font(.haven(22, .medium)).foregroundStyle(settings.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Theme.Space.screen).padding(.bottom, 16).padding(.top, 6)

                LazyVGrid(columns: cols, spacing: 16) {
                    ForEach(Charm.allCases) { c in
                        Button { settings.charm = c } label: {
                            CharmCard(charm: c, selected: settings.charm == c)
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Space.screen)
                .padding(.bottom, 40)
            }
        }
    }
}

private struct CharmCard: View {
    @EnvironmentObject private var settings: SettingsStore
    let charm: Charm
    let selected: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RadialGradient(
                    colors: [
                        charmGlow.opacity(selected ? 0.34 : 0.18),
                        .clear
                    ],
                    center: .center,
                    startRadius: 6,
                    endRadius: 78
                )
                CharmView(charm: charm)
                    .frame(width: 112, height: 112)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 116)

            HStack(spacing: 7) {
                Text(charm.title)
                    .font(.haven(17, .medium))
                    .foregroundStyle(selected ? settings.textPrimary : settings.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(height: 22)
        }
        .padding(.horizontal, 12)
        .padding(.top, 18)
        .padding(.bottom, 14)
        .frame(maxWidth: .infinity)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(cardStroke)
        .overlay(alignment: .topTrailing) {
            if selected {
                Circle()
                    .fill(Theme.brown)
                    .frame(width: 26, height: 26)
                    .overlay(Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundStyle(.white))
                    .offset(x: -12, y: 12)
            }
        }
        .shadow(color: selected ? charmGlow.opacity(settings.darkMode ? 0.20 : 0.26) : .black.opacity(settings.darkMode ? 0.18 : 0.08),
                radius: selected ? 16 : 10,
                y: selected ? 8 : 5)
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var cardBackground: some ShapeStyle {
        LinearGradient(
            colors: settings.darkMode
                ? [Color(hex: "#2D2721"), Color(hex: "#1F1A16")]
                : [Color(hex: "#FFF6E9"), Color(hex: "#F0DFCE")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardStroke: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(
                selected
                    ? LinearGradient(colors: [Theme.goldSoft, Theme.brown], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [Color.white.opacity(settings.darkMode ? 0.08 : 0.45), Color.black.opacity(0.05)],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing),
                lineWidth: selected ? 2 : 1
            )
    }

    private var charmGlow: Color {
        switch charm {
        case .silverOrnate: Color(hex: "#F3F2FA")
        case .darkOrnate: Color(hex: "#5B5047")
        case .bronzeCrucifix: Color(hex: "#B47A35")
        default: Theme.gold
        }
    }
}

// MARK: - Simpler leaf screens

struct NotificationPreferencesView: View {
    @EnvironmentObject private var settings: SettingsStore

    var body: some View {
        SettingsScreen(title: "Notification preferences") {
            ScrollView {
                VStack(spacing: 0) {
                    toggle("Daily verse", $settings.notifDailyVerse)
                    RowDivider()
                    toggle("Prayer reminders", $settings.notifPrayer)
                    RowDivider()
                    toggle("Streak reminders", $settings.notifStreak)
                    RowDivider()
                    toggle("New devotionals", $settings.notifDevotionals)
                    RowDivider()
                }
                .padding(.horizontal, Theme.Space.screen)
            }
        }
    }
    private func toggle(_ t: String, _ b: Binding<Bool>) -> some View {
        HStack {
            Text(t).font(.haven(21)).foregroundStyle(settings.textPrimary)
            Spacer()
            Toggle("", isOn: b).labelsHidden().tint(.green)
        }.padding(.vertical, 12)
    }
}

struct ManageSubscriptionView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.openURL) private var openURL
    var body: some View {
        SettingsScreen(title: "Manage subscription") {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(Brand.appName) Premium").font(.haven(24, .semibold)).foregroundStyle(settings.textPrimary)
                        Text("7-day free trial, then $6.99 per week")
                            .font(.haven(18)).foregroundStyle(settings.textSecondary)
                        Text("Renews automatically. Cancel anytime in the App Store.")
                            .font(.havenCaption).foregroundStyle(settings.textFaint)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(settings.elevated, in: RoundedRectangle(cornerRadius: Theme.Radius.card))

                    HavenPrimaryButton(title: "Manage in App Store") {
                        openURL(URL(string: "https://apps.apple.com/account/subscriptions")!)
                    }
                }
                .padding(.horizontal, Theme.Space.screen)
                .padding(.top, 8)
            }
        }
    }
}

struct HelpSupportView: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @State private var showFAQ = false

    var body: some View {
        SettingsScreen(title: "Help & Support") {
            ScrollView {
                VStack(spacing: 0) {
                    Button {
                        openURL(URL(string: "mailto:support@example.com")!)
                    } label: {
                        linkRow("Contact us", "envelope")
                    }.buttonStyle(.plain)
                    RowDivider()

                    Button {
                        showFAQ = true
                    } label: {
                        linkRow("Frequently asked questions", "questionmark.circle")
                    }.buttonStyle(.plain)
                    RowDivider()

                    Button {
                        requestReview()
                    } label: {
                        linkRow("Rate \(Brand.appName)", "star")
                    }.buttonStyle(.plain)
                    RowDivider()

                    ShareLink(item: "Sela — Bible Chat") {
                        linkRow("Share with a friend", "square.and.arrow.up")
                    }.buttonStyle(.plain)
                    RowDivider()
                }
                .padding(.horizontal, Theme.Space.screen)
            }
        }
        .sheet(isPresented: $showFAQ) {
            FAQSheet().environmentObject(settings)
        }
    }
    private func linkRow(_ t: String, _ icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.system(size: 18)).foregroundStyle(settings.textSecondary).frame(width: 24)
            Text(t).font(.haven(21)).foregroundStyle(settings.textPrimary)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(settings.textFaint)
        }.padding(.vertical, 17).contentShape(Rectangle())
    }
}

// MARK: - FAQ sheet

private struct FAQSheet: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    private let items: [(q: String, a: String)] = [
        ("Is \(Brand.appName) free to use?",
         "\(Brand.appName) offers a free trial, after which Premium unlocks unlimited chats and audio. You can manage or cancel your subscription anytime in the App Store."),
        ("How do I change my Bible version?",
         "Open My Journey → Preferences → Bible version, then swipe through the covers and tap “Use” on the translation you’d like."),
        ("Are my conversations private?",
         "Your journey, saved verses, and chats stay on your device. Creating an account with Apple Sign In lets you securely back them up.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("FAQ")
                    .font(.havenSubheading).foregroundStyle(settings.textPrimary)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(settings.textFaint)
                        .frame(width: 34, height: 34)
                        .background(settings.elevated, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.top, 18).padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(items, id: \.q) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.q)
                                .font(.haven(20, .semibold)).foregroundStyle(settings.textPrimary)
                            Text(item.a)
                                .font(.haven(17)).foregroundStyle(settings.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.Space.screen)
                .padding(.top, 12).padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(settings.surface.ignoresSafeArea())
        .preferredColorScheme(settings.colorScheme)
    }
}

struct LegalView: View {
    @EnvironmentObject private var settings: SettingsStore
    @State private var showAcknowledgements = false

    var body: some View {
        SettingsScreen(title: "Legal") {
            ScrollView {
                VStack(spacing: 0) {
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        row("Terms of Service")
                    }.buttonStyle(.plain)
                    RowDivider()
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        row("Privacy Policy")
                    }.buttonStyle(.plain)
                    RowDivider()
                    Button { showAcknowledgements = true } label: {
                        row("Acknowledgements")
                    }.buttonStyle(.plain)
                    RowDivider()
                }
                .padding(.horizontal, Theme.Space.screen)
            }
        }
        .sheet(isPresented: $showAcknowledgements) {
            AcknowledgementsSheet().environmentObject(settings)
        }
    }
    private func row(_ t: String) -> some View {
        HStack {
            Text(t).font(.haven(21)).foregroundStyle(settings.textPrimary)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(settings.textFaint)
        }.padding(.vertical, 17).contentShape(Rectangle())
    }
}

// MARK: - Acknowledgements sheet

private struct AcknowledgementsSheet: View {
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Acknowledgements")
                    .font(.havenSubheading).foregroundStyle(settings.textPrimary)
                    .lineLimit(1).minimumScaleFactor(0.7)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(settings.textFaint)
                        .frame(width: 34, height: 34)
                        .background(settings.elevated, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.top, 18).padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(Brand.appName) is made with gratitude for the open-source community.")
                        .font(.haven(18)).foregroundStyle(settings.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Kokoro TTS")
                            .font(.haven(19, .semibold)).foregroundStyle(settings.textPrimary)
                        Text("On-device text-to-speech powering the app’s spoken scripture and devotionals.")
                            .font(.haven(16)).foregroundStyle(settings.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("SwiftUI")
                            .font(.haven(19, .semibold)).foregroundStyle(settings.textPrimary)
                        Text("Apple’s declarative UI framework, used throughout \(Brand.appName).")
                            .font(.haven(16)).foregroundStyle(settings.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text("With thanks to everyone whose work makes this app possible.")
                        .font(.havenCaption).foregroundStyle(settings.textFaint)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Theme.Space.screen)
                .padding(.top, 12).padding(.bottom, 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(settings.surface.ignoresSafeArea())
        .preferredColorScheme(settings.colorScheme)
    }
}

#Preview {
    MyJourneyView()
        .environmentObject(AppState())
        .environmentObject(SettingsStore())
}
