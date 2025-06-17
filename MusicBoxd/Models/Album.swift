//
//  Album.swift
//  MusicBoxd
//
//  Created by Ricardo Leal on 17/05/25.
//


import Foundation

struct Album: Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let imageName: String
    let popularityScore: Int
}
