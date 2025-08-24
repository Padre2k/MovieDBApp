//
//  MovieDetail.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//


import Foundation

/// Detailed info from the OMDb `i=` lookup.
struct MovieDetail: Identifiable, Decodable {
    let title: String
    let year: String
    let imdbID: String
    let poster: String
    let genre: String
    let plot: String
    let director: String
    let actors: String
    let runtime: String
    let released: String
    let rated: String
    let imdbRating: String
    let ratings: [RatingItem]?

    var id: String { imdbID }

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case poster = "Poster"
        case genre = "Genre"
        case plot = "Plot"
        case director = "Director"
        case actors = "Actors"
        case runtime = "Runtime"
        case released = "Released"
        case rated = "Rated"
        case imdbRating
        case ratings = "Ratings"
    }
}
