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
    @State private var selectedGenre: Genre? = nil // nil = All
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Genre filter chips (All + every genre)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button {
                            selectedGenre = nil
                        } label: {
                            Text("All")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule().fill(selectedGenre == nil ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.12))
                                )
                                .overlay(
                                    Capsule().stroke(selectedGenre == nil ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        ForEach(Genre.allCases) { g in
                            Button {
                                selectedGenre = g
                            } label: {
                                Text(g.rawValue)
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule().fill(selectedGenre == g ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.12))
                                    )
                                    .overlay(
                                        Capsule().stroke(selectedGenre == g ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                }
                
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
                        
                    } else if filteredResults.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass").font(.system(size: 36))
                            Text("Search Movies").font(.headline)
                            Text("Type a title like “Inception” or “Batman”.")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    } else {
                        List(filteredResults) { movie in
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
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $vm.query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Movie title")
            .onSubmit(of: .search) { vm.search(prefs: prefs) }
            .onChange(of: vm.query) { _, new in
                Task {
                    try? await Task.sleep(nanoseconds: 400_000_000) // debounce ~0.4s
                    if new == vm.query { vm.search(prefs: prefs) }
                }
            }
        }
    }
    
    private var filteredResults: [MovieDetail] {
        guard let g = selectedGenre else { return vm.results }
        return vm.results.filter {
            $0.genre.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .contains(g.rawValue)
        }
    }
}

