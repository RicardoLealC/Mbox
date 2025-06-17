//
//  Artist.swift
//  MusicBoxd
//
//  Created by Jules on 03/11/2024
//

import Foundation

// MARK: - Shared Structures

/// Represents an image object from Spotify, typically used for artists and albums.
struct SpotifyImage: Decodable, Hashable {
    let url: String
    let height: Int?
    let width: Int?
}

/// Represents external URLs, commonly for Spotify content.
struct SpotifyExternalURLs: Decodable, Hashable {
    let spotify: String?
}

// MARK: - Artist Definition

/// Represents a Spotify Artist.
struct SpotifyArtist: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let images: [SpotifyImage]?
    let genres: [String]?
    let popularity: Int?
    let uri: String?
    let type: String? // e.g., "artist"
    let external_urls: SpotifyExternalURLs?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case images
        case genres
        case popularity
        case uri
        case type
        case external_urls
    }
}
