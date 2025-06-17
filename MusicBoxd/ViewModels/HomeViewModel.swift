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
    @Published var timeFilter: TimeFilter = .today

    // Datos de ejemplo
    @Published var albums: [Album] = [
        Album(title: "Midnights", artist: "Taylor Swift", imageName: "album1", popularityScore: 90),
        Album(title: "After Hours", artist: "The Weeknd", imageName: "album2", popularityScore: 85),
        Album(title: "Random Access Memories", artist: "Daft Punk", imageName: "album3", popularityScore: 82)
    ]

    // Aquí irían los filtros y llamadas reales a la API o base de datos
    func fetchFilteredContent() {
        // Filtra en base al tipo de contenido y al tiempo
        // Esto es simulado, en el futuro sería una llamada a Firebase o una API
    }
}
