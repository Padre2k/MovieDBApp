//
//  ContentView.swift
//  MovieDBApp
//
//  Created by Ethan Faggett on 8/23/24.
//



import SwiftUI

struct ContentView: View {
    @EnvironmentObject var prefs: Preferences
    @StateObject private var vm = MoviesViewModel()
    @State private var showKeySheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                genreChips
                filterChips
                Divider()
                contentList
            } //: VStack
            .navigationTitle("OMDb Genres")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showKeySheet = true } label: {
                        Image(systemName: prefs.apiKey.isEmpty ? "key.fill" : "key")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { vm.load(for: vm.selectedGenre, prefs: prefs) } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(prefs.apiKey.isEmpty)
                }
            }
            .sheet(isPresented: $showKeySheet) {
                APIKeySheet(apiKey: $prefs.apiKey)
                    .presentationDetents([.medium])
            }
            .onAppear {
                if !prefs.apiKey.isEmpty, vm.movies.isEmpty {
                    vm.load(for: .Action, prefs: prefs)
                }
            }
        } //: NavigationStack
    }

   
    
    
    private var genreChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Genre.allCases) { genre in
                    Button {
                        vm.load(for: genre, prefs: prefs)
                    } label: {
                        Text(genre.rawValue)
                            .font(.callout.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(genre == vm.selectedGenre ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.12))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(genre == vm.selectedGenre ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 6)
        }
    }

    private var filterChips: some View {
        HStack(spacing: 8) {
            ForEach(DisplayFilter.allCases) { filter in
                Button { vm.displayFilter = filter } label: {
                    Text(filter.rawValue)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(filter == vm.displayFilter ? Color.accentColor.opacity(0.18) : Color.gray.opacity(0.12))
                        )
                        .overlay(
                            Capsule()
                                .stroke(filter == vm.displayFilter ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom, 6)
    }

    @ViewBuilder
    private var contentList: some View {
        if prefs.apiKey.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "key").font(.system(size: 36))
                Text("Add your OMDb API Key").font(.headline)
                Text("Tap the key icon to enter your key.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if vm.loading {
            ProgressView("Loading \(vm.selectedGenre.rawValue) movies…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let message = vm.errorMessage {
            VStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle").font(.system(size: 40))
                Text(message).multilineTextAlignment(.center).padding(.horizontal)
                Button("Try Again") { vm.load(for: vm.selectedGenre, prefs: prefs) }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(filteredMovies(prefs: prefs)) { movie in
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

    private func filteredMovies(prefs: Preferences) -> [MovieDetail] {
        switch vm.displayFilter {
        case .all: return vm.movies
        case .liked: return vm.movies.filter { prefs.liked.contains($0.imdbID) }
        case .watchlist: return vm.movies.filter { prefs.watchlist.contains($0.imdbID) }
        }
    }
}
