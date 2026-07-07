//
//  ListenCollectionView.swift
//  Bible Chat  ·  "Haven" recreation
//
//  A single library collection — sections of story cards that open the player.
//

import SwiftUI

struct ListenCollectionView: View {
    let collection: LibraryCollection

    @EnvironmentObject private var app: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var presentedStory: Story? = nil

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                ForEach(collection.sections) { section in
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(section.title)
                                .font(.haven(26, .semibold))
                                .foregroundStyle(Theme.brown)
                            Text(section.subtitle)
                                .font(.haven(17))
                                .foregroundStyle(Theme.inkSoft)
                        }

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(section.stories) { story in
                                Button {
                                    app.nowPlaying = story
                                    app.isPlaying = true
                                    presentedStory = story
                                } label: {
                                    StoryCard(story: story)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                Color.clear.frame(height: 96)   // bottom clearance for tab bar
            }
            .padding(.horizontal, Theme.Space.screen)
            .padding(.top, 8)
        }
        .background(Theme.paper.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) { header }
        .fullScreenCover(item: $presentedStory) { story in
            AudioPlayerView(story: story)
        }
    }

    private var header: some View {
        ZStack {
            Text(collection.title)
                .font(.haven(30, .bold))
                .foregroundStyle(Theme.brown)
                .frame(maxWidth: .infinity)

            HStack {
                CircleIconButton(systemName: "arrow.left") { dismiss() }
                Spacer()
            }
        }
        .padding(.horizontal, Theme.Space.screen)
        .padding(.top, 6)
        .padding(.bottom, 12)
        .background(Theme.paper.opacity(0.98))
    }
}

// MARK: - Story card (painterly tile w/ uppercase ref + serif title)

private struct StoryCard: View {
    let story: Story
    var body: some View {
        ArtworkView(art: story.artwork)
            .aspectRatio(1.0, contentMode: .fill)
            .overlay(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.05), .black.opacity(0.66)],
                    startPoint: .center, endPoint: .bottom
                )
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(story.reference.uppercased())
                            .font(.havenUI(12, .semibold))
                            .tracking(0.5)
                            .foregroundStyle(.white.opacity(0.85))
                        Text(story.title)
                            .font(.haven(20, .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(3)
                    }
                    .padding(14)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(.black.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
    }
}

#Preview {
    NavigationStack {
        ListenCollectionView(collection: BibleData.libraryCollections[0])
            .environmentObject(AppState())
    }
}
