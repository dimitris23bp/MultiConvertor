//
//  CryptoService.swift
//  CryptoConverter
//
//  Created by Dimitris Karamanis on 27/9/25.
//

import Foundation

// MARK: - Models

struct TickersResponse: Decodable {
    let data: [CryptoTicker]
    let info: Info
}

struct CryptoTicker: Decodable {
    let id: String
    let symbol: String
    let name: String
    let nameid: String // API uses "nameid" without underscore; keep as-is to avoid custom CodingKeys
    let rank: Int

    // Many numeric fields are returned as strings by the API; keep them as String for lossless decoding.
    let priceUsd: String
    let priceBtc: String
    let marketCapUsd: String

    // These are numeric in the sample payload
    let volume24: Double
    let volume24a: Double
}

struct Info: Decodable {
    let coinsNum: Int
    let time: Int
}

// MARK: - Service

/// A service responsible for fetching cryptocurrency tickers from Coinlore's public API.
/// This service does not cache responses.
final class CryptoService {
    private let session: URLSession

    /// Initializes the service with a default URLSession to avoid any caching.
    /// - Parameter session: A URLSession. Defaults to a default session.
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }

    /// Fetches cryptocurrency tickers.
    /// - Parameters:
    ///   - start: The starting index for pagination (e.g., 0, 100, 200...).
    ///   - limit: The number of items to return.
    /// - Returns: An array of `CryptoTicker` items.
    /// - Throws: An error if the request fails or decoding fails.
    @discardableResult
    func fetchTickers(start: Int? = nil, limit: Int? = nil) async throws -> [CryptoTicker] {
        let response = try await fetchTickersResponse(start: start, limit: limit)
        return response.data
    }

    /// Fetches the full response, including `info` metadata.
    /// - Parameters:
    ///   - start: The starting index for pagination.
    ///   - limit: The number of items to return.
    /// - Returns: A `TickersResponse` containing tickers and metadata.
    func fetchTickersResponse(start: Int?, limit: Int?) async throws -> TickersResponse {
        var components = URLComponents(string: "https://api.coinlore.net/api/tickers/")!
		if start != nil && limit != nil {
			components.queryItems = [
				URLQueryItem(name: "start", value: String(start!)),
				URLQueryItem(name: "limit", value: String(limit!))
			]
		}

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let request = URLRequest(url: url)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(TickersResponse.self, from: data)
    }
}
