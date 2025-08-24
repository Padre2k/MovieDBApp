//
//  LibraryViewModel.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/24/25.
//

import Foundation
import SwiftUI

/// Holds details for the user's Liked and Watchlist libraries, independent of the browse feed.
@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var likedMovies: [MovieDetail] = []
    @Published var watchlistMovies: [MovieDetail] = []
    @Published var loading: Bool = false
    @Published var errorMessage: String?
    
    private var currentTask: Task<Void, Never>?
    
    func refresh(prefs: Preferences) {
        currentTask?.cancel()
        errorMessage = nil
        loading = true
        
        let idsLiked = prefs.liked
        let idsWatch = prefs.watchlist
        let apiKey = prefs.apiKey
        
        guard !apiKey.isEmpty, (!idsLiked.isEmpty || !idsWatch.isEmpty) else {
            likedMovies = []
            watchlistMovies = []
            loading = false
            return
        }
        
        currentTask = Task {
            defer { loading = false }
            do {
                let client = OMDbClient(apiKey: apiKey)
                
                // fetch liked & watchlist in parallel
                async let likedFetch: [MovieDetail] = fetchDetails(for: Array(idsLiked), client: client)
                async let watchFetch: [MovieDetail] = fetchDetails(for: Array(idsWatch), client: client)
                let (liked, watched) = try await (likedFetch, watchFetch)
                
                // sort by year desc then title
                self.likedMovies = liked.sorted {
                    (Int($0.year.prefix(4)) ?? 0, $0.title) > (Int($1.year.prefix(4)) ?? 0, $1.title)
                }
                self.watchlistMovies = watched.sorted {
                    (Int($0.year.prefix(4)) ?? 0, $0.title) > (Int($1.year.prefix(4)) ?? 0, $1.title)
                }
            } catch {
                if Task.isCancelled { return }
                errorMessage = "Library error: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchDetails(for ids: [String], client: OMDbClient) async throws -> [MovieDetail] {
        var results: [MovieDetail] = []
        for chunk in ids.chunked(into: 6) {
            try await withThrowingTaskGroup(of: MovieDetail?.self) { group in
                for id in chunk {
                    group.addTask { try await client.movieDetails(imdbID: id) }
                }
                for try await detail in group {
                    if let d = detail { results.append(d) }
                }
            }
        }
        return results
    }
    
    func likedFiltered(by genre: Genre?) -> [MovieDetail] {
        guard let g = genre else { return likedMovies }
        return likedMovies.filter {
            $0.genre.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .contains(g.rawValue)
        }
    }
    
    func watchlistFiltered(by genre: Genre?) -> [MovieDetail] {
        guard let g = genre else { return watchlistMovies }
        return watchlistMovies.filter {
            $0.genre.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .contains(g.rawValue)
        }
    }
}
