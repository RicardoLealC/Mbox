//
//  ContentType.swift
//  MusicBoxd
//
//  Created by Ricardo Leal on 17/05/25.
//


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

                // Lista de álbumes
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.albums) { album in
                            AlbumCardView(album: album)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("Destacados")
        }
    }
}
