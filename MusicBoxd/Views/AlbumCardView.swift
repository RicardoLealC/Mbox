//
//  AlbumCardView.swift
//  MusicBoxd
//
//  Created by Ricardo Leal on 17/05/25.
//


import SwiftUI

struct AlbumCardView: View {
    let album: Album

    var body: some View {
        HStack {
            Image(album.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {
                Text(album.title)
                    .font(.headline)
                Text(album.artist)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Popularidad: \(album.popularityScore)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}
