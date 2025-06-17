// MusicBoxd/Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                // Toggle bar de tipo de contenido
                Picker("Tipo", selection: $viewModel.contentType) {
                    ForEach(ContentType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Toggle de tiempo
                Picker("Tiempo", selection: $viewModel.timeFilter) {
                    ForEach(TimeFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Content Area
                if viewModel.isLoading && viewModel.albums.isEmpty && viewModel.artists.isEmpty && viewModel.tracks.isEmpty {
                    Spacer()
                    ProgressView("Cargando...")
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            // Conditional content based on contentType
                            switch viewModel.contentType {
                            case .albums:
                                if viewModel.albums.isEmpty && !viewModel.isLoading {
                                    Text("No se encontraron álbumes.")
                                        .foregroundColor(.gray)
                                        .padding(.top, 50)
                                } else {
                                    ForEach(viewModel.albums) { album in
                                        AlbumCardView(album: album)
                                    }
                                }
                            case .songs:
                                if viewModel.tracks.isEmpty && !viewModel.isLoading {
                                    Text("No se encontraron canciones. Implementación de TrackCardView pendiente.")
                                        .foregroundColor(.gray)
                                        .padding(.top, 50)
                                } else {
                                    // Placeholder for TrackCardView
                                    ForEach(viewModel.tracks) { track in
                                        // Replace with TrackCardView(track: track) when available
                                        VStack(alignment: .leading) {
                                            Text(track.name)
                                                .font(.headline)
                                            Text(track.artists.first?.name ?? "Artista desconocido")
                                                .font(.subheadline)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            case .producers: // Mapped to Artists
                                if viewModel.artists.isEmpty && !viewModel.isLoading {
                                    Text("No se encontraron artistas. Implementación de ArtistCardView pendiente.")
                                        .foregroundColor(.gray)
                                        .padding(.top, 50)
                                } else {
                                    // Placeholder for ArtistCardView
                                    ForEach(viewModel.artists) { artist in
                                        // Replace with ArtistCardView(artist: artist) when available
                                        VStack(alignment: .leading) {
                                            Text(artist.name)
                                                .font(.headline)
                                            Text(artist.genres?.first ?? "Género desconocido")
                                                .font(.subheadline)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, viewModel.albums.isEmpty && viewModel.artists.isEmpty && viewModel.tracks.isEmpty ? 0 : 20) // Add padding only if content is there
                    }
                }
                Spacer() // Ensures content or ProgressView/Error is centered if ScrollView is empty or not present
            }
            .navigationTitle("Destacados")
            .onAppear {
                // Fetch initial content only if nothing is loaded
                if viewModel.albums.isEmpty && viewModel.artists.isEmpty && viewModel.tracks.isEmpty {
                    viewModel.fetchFilteredContent()
                }
            }
            .onChange(of: viewModel.contentType) { _ in
                viewModel.fetchFilteredContent()
            }
            .onChange(of: viewModel.timeFilter) { _ in
                // Currently HomeViewModel doesn't use timeFilter for Spotify queries.
                // If it did, we would call fetchFilteredContent() here too.
                // For now, this just demonstrates where it would go.
                print("Time filter changed to: \(viewModel.timeFilter.rawValue). Fetching not implemented for this filter yet.")
            }
        }
    }
}
