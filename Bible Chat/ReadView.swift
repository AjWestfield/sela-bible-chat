import SwiftUI

struct ReadView: View {
    @EnvironmentObject private var app: AppState
    @EnvironmentObject private var settings: SettingsStore

    @State private var book: BibleBook = BibleData.book(named: "Genesis")
    @State private var chapter: Int = 1
    @State private var fontScale: Double = 1.0

    @State private var showBookPicker = false
    @State private var showChapterPicker = false
    @State private var showFontSettings = false

    @State private var menuVerse: Int? = nil   // verse number the menu is open for

    // Verse actions
    @State private var chatSeed: ChatSeed? = nil          // drives the Interpret-verse chat cover
    @State private var shareRef: VerseRefItem? = nil        // drives the Share sheet
    @State private var noteRef: VerseRefItem? = nil         // drives the Add-note sheet
    @State private var noteDraft: String = ""

    /// Per-verse notes, keyed by verse reference (persisted).
    @AppStorage("sela.verseNotes") private var notesData: Data = Data()
    /// Per-verse highlight colour names, keyed by verse reference (persisted).
    @AppStorage("sela.verseHighlights") private var highlightsData: Data = Data()
    /// Reader typeface choice (0 = serif, 1 = rounded, 2 = sans) — set in FontSettingsSheet.
    @AppStorage("sela.readerFont") private var readerFontChoice: Int = 0

    private var verses: [String] {
        BibleData.verses(book: book.name, chapter: chapter)
    }

    /// Reference string for the whole chapter (used by the bookmark FAB).
    private var currentRef: String { "\(book.name) \(chapter)" }

    /// Reference string for a specific verse, e.g. "Genesis 1:1".
    private func ref(for number: Int) -> String { "\(book.name) \(chapter):\(number)" }

    // Decoded [ref: value] dictionaries backed by @AppStorage blobs.
    private var notes: [String: String] {
        get { (try? JSONDecoder().decode([String: String].self, from: notesData)) ?? [:] }
    }
    private func setNote(_ text: String, for ref: String) {
        var dict = notes
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { dict[ref] = nil } else { dict[ref] = trimmed }
        notesData = (try? JSONEncoder().encode(dict)) ?? notesData
    }

    private var highlights: [String: String] {
        get { (try? JSONDecoder().decode([String: String].self, from: highlightsData)) ?? [:] }
    }
    private func setHighlight(_ name: String?, for ref: String) {
        var dict = highlights
        dict[ref] = name
        highlightsData = (try? JSONEncoder().encode(dict)) ?? highlightsData
    }

    /// Wrap the chat seed so `fullScreenCover(item:)` can identify it.
    private var chatSeedItem: Binding<ReadChatSeedItem?> {
        Binding(
            get: { chatSeed.map(ReadChatSeedItem.init) },
            set: { chatSeed = $0?.seed }
        )
    }

    var body: some View {
        ZStack {
            Theme.paperDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, Theme.Space.screen)
                    .padding(.top, 8)
                    .padding(.bottom, 10)

                versesScroll
            }

            floatingControls
        }
        .sheet(isPresented: $showBookPicker) {
            BookPickerSheet(book: $book, chapter: $chapter)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showChapterPicker) {
            ChapterPickerSheet(book: book, chapter: $chapter)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showFontSettings) {
            FontSettingsSheet(fontScale: $fontScale)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.hidden)
        }
        .fullScreenCover(item: chatSeedItem) { item in
            ChatView(seed: item.seed)
                .environmentObject(app)
                .environmentObject(settings)
        }
        .sheet(item: $shareRef) { item in
            VerseShareSheet(text: item.text, reference: item.ref)
                .presentationDetents([.height(220)])
        }
        .sheet(item: $noteRef) { item in
            noteEditor(for: item)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: Add-note editor

    private func noteEditor(for item: VerseRefItem) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text(item.ref)
                    .font(.haven(20, .semibold))
                    .foregroundStyle(Theme.ink)
                Text(item.text)
                    .font(.haven(16))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                TextEditor(text: $noteDraft)
                    .font(.haven(17))
                    .foregroundStyle(Theme.ink)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 160)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                                    .stroke(Theme.hairline, lineWidth: 1)
                            )
                    )
                Spacer(minLength: 0)
            }
            .padding(Theme.Space.screen)
            .background(Theme.paper.ignoresSafeArea())
            .navigationTitle("Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { noteRef = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        setNote(noteDraft, for: item.ref)
                        Haptics.success(enabled: settings.haptics)
                        noteRef = nil
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack(spacing: 8) {
            Button { showBookPicker = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Theme.brown)
                    Text(book.name)
                        .font(.haven(20, .semibold))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                        .fill(Color.white)
                )
            }
            .buttonStyle(.plain)

            Button { showChapterPicker = true } label: {
                Text("\(chapter)")
                    .font(.haven(20, .semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(minWidth: 30)
                    .padding(.horizontal, 14)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                            .fill(Color.white)
                    )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            Button { showFontSettings = true } label: {
                Text("Aa")
                    .font(.haven(19, .semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 50, height: 50)
                    .background(Circle().fill(Color.white))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Verses

    private var versesScroll: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(verses.enumerated()), id: \.offset) { idx, text in
                    verseParagraph(number: idx + 1, text: text)
                }
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
    }

    /// The reader body typeface, driven by the choice in FontSettingsSheet.
    private func readerFont(_ size: CGFloat) -> Font {
        switch readerFontChoice {
        case 2:  return .havenUI(size, .regular)                       // sans (SF)
        case 1:  return .system(size: size, weight: .regular, design: .rounded)
        default: return .haven(size, .regular)                        // serif (New York)
        }
    }

    /// Verse number (gold, small) + verse text (ink) as one wrapping paragraph.
    private func verseAttributed(number: Int, text: String) -> AttributedString {
        var attr = AttributedString("\(number) ")
        attr.font = .haven(13, .semibold)
        attr.foregroundColor = Theme.gold
        var body = AttributedString(text)
        body.font = readerFont(20 * fontScale)
        body.foregroundColor = Theme.ink
        attr.append(body)
        return attr
    }

    @ViewBuilder
    private func verseParagraph(number: Int, text: String) -> some View {
        let tint = highlightColor(named: highlights[ref(for: number)])
        let hasNote = notes[ref(for: number)]?.isEmpty == false

        let paragraph = Text(verseAttributed(number: number, text: text))
            .lineSpacing(10)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)

        Group {
            if let tint {
                paragraph
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                            .fill(tint)
                            .shadow(color: Theme.ink.opacity(0.05), radius: 12, y: 4)
                    )
                    .padding(.vertical, 12)
            } else {
                paragraph
                    .padding(.vertical, 14)
            }
        }
        .overlay(alignment: .topTrailing) {
            if hasNote {
                Image(systemName: "note.text")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.brown)
                    .padding(.top, 4)
            }
        }
        .contentShape(Rectangle())
        .overlay(alignment: .topLeading) {
            if menuVerse == number {
                verseMenu(number: number, text: text)
                    .offset(y: 46)
                    .zIndex(10)
            }
        }
        .onLongPressGesture {
            withAnimation(.easeOut(duration: 0.14)) {
                menuVerse = (menuVerse == number) ? nil : number
            }
        }
    }

    // MARK: Verse menu popover

    private func verseMenu(number: Int, text: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            menuRow("doc.on.doc", "Copy verse") {
                UIPasteboard.general.string = "\(text) (\(book.name) \(chapter):\(number))"
                closeMenu()
            }
            menuRow("paperplane", "Interpret verse") {
                let r = ref(for: number)
                chatSeed = .dailyVerse(Verse(text: text, reference: r))
                Haptics.lightImpact(enabled: settings.haptics)
                closeMenu()
            }
            menuRow("square.and.arrow.up", "Share verse") {
                shareRef = VerseRefItem(ref: ref(for: number), text: text)
                closeMenu()
            }
            menuRow(app.isSaved(ref(for: number)) ? "heart.fill" : "heart",
                    app.isSaved(ref(for: number)) ? "Saved" : "Save verse") {
                app.toggleSaved(ref(for: number))
                Haptics.success(enabled: settings.haptics)
                closeMenu()
            }
            menuRow("square.and.pencil",
                    (notes[ref(for: number)]?.isEmpty == false) ? "Edit note" : "Add note") {
                let r = ref(for: number)
                noteDraft = notes[r] ?? ""
                noteRef = VerseRefItem(ref: r, text: text)
                closeMenu()
            }

            Divider()
                .overlay(Theme.hairline)
                .padding(.horizontal, 12)

            HStack(spacing: 14) {
                ForEach(swatches, id: \.name) { swatch in
                    let selected = (highlights[ref(for: number)] ?? "none") == swatch.name
                    Circle()
                        .fill(Color(hex: swatch.hex))
                        .frame(width: 34, height: 34)
                        .overlay(
                            Circle().stroke(selected ? Theme.brown : Theme.hairline,
                                            lineWidth: selected ? 2 : 1)
                        )
                        .onTapGesture {
                            setHighlight(swatch.name == "none" ? nil : swatch.name,
                                         for: ref(for: number))
                            Haptics.selection(enabled: settings.haptics)
                            closeMenu()
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous)
                .fill(Color.white)
                .shadow(color: Theme.ink.opacity(0.18), radius: 22, y: 8)
        )
    }

    /// Highlight swatches as (persistable name, hex). "none" clears the highlight.
    private var swatches: [(name: String, hex: String)] {
        [("none",  "#FFFFFF"),
         ("gold",  "#FBE7A3"),
         ("green", "#BFE9C4"),
         ("pink",  "#F6C7D8"),
         ("blue",  "#AFD6EE"),
         ("peach", "#F3C79A"),
         ("lilac", "#D3BEEA")]
    }

    /// Resolve a stored highlight name to its swatch colour, or nil if none.
    private func highlightColor(named name: String?) -> Color? {
        guard let name, name != "none",
              let hex = swatches.first(where: { $0.name == name })?.hex else { return nil }
        return Color(hex: hex)
    }

    private func menuRow(_ icon: String, _ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Theme.brown)
                    .frame(width: 22)
                Text(title)
                    .font(.haven(19))
                    .foregroundStyle(Theme.ink)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func closeMenu() {
        withAnimation(.easeOut(duration: 0.14)) { menuVerse = nil }
    }

    // MARK: Floating controls

    private var floatingControls: some View {
        VStack {
            Spacer()
            HStack {
                fab(icon: app.isBookmarked(currentRef) ? "bookmark.fill" : "bookmark") {
                    app.toggleBookmark(currentRef)
                    Haptics.lightImpact(enabled: settings.haptics)
                }
                Spacer()
                fab(icon: "chevron.right") { advanceChapter() }
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.bottom, 108)
        }
        .allowsHitTesting(true)
    }

    private func fab(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.ink)
                .frame(width: 58, height: 58)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Theme.ink.opacity(0.12), radius: 14, y: 4)
                )
        }
        .buttonStyle(.plain)
    }

    private func advanceChapter() {
        if chapter < book.chapters {
            withAnimation { chapter += 1 }
        }
    }
}

// MARK: - Verse action helpers

/// Identifiable wrapper so a tapped verse can drive `.sheet(item:)`.
private struct VerseRefItem: Identifiable {
    let id = UUID()
    let ref: String
    let text: String
}

/// Identifiable wrapper so a chat seed can drive `.fullScreenCover(item:)`.
private struct ReadChatSeedItem: Identifiable {
    let id = UUID()
    let seed: ChatSeed
}

/// Compact share sheet for a single verse (text + reference).
private struct VerseShareSheet: View {
    let text: String
    let reference: String

    private var shareText: String { "\(text)\n\n— \(reference)" }

    var body: some View {
        VStack(spacing: 18) {
            Capsule()
                .fill(Theme.hairline)
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            VStack(alignment: .leading, spacing: 10) {
                Text(text)
                    .font(.haven(18))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(reference)
                    .font(.havenUI(14, .semibold))
                    .foregroundStyle(Theme.brown)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                    .fill(Color.white)
            )

            ShareLink(item: shareText) {
                Text("Share verse")
                    .font(.havenUI(16, .semibold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                            .fill(Theme.brown)
                    )
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Theme.Space.screen)
        .background(Theme.paper.ignoresSafeArea())
    }
}

#Preview {
    ReadView()
        .environmentObject(AppState())
        .environmentObject(SettingsStore())
}
