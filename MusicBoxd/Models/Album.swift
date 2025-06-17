//
//  Album.swift
//  MusicBoxd
//
//  Created by Ricardo Leal on 17/05/25.
//  Updated by Jules on 03/11/2024 for Spotify API integration.
//

import Foundation

/// Represents a collection of tracks, typically used within an album or playlist response from Spotify.
struct SpotifyTrackCollection: Decodable, Hashable {
    let items: [SpotifyTrack] // Forward declaration; SpotifyTrack will be defined in Track.swift
    let href: String?
    let limit: Int?
    let next: String?
    let offset: Int?
    let previous: String?
    let total: Int?
}

/// Represents a Spotify Album.
struct SpotifyAlbum: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let images: [SpotifyImage]?
    let popularity: Int?
    let release_date: String?
    let release_date_precision: String?
    let total_tracks: Int?
    let album_type: String?
    let uri: String?
    let external_urls: SpotifyExternalURLs?
    let tracks: SpotifyTrackCollection? // For nested track lists

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artists
        case images
        case popularity
        case release_date
        case release_date_precision
        case total_tracks
        case album_type
        case uri
        case external_urls
        case tracks
    }
}
