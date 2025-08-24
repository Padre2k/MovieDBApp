//
//  RatingItem.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//



import Foundation

/// Ratings entry inside MovieDetail (e.g., Rotten Tomatoes, Metacritic).
struct RatingItem: Decodable, Identifiable {
    let source: String
    let value: String
    var id: String { source + value }
    enum CodingKeys: String, CodingKey {
        case source = "Source"
        case value = "Value"
    }
}
