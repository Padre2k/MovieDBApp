//
//  SearcViewModel.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//


import Foundation
import SwiftUI

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [MovieDetail] = []
    @Published var loading: Bool = false
    @Published var errorMessage: String?

    private var currentTask: Task<Void, Never>?

    func search(prefs: Preferences) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = nil
        currentTask?.cancel()
        results = []

        guard !prefs.apiKey.isEmpty, !q.isEmpty else { return }

        loading = true
        let client = OMDbClient(apiKey: prefs.apiKey)

        currentTask = Task {
            defer { loading = false }
            do {
                let pages = [1, 2]
                var summaries: [MovieSummary] = []
                for p in pages {
                    if Task.isCancelled { return }
                    let pageResults = try await client.searchMovies(keyword: q, page: p)
                    summaries.append(contentsOf: pageResults)
                }

                let details = try await fetchDetailsInBatches(summaries: summaries, client: client)
                if Task.isCancelled { return }

                let unique = Dictionary(grouping: details, by: { $0.imdbID }).compactMap { $0.value.first }
                self.results = unique.sorted { lhs, rhs in
                    let li = Int(lhs.year.prefix(4)) ?? 0
                    let ri = Int(rhs.year.prefix(4)) ?? 0
                    if li != ri { return li > ri }
                    return lhs.title < rhs.title
                }

                if results.isEmpty {
                    errorMessage = "No matches for “\(q)”."
                }
            } catch {
                if Task.isCancelled { return }
                errorMessage = "Error: \(error.localizedDescription)"
                results = []
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
