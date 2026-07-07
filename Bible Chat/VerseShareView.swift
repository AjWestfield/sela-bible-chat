import SwiftUI

struct VerseShareView: View {
    @EnvironmentObject private var app: AppState

    /// Shareable verse string built from the same verse the view displays.
    private var shareText: String {
        "\u{201C}" + BibleData.dailyVerse.text + "\u{201D}\n— " + BibleData.dailyVerse.reference
    }

    var body: some View {
        ZStack {
            // Full-bleed oil-painting meadow field
            ArtworkView(art: .meadow)
                .ignoresSafeArea()
            LinearGradient(colors: [.black.opacity(0.35), .black.opacity(0.12), .black.opacity(0.45)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Full-screen tap target (anywhere except the Share button) -> continue
            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture { app.enterMainApp() }

            VStack(spacing: 0) {
                Text(Brand.appName)
                    .font(.haven(30, .regular))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 2)
                    .padding(.top, 8)

                Spacer()

                // Centered white serif verse
                VStack(spacing: 30) {
                    Text("\u{201C}" + BibleData.dailyVerse.text + "\u{201D}")
                        .font(.haven(38, .regular))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .shadow(color: .black.opacity(0.35), radius: 12, y: 3)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(BibleData.dailyVerse.reference.uppercased())
                        .font(.haven(19, .regular))
                        .tracking(2.5)
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.35), radius: 8, y: 2)
                }
                .padding(.horizontal, 34)

                Spacer()

                // Share pill + caption
                VStack(spacing: 18) {
                    ShareLink(item: shareText) {
                        HStack(spacing: 12) {
                            Text("Share to story")
                                .font(.haven(24, .regular))
                                .foregroundStyle(.white)
                            Image(systemName: "cross.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(
                            .ultraThinMaterial.opacity(0.9),
                            in: RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous)
                                .fill(.white.opacity(0.12))
                        )
                    }
                    .buttonStyle(.plain)

                    Text("Or, tap anywhere to continue")
                        .font(.haven(19, .regular))
                        .foregroundStyle(.white.opacity(0.85))
                        .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
                }
                .padding(.horizontal, 26)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    VerseShareView()
        .environmentObject(AppState())
}
