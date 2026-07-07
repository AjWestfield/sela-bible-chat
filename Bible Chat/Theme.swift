//
//  Theme.swift
//  Bible Chat  ·  "Haven" recreation
//
//  Central design system — colors, typography, metrics.
//  Every screen composes against these tokens so the whole app stays
//  visually consistent with the reference recording.
//

import SwiftUI
import UIKit

// MARK: - Hex helper

extension Color {
    /// A color that resolves to `light` in light mode and `dark` in dark mode.
    static func dynamic(_ light: String, _ dark: String) -> Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }

    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r, g, b, a: Double
        if s.count == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255
            g = Double((rgb & 0x00FF0000) >> 16) / 255
            b = Double((rgb & 0x0000FF00) >> 8) / 255
            a = Double(rgb & 0x000000FF) / 255
        } else {
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Palette

enum Theme {
    // Paper / surfaces (adaptive — flip to warm-dark when Dark Mode is on)
    static let paper       = Color.dynamic("#F6EFE5", "#14110D")   // main warm vellum background
    static let paperDeep   = Color.dynamic("#EFE5D7", "#1B1712")   // slightly deeper reader parchment
    static let card        = Color.dynamic("#FFF9F0", "#221D17")   // raised card / sheet
    static let cardSoft    = Color.dynamic("#F5EADB", "#2A231C")

    // Ink (serif text) — adaptive to stay legible on dark surfaces
    static let ink         = Color.dynamic("#3A2A1C", "#F3ECDF")   // primary
    static let inkSoft     = Color.dynamic("#7B6A58", "#B9AC97")   // secondary
    static let inkFaint    = Color.dynamic("#A99A88", "#8A7E6E")   // tertiary / captions

    // Brand browns (CTAs, active accents)
    static let brown       = Color(hex: "#5B3A22")
    static let brownDeep   = Color(hex: "#432815")

    // Secondary brand accents
    static let teal        = Color(hex: "#174F55")
    static let sage        = Color(hex: "#71805A")
    static let rose        = Color(hex: "#B7665D")
    static let inkBlue     = Color(hex: "#314F66")

    // Gold accents (streak flame, active day ring, cross)
    static let gold        = Color(hex: "#D9A93E")
    static let goldSoft    = Color(hex: "#E7C878")
    static let goldPale    = Color(hex: "#EBDDB6")

    // Celebration / postcard background
    static let amber       = Color(hex: "#E8A63E")
    static let amberDeep   = Color(hex: "#D5912B")

    // Hairlines / dividers
    static let hairline    = Color.dynamic("#E4D8C4", "#332B22")

    // Conversational sky gradient (onboarding Q&A + prayer)
    static let skyTop      = Color(hex: "#2E5F86")
    static let skyMid      = Color(hex: "#3F7099")
    static let skyBottom   = Color(hex: "#6E9DBD")

    // MARK: Metrics
    enum Radius {
        static let card: CGFloat   = 22
        static let sheet: CGFloat  = 30
        static let pill: CGFloat   = 30
        static let button: CGFloat = 18
        static let tile: CGFloat   = 16
    }

    enum Space {
        static let screen: CGFloat = 22
    }
}

// MARK: - Typography (system serif = New York)

extension Font {
    /// Serif (New York) — the app's primary typeface.
    static func haven(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    /// Sans (SF) for UI chrome where the reference uses it.
    static func havenUI(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // Semantic roles
    static var havenLargeTitle: Font { .haven(40, .bold) }      // "Welcome to Haven"
    static var havenTitle: Font      { .haven(34, .bold) }      // "Haven", "Congratulations!"
    static var havenHeading: Font    { .haven(26, .semibold) }  // section headers
    static var havenSubheading: Font { .haven(22, .semibold) }
    static var havenBody: Font       { .haven(19, .regular) }
    static var havenBodyM: Font      { .haven(18, .medium) }
    static var havenCaption: Font    { .haven(15, .regular) }
    static var havenTiny: Font       { .haven(13, .medium) }
}

// MARK: - Sky background used by the conversational onboarding + prayer

struct HavenSkyBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.skyTop, Theme.skyMid, Theme.skyBottom],
                           startPoint: .top, endPoint: .bottom)
            // Soft painterly clouds
            GeometryReader { geo in
                let w = geo.size.width, h = geo.size.height
                ForEach(HavenSkyBackground.clouds, id: \.0) { c in
                    Ellipse()
                        .fill(Color.white.opacity(c.4))
                        .frame(width: w * c.2, height: h * c.3)
                        .blur(radius: 34)
                        .position(x: w * c.0, y: h * c.1)
                }
            }
        }
        .ignoresSafeArea()
    }
    // x,y,w,h,opacity
    static let clouds: [(Double, Double, Double, Double, Double)] = [
        (0.20, 0.28, 0.7, 0.10, 0.16),
        (0.78, 0.20, 0.6, 0.09, 0.12),
        (0.50, 0.55, 0.9, 0.12, 0.10),
        (0.28, 0.80, 0.7, 0.10, 0.14),
        (0.82, 0.72, 0.6, 0.09, 0.10)
    ]
}
