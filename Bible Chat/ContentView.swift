//
//  ContentView.swift
//  Bible Chat  ·  "Haven" recreation
//
//  Root router. Everything the app can show is reachable from here,
//  switching on AppState.phase:  launch → onboarding → paywall → verseShare → main.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var app: AppState
    #if DEBUG
    @State private var showLaunch = !DebugRoute.active
    #else
    @State private var showLaunch = true
    #endif

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()

            switch app.phase {
            case .onboarding: OnboardingRootView()
            case .paywall:    PaywallView()
            case .verseShare: VerseShareView()
            case .main:       MainTabView()
            }

            if showLaunch {
                LaunchSplash()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_300_000_000)
            withAnimation(.easeInOut(duration: 0.5)) { showLaunch = false }
        }
        .animation(.easeInOut(duration: 0.45), value: app.phase)
    }
}

/// Launch screen — Sela mark over warm vellum.
struct LaunchSplash: View {
    @State private var glow = false
    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(spacing: 12) {
                BrandMark(size: 128)
                    .scaleEffect(glow ? 1.03 : 0.97)
                    .opacity(glow ? 1 : 0.86)
                Text(Brand.appName)
                    .font(.haven(34, .semibold))
                    .foregroundStyle(Theme.ink)
                    .opacity(glow ? 1 : 0.78)
            }
                .scaleEffect(glow ? 1.03 : 0.97)
                .opacity(glow ? 1 : 0.85)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { glow = true }
        }
    }
}

/// Legacy reference mark retained for comparison screens.
struct CrossInHands: View {
    var size: CGFloat = 120
    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Capsule()
                    .fill(Theme.gold.opacity(0.5))
                    .frame(width: 3, height: size * 0.16)
                    .offset(y: -size * 0.42)
                    .rotationEffect(.degrees(Double(i) / 12 * 360))
            }
            GoldCross(size: size * 0.5, glow: true)
                .offset(y: -size * 0.05)
            HandsShape()
                .stroke(Theme.ink, style: StrokeStyle(lineWidth: size * 0.05, lineCap: .round, lineJoin: .round))
                .frame(width: size, height: size * 0.5)
                .offset(y: size * 0.34)
        }
        .frame(width: size * 1.4, height: size * 1.4)
    }
}

/// Two cupped hands (simple line drawing).
struct HandsShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let w = r.width, h = r.height
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.15))
        p.addQuadCurve(to: CGPoint(x: w * 0.06, y: h * 0.75),
                       control: CGPoint(x: w * 0.12, y: h * 0.15))
        p.addLine(to: CGPoint(x: w * 0.18, y: h * 0.95))
        p.move(to: CGPoint(x: w * 0.5, y: h * 0.15))
        p.addQuadCurve(to: CGPoint(x: w * 0.94, y: h * 0.75),
                       control: CGPoint(x: w * 0.88, y: h * 0.15))
        p.addLine(to: CGPoint(x: w * 0.82, y: h * 0.95))
        return p
    }
}

#Preview {
    ContentView().environmentObject(AppState())
}
