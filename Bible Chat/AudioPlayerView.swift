//
//  AudioPlayerView.swift
//  Bible Chat  ·  "Haven" recreation
//
//  Full-screen dark "Creation" audio player with karaoke narration,
//  a scrubbing progress bar, and playback controls.
//

import SwiftUI
import Combine
import AVFoundation

/// Plays a bundled narration file (generated with the Voicebox/Kokoro TTS engine)
/// via AVAudioPlayer. Falls back to a silent simulated timeline when the audio
/// preference is off or no file is bundled for a story.
@MainActor
final class NarrationEngine: ObservableObject {
    private var player: AVAudioPlayer?
    var hasAudio: Bool { player != nil }
    var duration: Double { player?.duration ?? 0 }
    var currentTime: Double { player?.currentTime ?? 0 }
    var isFinished: Bool { guard let p = player else { return false }; return p.currentTime >= p.duration - 0.05 }

    func load(slug: String) {
        guard let url = Bundle.main.url(forResource: slug, withExtension: "m4a") else { player = nil; return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            let p = try AVAudioPlayer(contentsOf: url)
            p.enableRate = true
            p.prepareToPlay()
            player = p
        } catch { player = nil }
    }
    func play(rate: Float) { player?.rate = rate; player?.play() }
    func pause() { player?.pause() }
    func setRate(_ r: Float) { let wasPlaying = player?.isPlaying ?? false; player?.rate = r; if wasPlaying { player?.play() } }
    func seek(fraction f: Double) { guard let p = player else { return }; p.currentTime = max(0, min(f, 1)) * p.duration }
    func stop() { player?.stop(); player = nil; try? AVAudioSession.sharedInstance().setActive(false) }
}

struct AudioPlayerView: View {
    let story: Story

    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var engine = NarrationEngine()

    @State private var progress: Double = 0.0        // 0…1
    @State private var lineIndex: Int = 0
    @State private var speed: Double = 1.0
    @State private var showQueue = false
    @State private var showPassage = false

    // Drives both the scrubber and the karaoke line advance.
    private let tick = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

    /// Slug matching the generated audio filenames (lowercased, non-alphanumerics → "_").
    private var audioSlug: String {
        let mapped = story.title.lowercased().map { c -> Character in
            (c.isASCII && (c.isLetter || c.isNumber)) ? c : "_"
        }
        var s = String(mapped)
        while s.contains("__") { s = s.replacingOccurrences(of: "__", with: "_") }
        return s.trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }

    private var duration: Double { engine.hasAudio ? max(engine.duration, 1) : Double(max(story.durationSeconds, 1)) }
    private var elapsed: Double { progress * duration }
    private var remaining: Double { max(duration - elapsed, 0) }

    var body: some View {
        ZStack {
            // Full-bleed painterly background with strong dark overlay.
            ArtworkView(art: story.artwork)
                .overlay(Color.black.opacity(0.42))
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.35), .clear, .black.opacity(0.55)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, Theme.Space.screen)
                    .padding(.top, 4)

                titleBlock
                    .padding(.horizontal, Theme.Space.screen)
                    .padding(.top, 14)

                Spacer(minLength: 0)

                Text(story.reference.uppercased())
                    .font(.havenUI(15, .semibold))
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Theme.Space.screen)

                Spacer(minLength: 0)

                karaoke
                    .padding(.horizontal, Theme.Space.screen)
                    .padding(.bottom, 22)

                scrubber
                    .padding(.horizontal, Theme.Space.screen)

                controls
                    .padding(.horizontal, Theme.Space.screen)
                    .padding(.top, 18)
                    .padding(.bottom, 10)
            }
            .padding(.top, 8)
        }
        .onReceive(tick) { _ in advance() }
        .sheet(isPresented: $showQueue) { queueSheet }
        .sheet(isPresented: $showPassage) { passageSheet }
        .onAppear {
            if settings.audio {
                engine.load(slug: audioSlug)
                if app.isPlaying { engine.play(rate: Float(speed)) }
            }
        }
        .onChange(of: app.isPlaying) { _, playing in
            guard engine.hasAudio else { return }
            playing ? engine.play(rate: Float(speed)) : engine.pause()
        }
        .onDisappear { engine.stop() }
    }

    // MARK: - Queue / narration list sheet

    private var queueSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(story.narration.enumerated()), id: \.offset) { idx, line in
                        HStack(alignment: .firstTextBaseline, spacing: 14) {
                            Text("\(idx + 1)")
                                .font(.havenUI(14, .semibold))
                                .foregroundStyle(Theme.gold)
                                .frame(width: 24, alignment: .trailing)

                            Text(line)
                                .font(.haven(18, idx == lineIndex ? .semibold : .regular))
                                .foregroundStyle(idx == lineIndex ? Theme.ink : Theme.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(Theme.Space.screen)
            }
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle("Up Next")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showQueue = false }
                        .font(.havenUI(16, .semibold))
                        .foregroundStyle(Theme.ink)
                }
            }
        }
    }

    // MARK: - Read-the-passage sheet

    private var passageSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(story.reference.uppercased())
                        .font(.havenUI(14, .semibold))
                        .tracking(1.5)
                        .foregroundStyle(Theme.gold)

                    Text(story.narration.joined(separator: "\n\n"))
                        .font(.haven(20, .regular))
                        .foregroundStyle(Theme.ink)
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Theme.Space.screen)
            }
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle(story.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showPassage = false }
                        .font(.havenUI(16, .semibold))
                        .foregroundStyle(Theme.ink)
                }
            }
        }
    }

    // MARK: Top bar

    private var topBar: some View {
        ZStack {
            Text("BIBLE STORY")
                .font(.haven(14, .semibold))
                .tracking(2.5)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)

            HStack {
                CircleIconButton(
                    systemName: "chevron.left",
                    bg: Color.white.opacity(0.18),
                    fg: .white
                ) {
                    app.isPlaying = false
                    dismiss()
                }

                Spacer()

                CircleIconButton(
                    systemName: "book",
                    bg: Color.white.opacity(0.18),
                    fg: .white
                ) { showPassage = true }
            }
        }
    }

    // MARK: Title

    private var titleBlock: some View {
        Text(story.title)
            .font(.haven(26, .bold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // MARK: Karaoke narration

    /// A short window of narration: the current line plus the next couple, so the
    /// block sits in the lower third (matching the reference) instead of filling the screen.
    private var narrationWindow: [(Int, String)] {
        let start = lineIndex
        let end = min(start + 3, story.narration.count)
        return (start..<end).map { ($0, story.narration[$0]) }
    }

    private var karaoke: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(narrationWindow, id: \.0) { idx, line in
                Text(line)
                    .font(.haven(24, idx == lineIndex ? .bold : .regular))
                    .foregroundStyle(.white.opacity(idx == lineIndex ? 1.0 : 0.4))
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .bottomLeading)
        .animation(.easeInOut(duration: 0.3), value: lineIndex)
    }

    // MARK: Scrubber

    private var scrubber: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let w = geo.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.28))
                        .frame(height: 5)
                    Capsule()
                        .fill(Color.white)
                        .frame(width: max(0, min(w, w * progress)), height: 5)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 26, height: 26)
                        .shadow(color: .black.opacity(0.25), radius: 4, y: 1)
                        .offset(x: max(0, min(w - 26, w * progress - 13)))
                }
                .frame(height: 26)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { v in
                            progress = min(max(0, v.location.x / w), 1)
                            if engine.hasAudio { engine.seek(fraction: progress) }
                            syncLineToProgress()
                        }
                )
            }
            .frame(height: 26)

            HStack {
                Text(timeString(elapsed))
                Spacer()
                Text("-" + timeString(remaining))
            }
            .font(.havenUI(15, .medium))
            .foregroundStyle(.white.opacity(0.9))
        }
    }

    // MARK: Controls

    private var controls: some View {
        HStack {
            // Speed chip
            Button { cycleSpeed() } label: {
                Text(speedLabel)
                    .font(.havenUI(16, .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.18), in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            CircleIconButton(
                systemName: "gobackward.10",
                diameter: 56,
                bg: Color.white.opacity(0.18),
                fg: .white
            ) { skip(by: -10) }

            Spacer()

            // Large white play / pause
            Button {
                app.isPlaying.toggle()
            } label: {
                Image(systemName: app.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 82, height: 82)
                    .background(Color.white, in: Circle())
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 3)
            }
            .buttonStyle(.plain)

            Spacer()

            CircleIconButton(
                systemName: "goforward.10",
                diameter: 56,
                bg: Color.white.opacity(0.18),
                fg: .white
            ) { skip(by: 10) }

            Spacer()

            CircleIconButton(
                systemName: "list.bullet",
                diameter: 56,
                bg: .white,
                fg: Theme.ink
            ) { showQueue = true }
        }
    }

    // MARK: - Playback logic

    private var speedLabel: String {
        speed == 1.0 ? "1x" : (speed == 1.5 ? "1.5x" : "2x")
    }

    private func cycleSpeed() {
        speed = speed == 1.0 ? 1.5 : (speed == 1.5 ? 2.0 : 1.0)
        engine.setRate(Float(speed))
    }

    private func advance() {
        if engine.hasAudio {
            // Drive the scrubber + karaoke from real playback time.
            progress = min(engine.currentTime / duration, 1.0)
            syncLineToProgress()
            if engine.isFinished && app.isPlaying { app.isPlaying = false }
            return
        }
        guard app.isPlaying else { return }
        let step = (0.2 * speed) / duration
        progress = min(progress + step, 1.0)
        syncLineToProgress()
        if progress >= 1.0 { app.isPlaying = false }
    }

    private func syncLineToProgress() {
        let count = max(story.narration.count, 1)
        lineIndex = min(Int(progress * Double(count)), count - 1)
    }

    private func skip(by seconds: Double) {
        progress = min(max(0, progress + seconds / duration), 1)
        if engine.hasAudio { engine.seek(fraction: progress) }
        syncLineToProgress()
    }

    private func timeString(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

#Preview {
    AudioPlayerView(story: BibleData.creationStory)
        .environmentObject(AppState())
}
