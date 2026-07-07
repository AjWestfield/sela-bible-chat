import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.openURL) private var openURL

    @State private var isProcessing = false
    @State private var showStoreKit = false
    @State private var showSuccess = false
    @State private var showRestore = false
    @State private var restoreSucceeded = false

    private let contentWidth: CGFloat = 336

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()

            VStack(spacing: 0) {
                topArtwork
                Spacer(minLength: 0)
            }
            .ignoresSafeArea(edges: .top)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    paywallHeader
                    offerCard
                    benefits
                }
                .frame(maxWidth: contentWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.top, 54)
                .padding(.bottom, 170)
            }
            .safeAreaInset(edge: .bottom) {
                bottomPurchaseBar
            }

            if showStoreKit {
                storeKitCard
                    .transition(.opacity)
            }
        }
        .alert("You're all set.", isPresented: $showSuccess) {
            Button("OK") { app.completePurchase() }
        } message: {
            Text("Your purchase was successful.")
        }
        .alert("Restore Purchases", isPresented: $showRestore) {
            Button("OK") {}
        } message: {
            Text(restoreSucceeded
                 ? "Your subscription has been restored."
                 : "No active subscription found.")
        }
    }

    private var topArtwork: some View {
        ArtworkView(art: .meadow)
            .frame(height: 172)
            .clipped()
            .overlay(
                LinearGradient(
                    colors: [
                        Theme.paper.opacity(0.0),
                        Theme.paper.opacity(0.78),
                        Theme.paper
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private var paywallHeader: some View {
        VStack(spacing: 12) {
            BrandMark(size: 58)

            VStack(spacing: 7) {
                Text("\(Brand.appName) Plus")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.brown)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text("Start your free week")
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)

                Text("Personalized Scripture, prayer, and guidance for \(app.displayName).")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var offerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("7 days free")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text("Then $6.99 per week")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.inkSoft)
                }

                Spacer(minLength: 8)

                Text("Selected")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.brown)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Theme.goldPale.opacity(0.75), in: Capsule())
            }

            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.sage)

                Text("No charge today. Cancel anytime.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(Theme.inkSoft)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.brown.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
    }

    private var benefits: some View {
        VStack(spacing: 8) {
            PaywallBenefitRow(
                icon: "calendar.badge.checkmark",
                title: "Personal daily plan",
                detail: "Scripture, prayer, and reflection shaped around your answers."
            )
            PaywallBenefitRow(
                icon: "message.fill",
                title: "Guided Bible chat",
                detail: "Ask questions and get faithful, contextual guidance."
            )
            PaywallBenefitRow(
                icon: "sparkles",
                title: "Verse reminders",
                detail: "Keep a daily verse close without breaking your rhythm."
            )
        }
    }

    private var bottomPurchaseBar: some View {
        VStack(spacing: 9) {
            primaryAction

            Text("7-day free trial, then $6.99 per week")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.inkSoft)
                .lineLimit(1)
                .minimumScaleFactor(0.88)
                .frame(maxWidth: .infinity, alignment: .center)

            footerLinks
        }
        .frame(maxWidth: contentWidth)
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background {
            Theme.paper
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Theme.hairline.opacity(0.85))
                .frame(height: 1)
        }
        .shadow(color: .black.opacity(0.04), radius: 14, y: -4)
    }

    private var primaryAction: some View {
        Group {
            if isProcessing {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                    Spacer()
                }
                .frame(height: 56)
                .background(Theme.brown, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                Button(action: startTrial) {
                    HStack(spacing: 8) {
                        Text("Start free trial")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(hex: "#FBF6EC"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Theme.brown, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var footerLinks: some View {
        HStack(spacing: 30) {
            Button("Terms") {
                openURL(URL(string: "https://example.com/terms")!)
            }
            Button("Privacy") {
                openURL(URL(string: "https://example.com/privacy")!)
            }
            Button("Restore") { restorePurchases() }
        }
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(Theme.inkFaint)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var storeKitCard: some View {
        StoreKitConfirmationCard(
            onDismiss: {
                withAnimation { showStoreKit = false }
                isProcessing = false
            },
            onConfirm: confirmPurchase
        )
    }

    private func startTrial() {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation { showStoreKit = true }
        }
    }

    private func confirmPurchase() {
        withAnimation { showStoreKit = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isProcessing = false
            showSuccess = true
        }
    }

    private func restorePurchases() {
        let ok = app.restorePurchases()
        restoreSucceeded = ok
        showRestore = true
    }
}

private struct PaywallBenefitRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.brown)
                .frame(width: 30, height: 30)
                .background(Theme.cardSoft, in: RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.ink)

                Text(detail)
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundStyle(Theme.inkSoft)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(11)
        .background(Theme.card.opacity(0.78), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.hairline.opacity(0.85), lineWidth: 1)
        )
    }
}

private struct StoreKitConfirmationCard: View {
    let onDismiss: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()

            VStack {
                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("App Store")
                            .font(.havenUI(24, .bold))
                            .foregroundStyle(.white)

                        Spacer()

                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(.white.opacity(0.4))
                            .onTapGesture(perform: onDismiss)
                    }
                    .padding(.bottom, 18)

                    HStack(alignment: .top, spacing: 14) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.white)
                            .frame(width: 58, height: 58)
                            .overlay(
                                Image(systemName: "hands.and.sparkles.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Theme.brown)
                            )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Unlimited")
                                .font(.havenUI(19, .semibold))
                                .foregroundStyle(.white)

                            Text(Brand.productLine)
                                .font(.havenUI(15))
                                .foregroundStyle(.white.opacity(0.7))

                            Text("Subscription")
                                .font(.havenUI(15))
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()
                    }
                    .padding(.vertical, 16)

                    Divider().overlay(.white.opacity(0.15))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("1-week free trial")
                            .font(.havenUI(19, .semibold))
                            .foregroundStyle(.white)

                        Text("Starting today")
                            .font(.havenUI(15))
                            .foregroundStyle(.white.opacity(0.6))

                        Text("$6.99 per week")
                            .font(.havenUI(19, .semibold))
                            .foregroundStyle(.white)
                            .padding(.top, 8)

                        Text("After the 7-day trial")
                            .font(.havenUI(15))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.vertical, 16)

                    Divider().overlay(.white.opacity(0.15))

                    Text("No commitment. Cancel anytime in Settings.")
                        .font(.havenUI(14))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.vertical, 14)

                    Button(action: onConfirm) {
                        Text("Double Click to Subscribe")
                            .font(.havenUI(18, .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.blue, in: Capsule())
                    }
                    .padding(.top, 4)
                }
                .padding(22)
                .background(Color(hex: "#1C1C1E"), in: .rect(topLeadingRadius: 24, topTrailingRadius: 24))
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

#Preview {
    PaywallView()
        .environmentObject(AppState())
}
