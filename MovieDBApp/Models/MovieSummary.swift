//
//  MovieSummary.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//



import Foundation

/// Compact results from the OMDb `s=` search.
struct MovieSummary: Identifiable, Decodable {
    let title: String
    let year: String
    let imdbID: String
    let poster: String

    var id: String { imdbID }

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case poster = "Poster"
    }
}
