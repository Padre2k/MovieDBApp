//
//  SearchView.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//


import SwiftUI

struct SearchView: View {
    @EnvironmentObject var prefs: Preferences
    @StateObject private var vm = SearchViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if prefs.apiKey.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "key").font(.system(size: 36))
                        Text("Add your OMDb API Key").font(.headline)
                        Text("Tap the key icon in the Browse tab to enter your key.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                    }
                } else if vm.loading {
                    ProgressView("Searching…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let message = vm.errorMessage, !vm.query.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle").font(.system(size: 40))
                        Text(message).multilineTextAlignment(.center).padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if vm.results.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass").font(.system(size: 36))
                        Text("Search Movies").font(.headline)
                        Text("Type a title like “Inception” or “Batman”.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(vm.results) { movie in
                        NavigationLink {
                            MovieDetailView(movie: movie)
                        } label: {
                            MovieRow(
                                movie: movie,
                                liked: prefs.liked.contains(movie.imdbID),
                                watched: prefs.watchlist.contains(movie.imdbID),
                                onLike: { prefs.toggleLiked(movie.imdbID) },
                                onWatch: { prefs.toggleWatch(movie.imdbID) }
                            )
                        } //: Label / Navigation
                    } //: List
                    .listStyle(.plain)
                } //: Else
            } //: Group
            .navigationTitle("Search")
            .searchable(text: $vm.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Movie title")
            .onSubmit(of: .search) { vm.search(prefs: prefs) }
            .onChange(of: vm.query) { _, new in
                Task {
                    try? await Task.sleep(nanoseconds: 400_000_000) // debounce ~0.4s
                    if new == vm.query { vm.search(prefs: prefs) }
                }
            }
        } //: Navigation
    }
}
