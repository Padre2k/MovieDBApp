//
//  Preferences.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//


import Foundation
import SwiftUI

/// Stores API key and user's likes/watchlist in UserDefaults via @AppStorage.
final class Preferences: ObservableObject {
    @AppStorage("omdb_api_key") var apiKey: String = "d22a396e"
    @AppStorage("liked_ids") private var likedJSON: String = "[]"
    @AppStorage("watch_ids") private var watchJSON: String = "[]"

    @Published var liked: Set<String> = []
    @Published var watchlist: Set<String> = []

    init() {
        liked = decodeSet(from: likedJSON)
        watchlist = decodeSet(from: watchJSON)
    }

    func toggleLiked(_ id: String) {
        if liked.contains(id) { liked.remove(id) } else { liked.insert(id) }
        likedJSON = encodeSet(liked)
        objectWillChange.send()
    }

    func toggleWatch(_ id: String) {
        if watchlist.contains(id) { watchlist.remove(id) } else { watchlist.insert(id) }
        watchJSON = encodeSet(watchlist)
        objectWillChange.send()
    }

    private func decodeSet(from json: String) -> Set<String> {
        (try? JSONDecoder().decode([String].self, from: Data(json.utf8))).map(Set.init) ?? []
    }
    private func encodeSet(_ set: Set<String>) -> String {
        let arr = Array(set)
        let data = try? JSONEncoder().encode(arr)
        return data.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}
