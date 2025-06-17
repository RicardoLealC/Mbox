//
//  Track.swift
//  MusicBoxd
//
//  Created by Jules on 03/11/2024
//

import Foundation

/// Represents a linked track object from Spotify (e.g., for relinked content).
struct SpotifyLinkedTrack: Decodable, Identifiable, Hashable {
    let id: String
    let uri: String?
    let type: String? // e.g., "track"
    let external_urls: SpotifyExternalURLs?

    enum CodingKeys: String, CodingKey {
        case id
        case uri
        case type
        case external_urls
    }
}

/// Represents a Spotify Track.
struct SpotifyTrack: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    // Simplified album object can be included when track is part of an album response,
    // or full album when track is fetched directly. Using SpotifyAlbum? handles both.
    let album: SpotifyAlbum?
    let duration_ms: Int
    let popularity: Int?
    let preview_url: String?
    let track_number: Int?
    let disc_number: Int?
    let explicit: Bool?
    let uri: String?
    let external_urls: SpotifyExternalURLs?
    let is_playable: Bool? // From Spotify API, indicates if track is playable in current market
    let linked_from: SpotifyLinkedTrack?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artists
        case album
        case duration_ms
        case popularity
        case preview_url
        case track_number
        case disc_number
        case explicit
        case uri
        case external_urls
        case is_playable
        case linked_from
    }
}
