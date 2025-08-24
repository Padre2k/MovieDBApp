# MovieDB (SwiftUI + OMDb)

A small SwiftUI app split into a clean file/folder structure:
- Browse by **Genre** (OMDb)
- **Search** tab with query + debounce
- **Details** screen with poster, facts, ratings, and IMDb link
- ❤️ **Liked** and 👀 **One to See** watchlist via @AppStorage

## Structure
```
App/
  OMDbGenresApp.swift
Models/
  MovieSummary.swift
  RatingItem.swift
  MovieDetail.swift
  SearchResponse.swift
Networking/
  OMDbClient.swift
Persistence/
  Preferences.swift
Utilities/
  Array+Chunked.swift
ViewModels/
  MoviesViewModel.swift
  SearchViewModel.swift
Views/
  Browse/
    ContentView.swift
    MovieRow.swift
  Components/
    FlowLayout.swift
    FactRow.swift
  Detail/
    MovieDetailView.swift
  Search/
    SearchView.swift
  Sheets/
    APIKeySheet.swift
  RootView.swift
```

## Setup
1. Open your Xcode SwiftUI iOS project.
2. Drag the `MovieDB` folders into your project (check “Copy items if needed”).  
3. Set the app entry to **OMDbGenresApp** *or* place `RootView()` inside your existing App.
4. Run, tap the **key** icon (Browse tab) to paste your **OMDb API key**.

## Notes
- OMDb does not support `genre=` filtering directly; we search then filter by the `Genre` field from details.
- API quota: keep pages small (currently 2) or add caching to reduce calls.
