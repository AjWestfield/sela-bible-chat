//
//  ListenView.swift
//  Bible Chat  ·  "Haven" recreation
//
//  The Listen tab — a "Library" of oil-painting collection cards.
//

import SwiftUI

struct ListenView: View {
    @EnvironmentObject private var app: AppState

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Text("Library")
                        .font(.haven(34, .bold))
                        .foregroundStyle(Theme.brown)
                        .padding(.top, 8)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(BibleData.libraryCollections) { collection in
                            NavigationLink {
                                ListenCollectionView(collection: collection)
                            } label: {
                                CollectionCard(collection: collection)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Theme.Space.screen)

                    Color.clear.frame(height: 96)   // bottom clearance for tab bar
                }
            }
            .background(Theme.paper.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Collection card (square painterly tile w/ title bottom-left)

private struct CollectionCard: View {
    let collection: LibraryCollection
    var body: some View {
        ArtworkView(art: collection.artwork)
            .aspectRatio(0.92, contentMode: .fill)
            .overlay(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [.clear, .black.opacity(0.05), .black.opacity(0.62)],
                    startPoint: .center, endPoint: .bottom
                )
                .overlay(alignment: .bottomLeading) {
                    Text(collection.title)
                        .font(.haven(23, .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .padding(16)
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
    ListenView()
        .environmentObject(AppState())
}
