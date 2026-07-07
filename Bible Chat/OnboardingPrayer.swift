import SwiftUI

/// Step 4 — the personalized prayer, recited via tap-and-hold.
struct OnboardingPrayer: View {
    let onComplete: () -> Void
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var settings: SettingsStore

    @State private var reciting = false     // true once "TAP TO RECITE" tapped
    @State private var holdProgress: CGFloat = 0
    @State private var holding = false
    @State private var showAmen = false
    @State private var holdTimer: Timer?

    private let holdDuration: Double = 2.2

    private var paragraphs: [String] {
        let name = app.displayName
        let challenge = app.challenge.isEmpty ? "peace" : app.challenge
        return [
            "Heavenly Father, I lift up \(name) to You. Thank You for the blessings they cherish, and for the joy and love You have placed in their life.",
            "Lord, draw near to \(name) as they navigate this season: \(challenge). Give them strength, hope, and clarity for the next faithful step.",
            "As \(name) seeks to grow closer to You, deepen their faith and help them feel Your loving presence with each step of the journey."
        ]
    }

    var body: some View {
        ZStack {
            HavenSkyBackground()
            // Darker vignette
            RadialGradient(
                colors: [Color.black.opacity(0.05), Color.black.opacity(0.42)],
                center: .center, startRadius: 120, endRadius: 620
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 40)

                Rectangle()
                    .fill(.white.opacity(0.35))
                    .frame(height: 1)
                    .padding(.horizontal, 30)

                VStack(spacing: 22) {
                    Text("A Prayer for \(app.displayName)")
                        .font(.haven(26, .semibold))
                        .foregroundStyle(.white)
                        .padding(.top, 28)

                    ForEach(Array(paragraphs.enumerated()), id: \.offset) { idx, para in
                        Text(para)
                            .font(.haven(24))
                            .foregroundStyle(.white.opacity(reciting || idx == 0 ? 0.96 : 0.68))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(.easeInOut(duration: 0.6), value: reciting)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 26)

                Rectangle()
                    .fill(.white.opacity(0.35))
                    .frame(height: 1)
                    .padding(.horizontal, 30)

                Spacer(minLength: 30)

                footer
                    .padding(.bottom, 60)
            }
        }
    }

    // MARK: - Footer (recite / hold / amen)

    @ViewBuilder private var footer: some View {
        if showAmen {
            Text("Amen.")
                .font(.haven(34, .semibold))
                .foregroundStyle(.white)
                .transition(.opacity.combined(with: .scale))
        } else if reciting {
            VStack(spacing: 26) {
                Text("Tap and hold")
                    .font(.haven(24))
                    .foregroundStyle(.white.opacity(0.7))

                ZStack {
                    Circle()
                        .fill(Theme.gold.opacity(0.9))
                        .frame(width: 96, height: 96)
                        .shadow(color: Theme.gold.opacity(holding ? 0.9 : 0.5),
                                radius: holding ? 30 : 18)

                    Circle()
                        .trim(from: 0, to: holdProgress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 96, height: 96)
                        .rotationEffect(.degrees(-90))

                    Image(systemName: "hands.sparkles")
                        .font(.system(size: 38, weight: .light))
                        .foregroundStyle(.white)
                }
                .scaleEffect(holding ? 1.06 : 1.0)
                .animation(.easeInOut(duration: 0.25), value: holding)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in if !holding { startHold() } }
                        .onEnded { _ in cancelHold() }
                )
            }
        } else {
            Button {
                Haptics.lightImpact(enabled: settings.haptics)
                withAnimation(.easeInOut(duration: 0.5)) { reciting = true }
            } label: {
                Text("TAP TO RECITE")
                    .font(.haven(18, .semibold))
                    .tracking(3)
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Hold logic

    private func startHold() {
        holding = true
        Haptics.mediumImpact(enabled: settings.haptics)
        holdTimer?.invalidate()
        let start = Date()
        holdTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { t in
            let elapsed = Date().timeIntervalSince(start)
            let p = min(CGFloat(elapsed / holdDuration), 1)
            holdProgress = p
            if p >= 1 {
                t.invalidate()
                completeRecitation()
            }
        }
    }

    private func cancelHold() {
        guard !showAmen else { return }
        holding = false
        holdTimer?.invalidate()
        if holdProgress < 1 {
            Haptics.selection(enabled: settings.haptics)
            withAnimation(.easeOut(duration: 0.3)) { holdProgress = 0 }
        }
    }

    private func completeRecitation() {
        holding = false
        holdTimer?.invalidate()
        Haptics.success(enabled: settings.haptics)
        withAnimation(.easeInOut(duration: 0.5)) { showAmen = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            onComplete()
        }
    }
}

#Preview {
    OnboardingPrayer(onComplete: {})
        .environmentObject(AppState())
}
