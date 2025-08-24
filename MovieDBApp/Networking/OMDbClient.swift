//
//  OMDbClient.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//



import Foundation

struct OMDbClient {
    let apiKey: String

    func searchMovies(keyword: String, page: Int) async throws -> [MovieSummary] {
        guard !apiKey.isEmpty else { return [] }
        var comps = URLComponents(string: "https://www.omdbapi.com/")!
        comps.queryItems = [
            .init(name: "apikey", value: apiKey),
            .init(name: "s", value: keyword),
            .init(name: "type", value: "movie"),
            .init(name: "page", value: String(page))
        ]
        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
        if decoded.response == "True" {
            return decoded.search ?? []
        } else {
            return []
        }
    }

    func movieDetails(imdbID: String) async throws -> MovieDetail? {
        guard !apiKey.isEmpty else { return nil }
        var comps = URLComponents(string: "https://www.omdbapi.com/")!
        comps.queryItems = [
            .init(name: "apikey", value: apiKey),
            .init(name: "i", value: imdbID),
            .init(name: "plot", value: "short")
        ]
        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        let decoded = try JSONDecoder().decode(MovieDetail.self, from: data)
        return decoded.imdbID.isEmpty ? nil : decoded
    }
}
