//
//  AlbumCardView.swift
//  MusicBoxd
//
//  Created by Ricardo Leal on 17/05/25.
//


import SwiftUI
import Kingfisher // Import Kingfisher

struct AlbumCardView: View {
    let album: SpotifyAlbum // Updated to use SpotifyAlbum model

    var body: some View {
        HStack {
            if let imageURLString = album.images?.first?.url, let url = URL(string: imageURLString) {
                KFImage(url)
                    .placeholder {
                        Image(systemName: "music.note.list")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(12)
                            .clipped()
                            .foregroundColor(.gray)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .clipped()
                    .cancelOnDisappear(true)
            } else {
                // Fallback placeholder if there are no images or URL is invalid
                Image(systemName: "music.note.list")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(12)
                    .clipped()
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(album.name) // Was album.title
                    .font(.headline)
                Text(album.artists?.first?.name ?? "Unknown Artist") // Was album.artist
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Popularidad: \(album.popularity ?? 0)") // Was album.popularityScore
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
