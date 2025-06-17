//
//  ContentType.swift
//  MusicBoxd
//
//  Created by Ricardo Leal on 17/05/25.
//


import Foundation

enum ContentType: String, CaseIterable {
    case albums = "Álbumes"
    case songs = "Canciones"
    case producers = "Productores"
}

enum TimeFilter: String, CaseIterable {
    case today = "Hoy"
    case week = "Semana"
    case month = "Mes"
    case year = "Año"
}

class HomeViewModel: ObservableObject {
    @Published var contentType: ContentType = .albums
    @Published var timeFilter: TimeFilter = .today // Not used in this version of fetch, but kept for future

    @Published var albums: [SpotifyAlbum] = []
    @Published var artists: [SpotifyArtist] = []
    @Published var tracks: [SpotifyTrack] = []

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let spotifyAPIService = SpotifyAPIService()

    init() {
        // Initial data load can be triggered here or from the View (e.g., .onAppear)
        // For now, we'll let the View trigger it.
    }

    func fetchFilteredContent() {
        isLoading = true
        errorMessage = nil

        // Using a default query for now, this can be dynamic later
        // based on timeFilter or a search bar.
        let searchQuery = "popular"
        // You might want to vary the query based on contentType or timeFilter in a real app.
        // For example, for "new" releases, the query might be different.

        switch contentType {
        case .albums:
            // Clear other arrays if you want to show only one type at a time
            self.artists = []
            self.tracks = []
            spotifyAPIService.searchAlbums(query: searchQuery, limit: 10) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let fetchedAlbums):
                        self?.albums = fetchedAlbums
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        print("Error fetching albums: \(error)")
                        // Optionally, present more user-friendly errors
                        if let spotifyError = error as? SpotifyAPIError {
                            switch spotifyError {
                            case .authenticationFailed:
                                self?.errorMessage = "Authentication failed. Please check credentials."
                            case .rateLimitExceeded:
                                self?.errorMessage = "Too many requests. Please try again later."
                            default:
                                self?.errorMessage = "Failed to load albums. \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }
        case .songs:
            self.albums = []
            self.artists = []
            spotifyAPIService.searchTracks(query: searchQuery, limit: 10) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let fetchedTracks):
                        self?.tracks = fetchedTracks
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        print("Error fetching tracks: \(error)")
                        // Add more specific error handling if needed
                         if let spotifyError = error as? SpotifyAPIError {
                            switch spotifyError {
                            case .authenticationFailed:
                                self?.errorMessage = "Authentication failed. Please check credentials."
                            case .rateLimitExceeded:
                                self?.errorMessage = "Too many requests. Please try again later."
                            default:
                                self?.errorMessage = "Failed to load songs. \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }
        case .producers: // Mapping 'producers' to search for artists
            self.albums = []
            self.tracks = []
            spotifyAPIService.searchArtists(query: searchQuery, limit: 10) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let fetchedArtists):
                        self?.artists = fetchedArtists
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        print("Error fetching artists (producers): \(error)")
                        // Add more specific error handling if needed
                        if let spotifyError = error as? SpotifyAPIError {
                            switch spotifyError {
                            case .authenticationFailed:
                                self?.errorMessage = "Authentication failed. Please check credentials."
                            case .rateLimitExceeded:
                                self?.errorMessage = "Too many requests. Please try again later."
                            default:
                                self?.errorMessage = "Failed to load producers. \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }
        }
    }
}
