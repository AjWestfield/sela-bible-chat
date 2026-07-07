//
//  ChatView.swift
//  Bible Chat  ·  "Haven" recreation
//
//  Full-screen conversational chat with Sela. Opened with a ChatSeed
//  (topic, daily verse, or an existing conversation). Streams warm,
//  biblically-themed replies token-by-token and persists the thread.
//

import SwiftUI

struct ChatView: View {
    let seed: ChatSeed

    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var messages: [ChatMessage] = []
    @State private var input: String = ""
    @State private var isStreaming = false
    @State private var streamTask: Task<Void, Never>? = nil
    @State private var existingConversationID: UUID? = nil
    @State private var showHistory = false

    // Verse ref shown inline in the opening companion message (dailyVerse seed).
    private var openingVerseRef: String? {
        if case let .dailyVerse(v) = seed { return v.reference }
        return nil
    }

    private var navTitle: String {
        switch seed {
        case .topic(let t): return t.title
        case .dailyVerse: return "Daily Verse " + shortDate()
        case .existing(let c): return c.title
        }
    }

    private var suggestions: [String] {
        switch seed {
        case .dailyVerse:
            return ["What's the core message here?",
                    "What makes this verse significant?",
                    "What's a modern example of this?"]
        case .topic(let t): return t.prompts
        case .existing(let c): return c.messages.isEmpty ? [] : []
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(Theme.hairline)
            messageScroll
            suggestionRow
            inputBar
        }
        .background(Theme.paper.ignoresSafeArea())
        .onAppear(perform: bootstrap)
        .onDisappear(perform: persist)
        .sheet(isPresented: $showHistory) {
            ChatHistorySheet(conversations: app.conversations) { convo in
                load(convo)
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            CircleIconButton(systemName: "chevron.left") { dismiss() }
            Spacer()
            Text(navTitle)
                .font(.havenSubheading)
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
            Spacer()
            CircleIconButton(systemName: "clock.arrow.circlepath") { showHistory = true }
        }
        .padding(.horizontal, Theme.Space.screen)
        .padding(.bottom, 12)
    }

    // MARK: Messages

    private var messageScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ForEach(Array(messages.enumerated()), id: \.element.id) { idx, msg in
                        messageRow(msg, isFirst: idx == 0)
                            .id(msg.id)
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, Theme.Space.screen)
                .padding(.top, 18)
                .padding(.bottom, 8)
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
            .onChange(of: messages.last?.text) { _, _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    @ViewBuilder
    private func messageRow(_ msg: ChatMessage, isFirst: Bool) -> some View {
        switch msg.role {
        case .haven:
            VStack(alignment: .leading, spacing: 8) {
                Text("\(Brand.companionName):")
                    .font(.haven(20))
                    .foregroundStyle(Theme.inkFaint)
                if isFirst, let ref = openingVerseRef {
                    // Rich opening line with inline verse tag.
                    havenOpeningVerseLine(ref: ref, text: msg.text)
                } else {
                    Text(msg.text)
                        .font(.haven(21))
                        .foregroundStyle(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .user:
            HStack {
                Spacer(minLength: 40)
                HavenChip(text: msg.text)
            }
        }
    }

    /// "Today's wisdom from [Hebrews 13:8]: "..." How could you..."
    private func havenOpeningVerseLine(ref: String, text: String) -> some View {
        var full = AttributedString("Today's wisdom from ")
        full.font = .haven(21); full.foregroundColor = Theme.ink
        var refRun = AttributedString(" \(ref) ")
        refRun.font = .havenUI(15, .semibold); refRun.foregroundColor = Theme.brown
        var bodyRun = AttributedString(text)
        bodyRun.font = .haven(21); bodyRun.foregroundColor = Theme.ink
        full.append(refRun); full.append(bodyRun)
        return Text(full).fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Suggestion chips

    @ViewBuilder
    private var suggestionRow: some View {
        if !suggestions.isEmpty && !isStreaming && messages.filter({ $0.role == .user }).isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(suggestions, id: \.self) { s in
                        Button { send(s) } label: {
                            HavenChip(text: s, filled: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Space.screen)
                .padding(.vertical, 10)
            }
        }
    }

    // MARK: Input bar

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask me anything...", text: $input, axis: .vertical)
                .font(.haven(19))
                .foregroundStyle(Theme.ink)
                .tint(Theme.brown)
                .lineLimit(1...4)
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 26))
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(Theme.hairline, lineWidth: 1))

            Button {
                if isStreaming { stopStreaming() }
                else { send(input) }
            } label: {
                Image(systemName: isStreaming ? "stop.fill" : "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(canSend || isStreaming ? Theme.brown : Theme.inkFaint, in: Circle())
            }
            .buttonStyle(.plain)
            .disabled(!canSend && !isStreaming)
        }
        .padding(.horizontal, Theme.Space.screen)
        .padding(.vertical, 12)
    }

    private var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: Behaviour

    private func bootstrap() {
        guard messages.isEmpty else { return }
        switch seed {
        case .existing(let convo):
            existingConversationID = convo.id
            messages = convo.messages
        case .dailyVerse(let v):
            // The visible text after the ref tag.
            let body = ": \"\(v.text)\" How could you intentionally apply this teaching in your daily choices?"
            messages = [ChatMessage(role: .haven, text: body, verseRef: v.reference)]
        case .topic(let t):
            messages = [ChatMessage(role: .haven,
                                    text: "Peace be with you. I'm here to walk with you through \(t.title.lowercased()) with Scripture and prayer. What's on your heart today?")]
        }
    }

    private func send(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isStreaming else { return }
        input = ""
        messages.append(ChatMessage(role: .user, text: trimmed))
        streamReply()
    }

    private func streamReply() {
        let conversationContext = messages
        let replyIndex = messages.count
        messages.append(ChatMessage(role: .haven, text: ""))
        isStreaming = true

        streamTask = Task {
            do {
                let full = try await GeminiChatService().reply(to: conversationContext, appState: app)
                await reveal(full, at: replyIndex)
            } catch {
                await MainActor.run {
                    if messages.indices.contains(replyIndex) {
                        messages[replyIndex].text = chatErrorMessage(for: error)
                    }
                    isStreaming = false
                }
            }
        }
    }

    private func reveal(_ full: String, at replyIndex: Int) async {
        let words = full.split(separator: " ", omittingEmptySubsequences: false)
        var built = ""
        for (i, w) in words.enumerated() {
            if Task.isCancelled { break }
            built += (i == 0 ? "" : " ") + w
            await MainActor.run {
                if messages.indices.contains(replyIndex) {
                    messages[replyIndex].text = built
                }
            }
            try? await Task.sleep(nanoseconds: 45_000_000)
        }
        await MainActor.run {
            if messages.indices.contains(replyIndex), messages[replyIndex].text.isEmpty {
                messages[replyIndex].text = full
            }
            isStreaming = false
        }
    }

    private func stopStreaming() {
        streamTask?.cancel()
        isStreaming = false
    }

    private func chatErrorMessage(for error: Error) -> String {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        return "I couldn't connect to Gemini just now. \(message)"
    }

    /// Load a saved conversation from the history sheet into the current chat.
    private func load(_ convo: Conversation) {
        // Save whatever is on screen before switching threads.
        persist()
        stopStreaming()
        existingConversationID = convo.id
        messages = convo.messages
        input = ""
        showHistory = false
    }

    private func persist() {
        streamTask?.cancel()
        guard messages.count > 0 else { return }
        // Only save if there's genuine back-and-forth beyond the seed opener.
        let hasUser = messages.contains { $0.role == .user }
        guard hasUser || existingConversationID != nil else { return }

        if let id = existingConversationID,
           let idx = app.conversations.firstIndex(where: { $0.id == id }) {
            app.conversations[idx].messages = messages
        } else {
            let convo = Conversation(title: navTitle, subtitle: "Today", messages: messages)
            app.conversations.insert(convo, at: 0)
        }
    }

    private func shortDate() -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: Date())
    }
}

// MARK: - History sheet

/// Lists persisted conversations. Tapping a row loads it into the chat.
private struct ChatHistorySheet: View {
    let conversations: [Conversation]
    let onSelect: (Conversation) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if conversations.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(conversations) { convo in
                                Button { onSelect(convo) } label: {
                                    row(convo)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, Theme.Space.screen)
                        .padding(.vertical, 18)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(.havenUI(16, .semibold))
                        .foregroundStyle(Theme.brown)
                }
            }
        }
    }

    private func row(_ convo: Conversation) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(convo.title)
                    .font(.haven(19, .medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Text(convo.subtitle)
                    .font(.havenUI(13))
                    .foregroundStyle(Theme.inkFaint)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.inkFaint)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(Theme.hairline, lineWidth: 1))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(Theme.inkFaint)
            Text("No conversations yet")
                .font(.haven(19, .medium))
                .foregroundStyle(Theme.inkSoft)
            Text("Your saved chats with \(Brand.companionName) will appear here.")
                .font(.havenUI(14))
                .foregroundStyle(Theme.inkFaint)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    ChatView(seed: .dailyVerse(BibleData.dailyVerse))
        .environmentObject(AppState())
}
