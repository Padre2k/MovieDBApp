//
//  SearchResponse.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//



import Foundation

/// Response wrapper for `s=` search.
struct SearchResponse: Decodable {
    let search: [MovieSummary]?
    let totalResults: String?
    let response: String
    let error: String?

    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
        case error = "Error"
    }
}
