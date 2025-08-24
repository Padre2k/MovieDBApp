//
//  MovieViewModel.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//



import Foundation
import SwiftUI

enum Genre: String, CaseIterable, Identifiable {
    case Action, Adventure, Animation, Comedy, Crime, Documentary, Drama, Family, Fantasy, History, Horror, Music, Mystery, Romance, SciFi = "Sci-Fi", Sport, Thriller, War, Western
    var id: String { rawValue }
    var searchKeyword: String { rawValue }
}

enum DisplayFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case liked = "Liked"
    case watchlist = "One to See"
    var id: String { rawValue }
}

@MainActor
final class MoviesViewModel: ObservableObject {
    @Published var selectedGenre: Genre = .Action
    @Published var displayFilter: DisplayFilter = .all
    @Published var loading: Bool = false
    @Published var errorMessage: String?
    @Published var movies: [MovieDetail] = []

    private var currentTask: Task<Void, Never>?

    func load(for genre: Genre, prefs: Preferences) {
        selectedGenre = genre
        errorMessage = nil
        currentTask?.cancel()

        guard !prefs.apiKey.isEmpty else {
            movies = []
            return
        }

        loading = true
        let client = OMDbClient(apiKey: prefs.apiKey)

        currentTask = Task {
            defer { loading = false }
            do {
                let pages = [1, 2]
                var summaries: [MovieSummary] = []
                for p in pages {
                    if Task.isCancelled { return }
                    let pageResults = try await client.searchMovies(keyword: genre.searchKeyword, page: p)
                    summaries.append(contentsOf: pageResults)
                }

                let details = try await fetchDetailsInBatches(summaries: summaries, client: client)
                if Task.isCancelled { return }

                let filtered = details.filter { detail in
                    detail.genre
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .contains(genre.rawValue)
                }

                let unique = Dictionary(grouping: filtered, by: { $0.imdbID }).compactMap { $0.value.first }

                self.movies = unique.sorted { lhs, rhs in
                    let li = Int(lhs.year.prefix(4)) ?? 0
                    let ri = Int(rhs.year.prefix(4)) ?? 0
                    if li != ri { return li > ri }
                    return lhs.title < rhs.title
                }

                if movies.isEmpty {
                    errorMessage = "No \(genre.rawValue) results matched after filtering."
                }
            } catch {
                if Task.isCancelled { return }
                errorMessage = "Error: \(error.localizedDescription)"
                movies = []
            }
        }
    }

    private func fetchDetailsInBatches(summaries: [MovieSummary], client: OMDbClient) async throws -> [MovieDetail] {
        let chunkSize = 5
        var all: [MovieDetail] = []
        for chunk in summaries.chunked(into: chunkSize) {
            if Task.isCancelled { return [] }
            try await withThrowingTaskGroup(of: MovieDetail?.self) { group in
                for item in chunk {
                    group.addTask {
                        try await client.movieDetails(imdbID: item.imdbID)
                    }
                }
                for try await result in group {
                    if let result { all.append(result) }
                }
            }
        }
        return all
    }
}
