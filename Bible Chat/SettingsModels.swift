//
//  SettingsModels.swift
//  Bible Chat  ·  "Sela" recreation
//
//  Bible-version + charm value types and their SwiftUI renderings
//  (3D-ish book covers and metal cross charms — drawn, no bundled art).
//

import SwiftUI

// MARK: - Bible versions

enum BibleVersion: String, CaseIterable, Identifiable {
    case kjv = "KJV", niv = "NIV", nkjv = "NKJV", esv = "ESV", nlt = "NLT", nabre = "NABRE"
    var id: String { rawValue }

    var fullName: String {
        switch self {
        case .kjv:   "King James Version"
        case .niv:   "New International Version"
        case .nkjv:  "New King James Version"
        case .esv:   "English Standard Version"
        case .nlt:   "New Living Translation"
        case .nabre: "New American Bible Revised Edition"
        }
    }

    var descriptor: String {
        switch self {
        case .kjv:   "Classic, poetic, traditional English"
        case .niv:   "Modern, clear, balanced translation"
        case .nkjv:  "Updated yet traditional wording"
        case .esv:   "Precise, literary, scholarly tone"
        case .nlt:   "Easy, natural, conversational flow"
        case .nabre: "Catholic, accurate, liturgical focus"
        }
    }

    var coverColors: [Color] {
        switch self {
        case .kjv:   [Color(hex: "#42424A"), Color(hex: "#1D1D22")]
        case .niv:   [Color(hex: "#6E8FC7"), Color(hex: "#3E5E96")]
        case .nkjv:  [Color(hex: "#743E3E"), Color(hex: "#47201F")]
        case .esv:   [Color(hex: "#6E8E6E"), Color(hex: "#3E5E44")]
        case .nlt:   [Color(hex: "#BFA277"), Color(hex: "#8E7048")]
        case .nabre: [Color(hex: "#5E4632"), Color(hex: "#3A2A1C")]
        }
    }
}

/// A leather-bound Bible cover with a gold double-frame, cross, and abbreviation.
struct BookCover: View {
    let version: BibleVersion
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            RoundedRectangle(cornerRadius: w * 0.06, style: .continuous)
                .fill(LinearGradient(colors: version.coverColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(
                    RoundedRectangle(cornerRadius: w * 0.035, style: .continuous)
                        .stroke(Theme.goldSoft.opacity(0.85), lineWidth: 1.6)
                        .padding(w * 0.07)
                )
                .overlay(
                    // spine highlight
                    LinearGradient(colors: [.white.opacity(0.14), .clear, .black.opacity(0.12)],
                                   startPoint: .leading, endPoint: .trailing)
                        .clipShape(RoundedRectangle(cornerRadius: w * 0.06, style: .continuous))
                )
                .overlay(
                    VStack(spacing: w * 0.06) {
                        Image(systemName: "cross.fill")
                            .font(.system(size: w * 0.16, weight: .light))
                            .foregroundStyle(Theme.goldSoft)
                        Text(version.rawValue)
                            .font(.haven(w * 0.20, .bold))
                            .foregroundStyle(.white)
                    }
                )
                .shadow(color: .black.opacity(0.28), radius: 14, y: 10)
        }
        .aspectRatio(0.72, contentMode: .fit)
    }
}

// MARK: - Charms (metal cross pendants)

enum CharmStyle { case plain, ornate, crucifix }

enum Charm: String, CaseIterable, Identifiable {
    case goldCrucifix, goldOrnate, silverOrnate, goldPlain, darkOrnate, bronzeCrucifix
    var id: String { rawValue }

    var title: String {
        switch self {
        case .goldCrucifix: "Radiant"
        case .goldOrnate: "Trinity"
        case .silverOrnate: "Silver"
        case .goldPlain: "Simple"
        case .darkOrnate: "Midnight"
        case .bronzeCrucifix: "Bronze"
        }
    }

    var metal: [Color] {
        switch self {
        case .goldCrucifix, .goldOrnate, .goldPlain:
            return [Color(hex: "#F6E29A"), Color(hex: "#E0B84E"), Color(hex: "#B78A2E")]
        case .silverOrnate:
            return [Color(hex: "#FFFFFF"), Color(hex: "#DDDDE2"), Color(hex: "#A9A9B2")]
        case .darkOrnate:
            return [Color(hex: "#5A5048"), Color(hex: "#332C26"), Color(hex: "#141210")]
        case .bronzeCrucifix:
            return [Color(hex: "#C9A46A"), Color(hex: "#9A7238"), Color(hex: "#6E4E22")]
        }
    }

    var style: CharmStyle {
        switch self {
        case .goldCrucifix, .bronzeCrucifix: .crucifix
        case .goldOrnate, .silverOrnate, .darkOrnate: .ornate
        case .goldPlain: .plain
        }
    }
}

/// A drawn metal cross with plain / ornate (trefoil) / crucifix variations.
struct CharmView: View {
    let charm: Charm
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let size = min(w, h)
            let barW = size * 0.14
            let grad = LinearGradient(colors: charm.metal, startPoint: .topLeading, endPoint: .bottomTrailing)
            let highlight = LinearGradient(colors: [.white.opacity(0.55), .clear, .black.opacity(0.18)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
            let crossH = size * 0.72
            let crossW = size * (charm.style == .plain ? 0.52 : 0.66)
            let crossTop = (h - crossH) / 2
            let armY = crossTop + crossH * 0.34

            ZStack {
                Circle()
                    .stroke(grad, lineWidth: max(2, size * 0.025))
                    .frame(width: size * 0.22, height: size * 0.22)
                    .position(x: w / 2, y: crossTop + size * 0.04)
                    .opacity(charm.style == .plain ? 0.45 : 0.75)

                RoundedRectangle(cornerRadius: barW * 0.45, style: .continuous)
                    .fill(grad)
                    .overlay(highlight.clipShape(RoundedRectangle(cornerRadius: barW * 0.45, style: .continuous)))
                    .frame(width: barW, height: crossH)
                    .position(x: w / 2, y: h / 2)
                    .shadow(color: charm.shadowColor.opacity(0.35), radius: 10, y: 7)

                RoundedRectangle(cornerRadius: barW * 0.45, style: .continuous)
                    .fill(grad)
                    .overlay(highlight.clipShape(RoundedRectangle(cornerRadius: barW * 0.45, style: .continuous)))
                    .frame(width: crossW, height: barW)
                    .position(x: w / 2, y: armY)
                    .shadow(color: charm.shadowColor.opacity(0.28), radius: 8, y: 5)

                if charm.style == .ornate {
                    let r = barW * 0.66
                    ForEach(Array(tipPoints(w: w, h: h, crossTop: crossTop, crossH: crossH, armY: armY).enumerated()), id: \.offset) { _, p in
                        Circle()
                            .fill(grad)
                            .overlay(Circle().fill(RadialGradient(colors: [.white.opacity(0.42), .clear],
                                                                  center: .topLeading,
                                                                  startRadius: 0,
                                                                  endRadius: r * 1.3)))
                            .frame(width: r * 2, height: r * 2)
                            .position(p)
                            .shadow(color: charm.shadowColor.opacity(0.25), radius: 5, y: 3)
                    }
                }

                if charm.style == .crucifix {
                    Capsule()
                        .fill(charm.metal.last!.opacity(0.42))
                        .frame(width: barW * 0.42, height: crossH * 0.30)
                        .position(x: w / 2, y: armY + crossH * 0.12)
                    Capsule()
                        .fill(charm.metal.last!.opacity(0.30))
                        .frame(width: crossW * 0.45, height: barW * 0.32)
                        .position(x: w / 2, y: armY + barW * 0.05)
                }

                RoundedRectangle(cornerRadius: barW * 0.2, style: .continuous)
                    .fill(Color.white.opacity(charm == .darkOrnate ? 0.08 : 0.24))
                    .frame(width: barW * 0.28, height: crossH * 0.58)
                    .position(x: w / 2 - barW * 0.22, y: h / 2 - crossH * 0.04)
            }
            .compositingGroup()
        }
    }

    private func tipPoints(w: CGFloat, h: CGFloat, crossTop: CGFloat, crossH: CGFloat, armY: CGFloat) -> [CGPoint] {
        [ CGPoint(x: w / 2, y: crossTop),                 // top
          CGPoint(x: w / 2, y: crossTop + crossH),        // bottom
          CGPoint(x: w * 0.17, y: armY),                  // left
          CGPoint(x: w * 0.83, y: armY) ]                 // right
    }
}

private extension Charm {
    var shadowColor: Color {
        switch self {
        case .silverOrnate: Color(hex: "#DCDDE5")
        case .darkOrnate: Color.black
        case .bronzeCrucifix: Color(hex: "#9A6230")
        default: Theme.gold
        }
    }
}

// MARK: - Decorative flourish (used under the book cover)

struct Flourish: View {
    var tint: Color = Theme.inkSoft
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(tint.opacity(0.5)).frame(width: 46, height: 1)
            Image(systemName: "seal").font(.system(size: 10)).foregroundStyle(tint.opacity(0.7))
            Circle().fill(tint.opacity(0.7)).frame(width: 5, height: 5)
            Image(systemName: "seal").font(.system(size: 10)).foregroundStyle(tint.opacity(0.7))
            Rectangle().fill(tint.opacity(0.5)).frame(width: 46, height: 1)
        }
    }
}
