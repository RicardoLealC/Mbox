//
//  SpotifyAPIService.swift
//  MusicBoxd
//
//  Created by Jules on 03/11/2024
//

import Foundation

class SpotifyAPIService {

    private var accessToken: String?
    private var accessTokenExpiryDate: Date?

    private struct SpotifyTokenResponse: Decodable {
        let access_token: String
        let token_type: String // Often "Bearer"
        let expires_in: Int // In seconds
    }

    // MARK: - Search Response Structures (Private)
    private struct SpotifySearchAlbumsResponse: Decodable {
        let albums: SpotifyAlbumSearchResult
    }
    private struct SpotifyAlbumSearchResult: Decodable {
        let items: [SpotifyAlbum]
        let href: String?
        let limit: Int?
        let next: String?
        let offset: Int?
        let previous: String?
        let total: Int?
    }

    private struct SpotifySearchArtistsResponse: Decodable {
        let artists: SpotifyArtistSearchResult
    }
    private struct SpotifyArtistSearchResult: Decodable {
        let items: [SpotifyArtist]
        let href: String?
        let limit: Int?
        let next: String?
        let offset: Int?
        let previous: String?
        let total: Int?
    }

    private struct SpotifySearchTracksResponse: Decodable {
        let tracks: SpotifyTrackSearchResult
    }
    private struct SpotifyTrackSearchResult: Decodable {
        let items: [SpotifyTrack]
        let href: String?
        let limit: Int?
        let next: String?
        let offset: Int?
        let previous: String?
        let total: Int?
    }

    // Accessing credentials from SpotifyCredentials.swift
    // Ensure SpotifyCredentials.swift is in the project and contains your actual ID and Secret.
    // For security, .gitignore should prevent SpotifyCredentials.swift from being committed.
    private var clientId: String { SpotifyCredentials.clientId }
    private var clientSecret: String { SpotifyCredentials.clientSecret }

    init() {
        // Future initializations can go here.
        // For example, loading cached token or setting up network monitoring.
    }

    private func requestAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            completion(.failure(SpotifyAPIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Prepare Basic Authentication header
        let authString = "\(clientId):\(clientSecret)"
        guard let authData = authString.data(using: .utf8) else {
            // This error should ideally not happen with valid strings
            completion(.failure(SpotifyAPIError.tokenError("Failed to encode auth string.")))
            return
        }
        let authValue = "Basic \(authData.base64EncodedString())"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")

        // Set Content-Type and request body
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let requestBody = "grant_type=client_credentials"
        request.httpBody = requestBody.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return } // Avoid retain cycles

            if let error = error {
                print("SpotifyAPIService: Error requesting access token: \(error.localizedDescription)")
                completion(.failure(SpotifyAPIError.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("SpotifyAPIService: Invalid response type during token request.")
                completion(.failure(SpotifyAPIError.invalidResponse(statusCode: -1)))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                var errorDetail = "SpotifyAPIService: Token request failed with status code \(httpResponse.statusCode)"
                if let data = data, let detail = String(data: data, encoding: .utf8) {
                    errorDetail += " - \(detail)"
                }
                print(errorDetail)
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                    completion(.failure(SpotifyAPIError.authenticationFailed))
                } else {
                    completion(.failure(SpotifyAPIError.tokenError(errorDetail)))
                }
                return
            }

            guard let data = data else {
                print("SpotifyAPIService: No data received during token request.")
                completion(.failure(SpotifyAPIError.invalidResponse(statusCode: httpResponse.statusCode)))
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
                self.accessToken = tokenResponse.access_token
                // Calculate expiry date based on current time + expires_in (seconds)
                self.accessTokenExpiryDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expires_in))
                completion(.success(tokenResponse.access_token))
            } catch {
                completion(.failure(SpotifyAPIError.dataDecodingError(error)))
            }
        }.resume()
    }

    public func getAccessToken(completion: @escaping (Result<String, Error>) -> Void) {
        // Check if a valid token exists and is not about to expire
        if let token = accessToken, let expiryDate = accessTokenExpiryDate {
            // Add a small buffer (e.g., 60 seconds) to consider token valid
            // This avoids using a token that's just about to expire
            if expiryDate.addingTimeInterval(-60) > Date() {
                completion(.success(token))
                return
            }
        }

        // If no valid token, or token is about to expire, request a new one
        requestAccessToken(completion: completion)
    }

    // MARK: - Public API Methods

    public func searchAlbums(query: String, limit: Int = 20, offset: Int = 0, completion: @escaping (Result<[SpotifyAlbum], Error>) -> Void) {
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "album"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]

        guard let url = components?.url else {
            completion(.failure(SpotifyAPIError.invalidURL))
            return
        }

        let request = URLRequest(url: url) // GET by default

        requestData(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(SpotifySearchAlbumsResponse.self, from: data)
                    completion(.success(decodedResponse.albums.items))
                } catch {
                    print("SpotifyAPIService: Error decoding searchAlbums response: \(error)")
                    completion(.failure(SpotifyAPIError.dataDecodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func searchArtists(query: String, limit: Int = 20, offset: Int = 0, completion: @escaping (Result<[SpotifyArtist], Error>) -> Void) {
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "artist"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]

        guard let url = components?.url else {
            completion(.failure(SpotifyAPIError.invalidURL))
            return
        }

        let request = URLRequest(url: url)

        requestData(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(SpotifySearchArtistsResponse.self, from: data)
                    completion(.success(decodedResponse.artists.items))
                } catch {
                    print("SpotifyAPIService: Error decoding searchArtists response: \(error)")
                    completion(.failure(SpotifyAPIError.dataDecodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func searchTracks(query: String, limit: Int = 20, offset: Int = 0, completion: @escaping (Result<[SpotifyTrack], Error>) -> Void) {
        var components = URLComponents(string: "https://api.spotify.com/v1/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "track"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]

        guard let url = components?.url else {
            completion(.failure(SpotifyAPIError.invalidURL))
            return
        }

        let request = URLRequest(url: url)

        requestData(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedResponse = try JSONDecoder().decode(SpotifySearchTracksResponse.self, from: data)
                    completion(.success(decodedResponse.tracks.items))
                } catch {
                    print("SpotifyAPIService: Error decoding searchTracks response: \(error)")
                    completion(.failure(SpotifyAPIError.dataDecodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func getAlbumDetails(albumId: String, completion: @escaping (Result<SpotifyAlbum, Error>) -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/albums/\(albumId)") else {
            completion(.failure(SpotifyAPIError.invalidURL))
            return
        }

        let request = URLRequest(url: url)

        requestData(request: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedAlbum = try JSONDecoder().decode(SpotifyAlbum.self, from: data)
                    completion(.success(decodedAlbum))
                } catch {
                    print("SpotifyAPIService: Error decoding getAlbumDetails response: \(error)")
                    completion(.failure(SpotifyAPIError.dataDecodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Private Helper Methods

    private func requestData(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        getAccessToken { [weak self] tokenResult in
            guard let self = self else { return }
            switch tokenResult {
            case .success(let token):
                var mutableRequest = request
                mutableRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

                // Perform the request with retry logic
                self.performRequestWithRetry(mutableRequest, attempts: 3, completion: completion)

            case .failure(let error):
                print("SpotifyAPIService: Failed to get access token for data request: \(error.localizedDescription)")
                // Propagate the original error or map to a more specific one if needed
                completion(.failure(error))
            }
        }
    }

    private func performRequestWithRetry(_ request: URLRequest, attempts: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("SpotifyAPIService: Data request failed: \(error.localizedDescription)")
                completion(.failure(SpotifyAPIError.requestFailed(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("SpotifyAPIService: Invalid response type during data request.")
                completion(.failure(SpotifyAPIError.invalidResponse(statusCode: -1)))
                return
            }

            if httpResponse.statusCode == 429 { // Rate limit
                if attempts > 1 {
                    let retryAfterSeconds = httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap { Int($0) } ?? 5
                    print("SpotifyAPIService: Rate limit hit. Retrying after \(retryAfterSeconds) seconds... (Attempts left: \(attempts - 1))")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retryAfterSeconds)) {
                        self.performRequestWithRetry(request, attempts: attempts - 1, completion: completion)
                    }
                } else {
                    print("SpotifyAPIService: Rate limit hit. No more retry attempts.")
                    completion(.failure(SpotifyAPIError.rateLimitExceeded(retryAfter: httpResponse.value(forHTTPHeaderField: "Retry-After").flatMap { Int($0) })))
                }
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                var errorDetail = "SpotifyAPIService: Data request failed with status code \(httpResponse.statusCode)"
                if let responseData = data, let detail = String(data: responseData, encoding: .utf8) {
                    errorDetail += " - \(detail)"
                }
                print(errorDetail)
                if httpResponse.statusCode == 401 || httpResponse.statusCode == 403 {
                     completion(.failure(SpotifyAPIError.authenticationFailed))
                } else {
                    completion(.failure(SpotifyAPIError.invalidResponse(statusCode: httpResponse.statusCode)))
                }
                return
            }

            guard let responseData = data else {
                print("SpotifyAPIService: No data received from data request, despite 2xx status.")
                completion(.failure(SpotifyAPIError.invalidResponse(statusCode: httpResponse.statusCode))) // Or a more specific .noDataError
                return
            }
            completion(.success(responseData))

        }.resume()
    }
}

// Custom Error enum for more detailed error handling
enum SpotifyAPIError: Error {
    case invalidURL
    case requestFailed(Error)           // Wraps an underlying URLSession error
    case invalidResponse(statusCode: Int) // For non-2xx responses or missing httpResponse
    case dataDecodingError(Error)       // Wraps a DecodingError
    case tokenError(String)             // Specific issues during token acquisition not covered by other cases
    case authenticationFailed           // For 401/403 errors, specifically for token or data requests
    case rateLimitExceeded(retryAfter: Int?) // For 429 errors
    // case noDataReceived // Could be added if differentiation from invalidResponse is needed
}
