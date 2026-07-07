import SwiftUI

/// Drives the full onboarding as a step machine.
/// Step order: carousel -> notifications -> conversation -> prayer -> personalized -> finishOnboarding()
struct OnboardingRootView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var settings: SettingsStore

    enum Step {
        case carousel
        case notifications
        case conversation
        case prayer
        case personalized
    }

    @State private var step: Step = OnboardingRootView.initialStep

    private static var initialStep: Step {
        #if DEBUG
        switch DebugRoute.obStep {
        case "notifications": return .notifications
        case "conversation":  return .conversation
        case "prayer":        return .prayer
        case "personalized":  return .personalized
        default:              return .carousel
        }
        #else
        return .carousel
        #endif
    }

    var body: some View {
        ZStack {
            switch step {
            case .carousel:
                OnboardingCarousel { advance(to: .notifications) }
                    .transition(.opacity)
            case .notifications:
                OnboardingNotifications { advance(to: .conversation) }
                    .transition(.opacity)
            case .conversation:
                OnboardingConversation { advance(to: .prayer) }
                    .transition(.opacity)
            case .prayer:
                OnboardingPrayer { advance(to: .personalized) }
                    .transition(.opacity)
            case .personalized:
                OnboardingPersonalized { app.finishOnboarding() }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: step)
    }

    private func advance(to next: Step) {
        Haptics.lightImpact(enabled: settings.haptics)
        withAnimation(.easeInOut(duration: 0.45)) { step = next }
    }
}

// MARK: - Notification permission (Step 2)

/// Faux iOS notification permission screen. Either button advances.
private struct OnboardingNotifications: View {
    let onContinue: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            ArtworkView(art: .sunset)
                .ignoresSafeArea()
            LinearGradient(
                colors: [
                    Color.black.opacity(0.45),
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.30)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    Text("Spiritual discipline,\nmade easier")
                        .font(.haven(40, .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.35), radius: 10, y: 4)

                    Text("Enable gentle reminders for your daily rhythm")
                        .font(.haven(21))
                        .foregroundStyle(.white.opacity(0.92))
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 3)
                        .padding(.horizontal, 28)
                }
                .padding(.top, 40)

                Spacer()

                // Faux alert card
                VStack(spacing: 0) {
                    VStack(spacing: 14) {
                        Text("\"\(Brand.appName)\" Would Like to Send You Notifications")
                            .font(.haven(20, .bold))
                            .foregroundStyle(Theme.brownDeep)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Notifications may include alerts, sounds, and icon badges. These can be configured in Settings.")
                            .font(.haven(16))
                            .foregroundStyle(Theme.brown.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 26)
                    .padding(.bottom, 22)

                    Rectangle()
                        .fill(Theme.brown.opacity(0.18))
                        .frame(height: 1)

                    HStack(spacing: 0) {
                        Button(action: onContinue) {
                            Text("Don't Allow")
                                .font(.haven(20))
                                .foregroundStyle(Theme.brown.opacity(0.55))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        Rectangle()
                            .fill(Theme.brown.opacity(0.18))
                            .frame(width: 1)
                        Button(action: onContinue) {
                            HStack(spacing: 8) {
                                Text("Allow")
                                    .font(.haven(21, .bold))
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundStyle(Theme.brownDeep)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(height: 66)
                }
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color(hex: "#F3E7DC"))
                )
                .fixedSize(horizontal: false, vertical: true)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                .shadow(color: .black.opacity(0.25), radius: 24, y: 12)
                .padding(.horizontal, 34)
                .scaleEffect(appeared ? 1 : 0.92)
                .opacity(appeared ? 1 : 0)

                // Upward arrow pointing at Allow
                Image(systemName: "arrow.up")
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 8, y: 3)
                    .padding(.top, 18)
                    .padding(.trailing, 40)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .opacity(appeared ? 1 : 0)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                appeared = true
            }
        }
    }
}

#Preview {
    OnboardingRootView()
        .environmentObject(AppState())
}
