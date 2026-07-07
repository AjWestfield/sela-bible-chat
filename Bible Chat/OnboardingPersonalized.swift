import SwiftUI

/// Step 5 — the personalized closing message on paper, ending with the app entry CTA.
struct OnboardingPersonalized: View {
    let onEnter: () -> Void
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var settings: SettingsStore

    @State private var revealed = 0     // number of paragraphs shown
    @State private var showButton = false

    private var paragraphs: [String] {
        [
            "\(app.displayName), I've personalized your \(Brand.appName) experience based on your thoughtful answers.",
            "You're about to embark on a transformative journey of faith, growth, and deeper connection with God.",
            "I look forward to walking alongside you.",
            "Are you ready to begin?"
        ]
    }

    var body: some View {
        ZStack {
            Theme.paper
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 30)

                BrandMark(size: 120)
                    .padding(.top, 10)

                Spacer()

                VStack(spacing: 26) {
                    ForEach(Array(paragraphs.enumerated()), id: \.offset) { idx, para in
                        Text(para)
                            .font(.haven(27))
                            .foregroundStyle(Theme.brownDeep)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .opacity(idx < revealed ? 1 : 0)
                            .offset(y: idx < revealed ? 0 : 8)
                    }
                }
                .padding(.horizontal, 28)

                Spacer()
                Spacer()

                HavenPrimaryButton(title: "Enter \(Brand.appName)") {
                    Haptics.mediumImpact(enabled: settings.haptics)
                    onEnter()
                }
                .padding(.horizontal, Theme.Space.screen)
                .padding(.bottom, 30)
                .opacity(showButton ? 1 : 0)
                .offset(y: showButton ? 0 : 16)
            }
        }
        .onAppear(perform: runReveal)
    }

    private func runReveal() {
        for i in 0..<paragraphs.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(i) * 0.9) {
                withAnimation(.easeOut(duration: 0.6)) { revealed = i + 1 }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + Double(paragraphs.count) * 0.9 + 0.3) {
            withAnimation(.easeOut(duration: 0.6)) { showButton = true }
        }
    }
}

#Preview {
    OnboardingPersonalized(onEnter: {})
        .environmentObject(AppState())
}
