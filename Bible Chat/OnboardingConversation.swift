import SwiftUI

/// Step 3 — conversational Q&A over the sky background.
/// A beat machine: each beat shows white serif prompt text, optionally an input or option rows.
struct OnboardingConversation: View {
    let onComplete: () -> Void
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var settings: SettingsStore

    private enum Beat: Int, CaseIterable {
        case greeting          // "Welcome, friend!" + companion line
        case askName           // name input
        case niceToMeet        // "It's nice to meet you, {NAME}!..."
        case fewQuestions      // "I have a few questions..."
        case answerThoughtfully
        case confidential
        case q1                // faith level options
        case q1Response
        case q2                // motivation options
        case q2Response
        case q3Intro           // "Last question, and this one is important..."
        case q3Input           // challenge input
        case q3Response         // empathetic reply
        case prayerCrafted     // "I've crafted a prayer for you, {NAME}."
    }

    @State private var beat: Beat = .greeting
    @State private var nameField = ""
    @State private var challengeField = ""
    @State private var visible = false
    @State private var activePrompt = ""
    @State private var displayedPrompt = ""
    @State private var streamComplete = false
    @State private var streamTask: Task<Void, Never>? = nil
    @State private var autoAdvanceTask: Task<Void, Never>? = nil
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            HavenSkyBackground()

            // Tap-to-advance layer for text-only beats
            if isTapAdvance {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { handleAdvanceTap() }
            }

            VStack(alignment: .leading, spacing: 22) {
                Spacer()

                content
                    .opacity(visible ? 1 : 0)
                    .offset(y: visible ? 0 : 10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if isTapAdvance { handleAdvanceTap() }
                    }

                Spacer()

            }
            .padding(.horizontal, 28)
        }
        .onAppear { reveal() }
        .onChange(of: beat) { _, _ in reveal() }
        .onDisappear {
            streamTask?.cancel()
            autoAdvanceTask?.cancel()
        }
    }

    // MARK: - Beat content

    @ViewBuilder private var content: some View {
        switch beat {
        case .greeting:
            line(promptText)
        case .askName:
            VStack(alignment: .leading, spacing: 28) {
                line(promptText)
                inputRow(placeholder: "Your first name...", text: $nameField) {
                    submitName()
                }
            }
        case .niceToMeet:
            line(promptText)
        case .fewQuestions:
            line(promptText)
        case .answerThoughtfully:
            line(promptText)
        case .confidential:
            line(promptText)
        case .q1:
            questionWithOptions(
                promptText,
                options: FaithLevel.allCases.map { ($0.rawValue, $0) },
                selected: app.faithLevel
            ) { level in
                Haptics.lightImpact(enabled: settings.haptics)
                app.faithLevel = level
                advance(feedback: false)
            }
        case .q1Response:
            line(promptText)
        case .q2:
            questionWithOptions(
                promptText,
                options: Motivation.allCases.map { ($0.rawValue, $0) },
                selected: app.motivation
            ) { m in
                Haptics.lightImpact(enabled: settings.haptics)
                app.motivation = m
                advance(feedback: false)
            }
        case .q2Response:
            line(promptText)
        case .q3Intro:
            line(promptText)
        case .q3Input:
            VStack(alignment: .leading, spacing: 28) {
                line(promptText)
                inputRow(placeholder: "What's weighing on you?", text: $challengeField) {
                    submitChallenge()
                }
            }
        case .q3Response:
            line(promptText)
        case .prayerCrafted:
            line(promptText)
        }
    }

    // MARK: - Building blocks

    private func line(_ text: String) -> some View {
        let visibleText = text == activePrompt ? displayedPrompt : text

        return ZStack(alignment: .topLeading) {
            Text(text)
                .font(.haven(30))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(0)
                .accessibilityHidden(true)

            Text(visibleText)
                .font(.haven(30))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 3)
        }
        .accessibilityLabel(text)
    }

    private func inputRow(placeholder: String, text: Binding<String>, submit: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 14) {
                TextField("", text: text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.55)))
                    .font(.haven(24))
                    .foregroundStyle(.white)
                    .tint(.white)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit(submit)

                Button(action: submit) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(canSubmit(text.wrappedValue) ? 1 : 0.4))
                }
                .disabled(!canSubmit(text.wrappedValue))
            }
            Rectangle()
                .fill(.white.opacity(0.5))
                .frame(height: 1)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { focused = true }
        }
    }

    private func questionWithOptions<T: Equatable>(
        _ question: String,
        options: [(String, T)],
        selected: T?,
        onSelect: @escaping (T) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 28) {
            line(question)
            VStack(alignment: .leading, spacing: 22) {
                ForEach(Array(options.enumerated()), id: \.offset) { _, opt in
                    Button {
                        onSelect(opt.1)
                    } label: {
                        Text(opt.0)
                            .font(.haven(25))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, selected != nil && selected! == opt.1 ? 8 : 0)
                            .padding(.horizontal, selected != nil && selected! == opt.1 ? 12 : 0)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(selected != nil && selected! == opt.1
                                          ? Color.white.opacity(0.18) : Color.clear)
                            )
                    }
                }
            }
        }
    }

    // MARK: - Flow

    private var isTapAdvance: Bool {
        switch beat {
        case .askName, .q1, .q2, .q3Input:
            return false
        default:
            return true
        }
    }

    private func canSubmit(_ s: String) -> Bool {
        !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func submitName() {
        let trimmed = nameField.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Haptics.lightImpact(enabled: settings.haptics)
        app.name = trimmed
        focused = false
        advance(feedback: false)
    }

    private func submitChallenge() {
        let trimmed = challengeField.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Haptics.lightImpact(enabled: settings.haptics)
        app.challenge = trimmed
        focused = false
        advance(feedback: false)
    }

    private func reveal() {
        streamTask?.cancel()
        autoAdvanceTask?.cancel()
        let prompt = promptText
        activePrompt = prompt
        displayedPrompt = ""
        streamComplete = prompt.isEmpty
        visible = false
        withAnimation(.easeOut(duration: 0.7)) { visible = true }
        guard !prompt.isEmpty else { return }

        let hapticsEnabled = settings.haptics
        let beatToReveal = beat
        streamTask = Task {
            let characters = Array(prompt)
            var built = ""
            var hapticIndex = 0

            for character in characters {
                if Task.isCancelled { return }
                built.append(character)
                hapticIndex += 1

                await MainActor.run {
                    displayedPrompt = built
                    if shouldTickHaptic(for: character, index: hapticIndex) {
                        Haptics.streamTick(enabled: hapticsEnabled)
                    }
                }

                try? await Task.sleep(nanoseconds: streamDelay(after: character))
            }

            await MainActor.run {
                displayedPrompt = prompt
                streamComplete = true
                Haptics.selection(enabled: hapticsEnabled)
                scheduleAutoAdvance(for: beatToReveal)
            }
        }
    }

    private func handleAdvanceTap() {
        autoAdvanceTask?.cancel()

        if !streamComplete {
            finishStream()
            Haptics.selection(enabled: settings.haptics)
            scheduleAutoAdvance(for: beat)
            return
        }

        advance()
    }

    private func advance(feedback: Bool = true) {
        autoAdvanceTask?.cancel()
        streamTask?.cancel()

        if feedback {
            Haptics.selection(enabled: settings.haptics)
        }

        let next = beat.rawValue + 1
        guard let nextBeat = Beat(rawValue: next) else {
            Haptics.success(enabled: settings.haptics)
            onComplete()
            return
        }
        visible = false
        beat = nextBeat
    }

    private func finishStream() {
        streamTask?.cancel()
        displayedPrompt = activePrompt
        streamComplete = true
        visible = true
    }

    private var promptText: String {
        switch beat {
        case .greeting:
            return "Welcome, friend!\nI'm \(Brand.companionName), your Scripture companion."
        case .askName:
            return "What can I call you?"
        case .niceToMeet:
            return "It's nice to meet you, \(app.displayName)! Thank you for being here."
        case .fewQuestions:
            return "I have a few questions to help shape your daily guidance."
        case .answerThoughtfully:
            return "Answer honestly. Your plan will adapt around what you share."
        case .confidential:
            return "Everything you share is completely confidential."
        case .q1:
            return "First, how would you describe your relationship with faith?"
        case .q1Response:
            return app.faithLevel?.response ?? ""
        case .q2:
            return "What's making you want to explore faith more right now?"
        case .q2Response:
            return app.motivation?.response ?? ""
        case .q3Intro:
            return "Last question, and this one is important..."
        case .q3Input:
            return "What are your biggest challenges in life right now? Feel free to share as much as you'd like."
        case .q3Response:
            return "Thank you for sharing that. You do not have to carry it alone. We'll shape your guidance around hope, patience, and steady next steps for what you're facing."
        case .prayerCrafted:
            return "I've crafted a prayer for you, \(app.displayName)."
        }
    }

    private func streamDelay(after character: Character) -> UInt64 {
        if ".!?".contains(character) { return 140_000_000 }
        if ",;:".contains(character) { return 80_000_000 }
        if character == "\n" { return 110_000_000 }
        if character == " " { return 24_000_000 }
        return 18_000_000
    }

    private func shouldTickHaptic(for character: Character, index: Int) -> Bool {
        guard character != " ", character != "\n" else { return false }
        if ".!?".contains(character) { return true }
        return index % 4 == 0
    }

    private func scheduleAutoAdvance(for streamedBeat: Beat) {
        guard shouldAutoAdvance(streamedBeat), beat == streamedBeat else { return }

        autoAdvanceTask?.cancel()
        autoAdvanceTask = Task {
            try? await Task.sleep(nanoseconds: autoAdvanceDelay(for: streamedBeat))
            if Task.isCancelled { return }
            await MainActor.run {
                guard beat == streamedBeat, streamComplete else { return }
                advance()
            }
        }
    }

    private func shouldAutoAdvance(_ beat: Beat) -> Bool {
        switch beat {
        case .askName, .q1, .q2, .q3Input:
            return false
        default:
            return true
        }
    }

    private func autoAdvanceDelay(for beat: Beat) -> UInt64 {
        switch beat {
        case .greeting:
            return 900_000_000
        case .niceToMeet, .q1Response, .q2Response, .q3Response:
            return 1_150_000_000
        case .prayerCrafted:
            return 900_000_000
        default:
            return 800_000_000
        }
    }
}

#Preview {
    OnboardingConversation(onComplete: {})
        .environmentObject(AppState())
}
