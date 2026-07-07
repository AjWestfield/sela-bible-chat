import SwiftUI

// MARK: - Book Picker

struct BookPickerSheet: View {
    @Binding var book: BibleBook
    @Binding var chapter: Int
    @Environment(\.dismiss) private var dismiss

    @State private var testament: Testament = .old

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    private var books: [BibleBook] {
        BibleData.books.filter { $0.testament == testament }
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber
            segmentedControl
                .padding(.horizontal, Theme.Space.screen)
                .padding(.top, 6)
                .padding(.bottom, 14)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(books) { b in
                        bookCell(b)
                    }
                }
                .padding(.horizontal, Theme.Space.screen)
                .padding(.bottom, 40)
            }
        }
        .background(Theme.paper.ignoresSafeArea())
        .onAppear { testament = book.testament }
    }

    private var grabber: some View {
        Capsule()
            .fill(Theme.hairline)
            .frame(width: 40, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 16)
    }

    private var segmentedControl: some View {
        HStack(spacing: 6) {
            segment(.old, title: "Old Testament")
            segment(.new, title: "New Testament")
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                .fill(Theme.cardSoft)
        )
    }

    private func segment(_ t: Testament, title: String) -> some View {
        let active = testament == t
        return Button {
            withAnimation(.easeInOut(duration: 0.18)) { testament = t }
        } label: {
            Text(title)
                .font(.havenUI(15, .semibold))
                .foregroundStyle(active ? Color.white : Theme.inkSoft)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.pill, style: .continuous)
                        .fill(active ? Theme.brown : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }

    private func bookCell(_ b: BibleBook) -> some View {
        let selected = b.name == book.name
        return Button {
            book = b
            chapter = 1
            dismiss()
        } label: {
            Text(b.name)
                .font(.haven(16))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                        .fill(selected ? Theme.goldPale : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                        .stroke(selected ? Theme.brown : Theme.hairline, lineWidth: selected ? 1.4 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chapter Picker

struct ChapterPickerSheet: View {
    let book: BibleBook
    @Binding var chapter: Int
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        VStack(spacing: 0) {
            grabber
            Text(book.name)
                .font(.haven(20, .semibold))
                .foregroundStyle(Theme.ink)
                .padding(.bottom, 16)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(1...max(book.chapters, 1), id: \.self) { n in
                        chapterCell(n)
                    }
                }
                .padding(.horizontal, Theme.Space.screen)
                .padding(.bottom, 40)
            }
        }
        .background(Theme.paper.ignoresSafeArea())
    }

    private var grabber: some View {
        Capsule()
            .fill(Theme.hairline)
            .frame(width: 40, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 16)
    }

    private func chapterCell(_ n: Int) -> some View {
        let selected = n == chapter
        return Button {
            chapter = n
            dismiss()
        } label: {
            Text("\(n)")
                .font(.haven(17, selected ? .semibold : .regular))
                .foregroundStyle(selected ? Color.white : Theme.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                        .fill(selected ? Theme.gold : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                        .stroke(selected ? Color.clear : Theme.hairline, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Font Settings

struct FontSettingsSheet: View {
    @Binding var fontScale: Double
    @Environment(\.dismiss) private var dismiss

    /// Reader typeface choice (0 = serif, 1 = rounded, 2 = sans), persisted.
    @AppStorage("sela.readerFont") private var serifChoice: Int = 0

    /// Build a reader font for a given style index and size.
    private func readerFont(_ index: Int, _ size: CGFloat) -> Font {
        switch index {
        case 2:  return .havenUI(size, .regular)                       // sans (SF)
        case 1:  return .system(size: size, weight: .regular, design: .rounded)
        default: return .haven(size, .regular)                        // serif (New York)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            grabber

            Text("Aa")
                .font(readerFont(serifChoice, 64 * CGFloat(fontScale)))
                .foregroundStyle(Theme.ink)
                .frame(height: 96)
                .padding(.bottom, 8)

            Text("Text Size")
                .font(.havenUI(13, .semibold))
                .foregroundStyle(Theme.inkFaint)
                .textCase(.uppercase)
                .kerning(1)
                .padding(.bottom, 12)

            HStack(spacing: 16) {
                Text("A")
                    .font(.haven(16))
                    .foregroundStyle(Theme.inkSoft)
                Slider(value: $fontScale, in: 0.85...1.4)
                    .tint(Theme.brown)
                Text("A")
                    .font(.haven(28))
                    .foregroundStyle(Theme.inkSoft)
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.bottom, 22)

            HStack(spacing: 12) {
                styleChoice(0)
                styleChoice(1)
                styleChoice(2)
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.bottom, 28)

            Spacer(minLength: 0)
        }
        .background(Theme.paper.ignoresSafeArea())
    }

    private var grabber: some View {
        Capsule()
            .fill(Theme.hairline)
            .frame(width: 40, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 20)
    }

    @ViewBuilder
    private func styleChoice(_ index: Int) -> some View {
        let selected = serifChoice == index
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { serifChoice = index }
            Haptics.selection()
        } label: {
            Text("Aa")
                .font(readerFont(index, 20))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                        .fill(selected ? Theme.goldPale : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.tile, style: .continuous)
                        .stroke(selected ? Theme.brown : Theme.hairline, lineWidth: selected ? 1.4 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Book Picker") {
    BookPickerSheet(book: .constant(BibleData.book(named: "Genesis")), chapter: .constant(1))
        .environmentObject(AppState())
}

#Preview("Chapter Picker") {
    ChapterPickerSheet(book: BibleData.book(named: "Genesis"), chapter: .constant(1))
        .environmentObject(AppState())
}

#Preview("Font Settings") {
    FontSettingsSheet(fontScale: .constant(1.0))
        .environmentObject(AppState())
}
