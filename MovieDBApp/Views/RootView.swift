//
//  RootView.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//


import SwiftUI

struct RootView: View {
    @StateObject private var prefs = Preferences()

    var body: some View {
        TabView {
            ContentView()
                .tabItem { Label("Browse", systemImage: "square.grid.2x2") }

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
        } //: Root
        .environmentObject(prefs) // share likes/watchlist/API key
    }
}
