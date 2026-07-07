//
//  Components.swift
//  Bible Chat  ·  "Haven" recreation
//
//  Reusable building blocks shared by every screen:
//  painterly artwork, buttons, chips, the gold cross, streak pill, etc.
//

import SwiftUI
import UIKit

// MARK: - Painterly artwork (impressionist oil-painting stand-ins via MeshGradient)

enum HavenArtwork: String, CaseIterable {
    case meadow, mountains, river, waterlilies, sunset, garden
    case darkCreation, goldenField, lockApps, dawn, village, harvest
    case cross, forgiveness, service, stress, lifeChange, mentalHealth

    var assetName: String {
        switch self {
        case .meadow: "ArtMeadow"
        case .mountains: "ArtMountains"
        case .river: "ArtRiver"
        case .waterlilies: "ArtWaterlilies"
        case .sunset: "ArtSunset"
        case .garden: "ArtGarden"
        case .darkCreation: "ArtDarkCreation"
        case .goldenField: "ArtGoldenField"
        case .lockApps: "ArtLockApps"
        case .dawn: "ArtDawn"
        case .village: "ArtVillage"
        case .harvest: "ArtHarvest"
        case .cross: "ArtCross"
        case .forgiveness: "ArtForgiveness"
        case .service: "ArtService"
        case .stress: "ArtStress"
        case .lifeChange: "ArtLifeChange"
        case .mentalHealth: "ArtMentalHealth"
        }
    }

    /// 9 colours laid out as a 3×3 mesh (row-major, top-left → bottom-right).
    var colors: [Color] {
        func c(_ h: String) -> Color { Color(hex: h) }
        switch self {
        case .meadow:
            return ["#6E7D3A","#8F9A4B","#B7A24E","#4F6B33","#7E9145","#C7B15A",
                    "#3C5A2C","#6E8B3E","#A7C05B"].map(c)
        case .mountains:
            return ["#7E8B8F","#9AA79C","#C9C09A","#5F7A6B","#8AA07E","#B8B889",
                    "#43604E","#6E8B5E","#9FB86F"].map(c)
        case .river:
            return ["#3E5E7A","#6E8FA0","#9DB36E","#2F5468","#5E86A2","#8FAE63",
                    "#274A5E","#4E7E62","#B7C070"].map(c)
        case .waterlilies:
            return ["#5E7E6E","#8FA07E","#C77E8E","#4E6E6E","#7E9E8E","#B76E9E",
                    "#3E5E5E","#6E8E7E","#E0A0B0"].map(c)
        case .sunset:
            return ["#D98A3E","#E0A94E","#C76E4E","#B76E3E","#E0B85E","#A75E4E",
                    "#8E4E3E","#D99E5E","#F0C86E"].map(c)
        case .garden:
            return ["#8FA0B8","#B7C0A0","#D9C88E","#5E7E5E","#8FA05E","#C0B070",
                    "#3E5E3E","#6E8E4E","#A7C060"].map(c)
        case .darkCreation:
            return ["#3A3226","#5E4E2E","#8E7040","#2A241C","#4E3E26","#B79050",
                    "#1A160F","#2E281C","#6E5A34"].map(c)
        case .goldenField:
            return ["#D9B84E","#E0C86E","#C7A03E","#B79E3E","#E0C05E","#A78E2E",
                    "#8E7E2E","#D9B84E","#F0D87E"].map(c)
        case .lockApps:
            return ["#C7A04E","#8FA0B8","#D9C070","#B7803E","#7E90A0","#C7B060",
                    "#8E6E3E","#5E7080","#E0C87E"].map(c)
        case .dawn:
            return ["#8FA0C0","#C0B0A0","#E0C89E","#7E90B0","#B0A090","#E0B888",
                    "#6E80A0","#A09080","#F0D0A0"].map(c)
        case .village:
            return ["#7E8B5E","#A7A06E","#C7B07E","#5E6E4E","#8E905E","#B7A070",
                    "#4E5E3E","#6E7E4E","#A79060"].map(c)
        case .harvest:
            return ["#C79E4E","#D9B85E","#B78E3E","#A78E3E","#C7A84E","#8E6E2E",
                    "#7E6E2E","#B7963E","#E0C060"].map(c)
        case .cross:
            return ["#E0C89E","#EAD8B0","#D9C090","#D0B888","#E6D0A0","#C7A870",
                    "#B89860","#D9C090","#F0E0B8"].map(c)
        case .forgiveness:
            return ["#8FA0B0","#C0A0A0","#E0C0A0","#7E90A0","#B09090","#D0A888",
                    "#6E8090","#A08078","#E0B898"].map(c)
        case .service:
            return ["#B78E5E","#C7A86E","#8FA05E","#A7804E","#C79E5E","#7E8E4E",
                    "#8E6E3E","#A78E4E","#B7B060"].map(c)
        case .stress:
            return ["#5E6E8E","#7E8EA0","#A0A0B0","#4E5E7E","#6E7E90","#9090A0",
                    "#3E4E6E","#5E6E80","#808090"].map(c)
        case .lifeChange:
            return ["#C78E5E","#E0B86E","#D9A05E","#B77E4E","#E0A85E","#C78E4E",
                    "#8E5E3E","#C79E5E","#F0C87E"].map(c)
        case .mentalHealth:
            return ["#7E9E8E","#A0B08E","#C7A0A0","#6E8E7E","#90A07E","#B78E9E",
                    "#5E7E6E","#7E9E7E","#D0A0B0"].map(c)
        }
    }
}

/// Impressionist background for a named scene.
struct ArtworkView: View {
    let art: HavenArtwork
    var body: some View {
        Group {
            if let image = UIImage(named: art.assetName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                MeshGradient(
                    width: 3, height: 3,
                    points: [
                        [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                        [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                    ],
                    colors: art.colors
                )
            }
        }
        .overlay(
            RadialGradient(colors: [.clear, .black.opacity(0.14)],
                           center: .center, startRadius: 80, endRadius: 540)
        )
    }
}

struct BrandMark: View {
    var size: CGFloat = 80

    var body: some View {
        Image("SelaLogoMark")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: Theme.gold.opacity(0.30), radius: size * 0.12, y: size * 0.04)
            .accessibilityHidden(true)
    }
}

// MARK: - Gold cross (paywall, personalization, launch)

struct GoldCross: View {
    var size: CGFloat = 96
    var glow: Bool = true
    private let gold = LinearGradient(
        colors: [Color(hex: "#F3DE9A"), Color(hex: "#D9A93E"), Color(hex: "#B5842A")],
        startPoint: .topLeading, endPoint: .bottomTrailing)
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.06)
                .fill(gold)
                .frame(width: size * 0.22, height: size)
            RoundedRectangle(cornerRadius: size * 0.06)
                .fill(gold)
                .frame(width: size * 0.66, height: size * 0.22)
                .offset(y: -size * 0.12)
        }
        .shadow(color: glow ? Theme.gold.opacity(0.55) : .clear, radius: 14)
        .frame(width: size, height: size)
    }
}

// MARK: - Buttons

/// Dark-brown filled pill CTA ("Start free trial →", "Enter Sela").
struct HavenPrimaryButton: View {
    let title: String
    var trailingArrow: Bool = false
    var fill: Color = Theme.brown
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title).font(.haven(21, .semibold))
                if trailingArrow { Image(systemName: "arrow.right").font(.system(size: 18, weight: .semibold)) }
            }
            .foregroundStyle(Color(hex: "#FBF6EC"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(fill, in: RoundedRectangle(cornerRadius: Theme.Radius.button))
        }
        .buttonStyle(.plain)
    }
}

/// White pill with ink serif label ("Begin", "Continue", "Review").
struct HavenWhitePill: View {
    let title: String
    var foreground: Color = Theme.ink
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.haven(21, .medium))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 19)
                .background(Color.white, in: RoundedRectangle(cornerRadius: Theme.Radius.button))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }
}

/// Round translucent/white icon button (nav chevrons, player controls).
struct CircleIconButton: View {
    let systemName: String
    var diameter: CGFloat = 46
    var bg: Color = .white
    var fg: Color = Theme.ink
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: diameter * 0.4, weight: .semibold))
                .foregroundStyle(fg)
                .frame(width: diameter, height: diameter)
                .background(bg, in: Circle())
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chips & tags

/// Rounded cream chip used for user replies / suggested prompts.
struct HavenChip: View {
    let text: String
    var filled: Bool = true
    var body: some View {
        Text(text)
            .font(.haven(17))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 16).padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(filled ? Theme.card : Color.white.opacity(0.9))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.hairline, lineWidth: 1))
            )
    }
}

/// Small verse-reference token (e.g. "Hebrews 13:8") with gold tint.
struct VerseRefTag: View {
    let ref: String
    var body: some View {
        Text(ref)
            .font(.havenUI(14, .semibold))
            .foregroundStyle(Theme.brown)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Theme.goldPale.opacity(0.7), in: RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Streak pill (calendar + flame + count)

struct StreakPill: View {
    let count: Int
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.inkSoft)
            HStack(spacing: 4) {
                Text("🔥").font(.system(size: 15))
                Text("\(count)").font(.haven(16, .semibold)).foregroundStyle(Theme.gold)
            }
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Color.white, in: Capsule())
        }
        .padding(.horizontal, 6).padding(.vertical, 5)
        .background(Theme.cardSoft, in: Capsule())
    }
}

// MARK: - Weekday selector (S M T W T F S with active gold ring)

struct WeekdayStrip: View {
    /// index of "today" 0=Sun … 6=Sat
    var todayIndex: Int = 3
    /// which days are completed (filled gold)
    var completed: Set<Int> = []
    private let labels = ["S","M","T","W","T","F","S"]
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<7, id: \.self) { i in
                Text(labels[i])
                    .font(.haven(18, .medium))
                    .foregroundStyle(completed.contains(i) ? Theme.brown : Theme.inkSoft)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        Circle().fill(completed.contains(i) ? Theme.goldSoft : Theme.cardSoft)
                    )
                    .overlay(
                        Circle().stroke(i == todayIndex ? Theme.gold : .clear, lineWidth: 2.5)
                    )
            }
        }
    }
}

// MARK: - Paper background modifier

extension View {
    func havenPaper() -> some View {
        self.background(Theme.paper.ignoresSafeArea())
    }
}
