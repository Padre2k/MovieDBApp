//
//  MovieRow.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//



import SwiftUI

struct MovieRow: View {
    let movie: MovieDetail
    let liked: Bool
    let watched: Bool
    let onLike: () -> Void
    let onWatch: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            poster
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                Text(movie.year)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !movie.plot.isEmpty && movie.plot != "N/A" {
                    Text(movie.plot)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
                HStack(spacing: 12) {
                    Button(action: onLike) {
                        Label(liked ? "Liked" : "Like", systemImage: liked ? "heart.fill" : "heart")
                    }
                    .buttonStyle(.bordered)

                    Button(action: onWatch) {
                        Label(watched ? "One to See" : "One to See", systemImage: watched ? "eye.fill" : "eye")
                    }
                    .buttonStyle(.bordered)
                } //: HStack
                .labelStyle(.iconOnly)
            } //: VStack
        } //: HStack
        .frame(maxHeight: 140)
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var poster: some View {
        let url = (movie.poster != "N/A") ? URL(string: movie.poster) : nil
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.12))
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure:
                        Image(systemName: "film").font(.largeTitle).foregroundStyle(.secondary)
                    @unknown default: EmptyView()
                    }
                }
            } else {
                Image(systemName: "film").font(.largeTitle).foregroundStyle(.secondary)
            }
        }
        .frame(width: 90, height: 130)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
    }
}
