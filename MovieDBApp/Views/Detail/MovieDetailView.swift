//
//  MovieDetailView.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//




import SwiftUI

struct MovieDetailView: View {
    @EnvironmentObject var prefs: Preferences
    let movie: MovieDetail

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                posterHeader

                VStack(alignment: .leading, spacing: 8) {
                    Text(movie.title)
                        .font(.title.bold())
                        .lineLimit(3)

                    Text("\(movie.year)\(spacerDot(movie.runtime))\(movie.runtime)\(spacerDot(movie.rated))\(movie.rated)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    WrapChips(items: movie.genre.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })

                    actionRow

                    Divider()

                    keyFacts

                    if let ratings = movie.ratings, !ratings.isEmpty {
                        ratingsSection(ratings)
                    }

                    if movie.plot != "N/A" {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Summary").font(.headline)
                            Text(movie.plot)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }

                    imdbLink
                } //: VStack
                .padding(.horizontal)
                .padding(.bottom, 24)
            } //: Vstack
        } //Scrollview
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    prefs.toggleLiked(movie.imdbID)
                } label: {
                    Image(systemName: prefs.liked.contains(movie.imdbID) ? "heart.fill" : "heart")
                }
            }
        }
    }

    private func spacerDot(_ s: String) -> String { s == "N/A" ? "" : " • " }

    // MARK: Subviews

    private var posterHeader: some View {
        let url = (movie.poster != "N/A") ? URL(string: movie.poster) : nil
        return ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .frame(height: 280)
                .overlay(
                    Group {
                        if let url {
                            AsyncImage(url: url) { phase in
                                if case .success(let img) = phase {
                                    img.resizable().scaledToFill().opacity(0.35)
                                }
                            }
                        }
                    } //: Group
                )
                .clipped()

            HStack {
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 6)
                    poster
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } //: Zstack
                .frame(width: 180, height: 260)
                Spacer()
            } //: Hstack
        } //: Zstack
        .padding(.bottom, 8)
    }

    private var poster: some View {
        let url = (movie.poster != "N/A") ? URL(string: movie.poster) : nil
        return Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure: Image(systemName: "film").font(.largeTitle)
                    @unknown default: EmptyView()
                    }
                }
            } else {
                Image(systemName: "film").font(.largeTitle)
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button {
                prefs.toggleLiked(movie.imdbID)
            } label: {
                Label(prefs.liked.contains(movie.imdbID) ? "Liked" : "Like",
                      systemImage: prefs.liked.contains(movie.imdbID) ? "heart.fill" : "heart")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                prefs.toggleWatch(movie.imdbID)
            } label: {
                Label(prefs.watchlist.contains(movie.imdbID) ? "In Watchlist" : "One to See",
                      systemImage: prefs.watchlist.contains(movie.imdbID) ? "eye.fill" : "eye")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var keyFacts: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details").font(.headline)
            FactRow(label: "Director", value: movie.director)
            if movie.actors != "N/A" { FactRow(label: "Actors", value: movie.actors) }
            if movie.released != "N/A" { FactRow(label: "Released", value: movie.released) }
            if movie.imdbRating != "N/A" { FactRow(label: "IMDb", value: "\(movie.imdbRating)/10") }
        }
    }

    private func ratingsSection(_ ratings: [RatingItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Critic & Site Ratings").font(.headline)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(ratings) { r in
                    HStack {
                        Text(r.source).font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(r.value).font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .overlay(Divider(), alignment: .bottom)
                }
            }
        }
    }

    private var imdbLink: some View {
        VStack(alignment: .leading, spacing: 8) {
            Link(destination: URL(string: "https://www.imdb.com/title/\(movie.imdbID)/")!) {
                Label("View on IMDb", systemImage: "arrow.up.right.square")
            }
            .padding(.top, 8)
        }
    }
}
