//
//  CryptoRepository.swift
//  CryptoConverter
//
//  Created by Assistant on 10/3/25.
//

import Foundation
import SwiftData

/// A repository responsible for fetching and updating crypto data and images,
/// keeping SwiftData mutations on the main actor.
@MainActor
final class CryptoRepository {
    private let modelContext: ModelContext
    private let cryptoService: CryptoService
    private let imageService: ImageService

    /// Convenience initializer that constructs default services on the main actor to avoid
    /// evaluating default arguments in a nonisolated context.
    convenience init(modelContext: ModelContext) {
        self.init(modelContext: modelContext,
                  cryptoService: CryptoService(),
                  imageService: ImageService())
    }

    init(modelContext: ModelContext,
         cryptoService: CryptoService,
         imageService: ImageService) {
        self.modelContext = modelContext
        self.cryptoService = cryptoService
        self.imageService = imageService
    }

    // MARK: - Public API

    /// Ensures initial data exists by inserting from the remote API when the store is nearly empty.
    /// Marks BTC and ETH as favourites, saves once, and then fetches/stores logos.
    /// - Parameter minCount: Minimum number of records considered "seeded".
    func ensureInitialDataIfNeeded(minCount: Int = 3) async throws {
        let current = try fetchAllCryptos()
        guard current.count < minCount else { return }

        let tickers = try await cryptoService.fetchTickers()
        for ticker in tickers {
            if let crypto = CryptoCurrency(ticker: ticker) {
                if crypto.id == "BTC" || crypto.id == "ETH" {
                    crypto.favourite = true
                }
                modelContext.insert(crypto)
            }
        }

        try modelContext.save()

        // Fetch and store logos for all cryptos after seeding.
        try await fetchAndStoreLogosForAll()
    }

    /// Updates existing crypto values and market caps from the remote API.
    func updateTickerValues() async throws {
        let tickers = try await cryptoService.fetchTickers()
        let existing = try fetchAllCryptos()

        for ticker in tickers {
            if let incoming = CryptoCurrency(ticker: ticker),
               let match = existing.first(where: { $0.id == incoming.id }) {
                match.value = incoming.value
                match.marketCap = incoming.marketCap
            }
        }
    }

    /// Fetches logo URLs for all known cryptos and stores the image data.
    /// Saves after each image assignment to mirror the previous behavior.
    private func fetchAndStoreLogosForAll() async throws {
        let all = try fetchAllCryptos()
        guard !all.isEmpty else { return }

        let ids = all.map { $0.id }
        let idsAndUrls = try await imageService.fetchLogoURLs(for: ids)

        for crypto in all {
			// TODO: Why is this a guard let and not an if let? I skip one inner statement, but is there anything else to it?
            guard let url = idsAndUrls[crypto.id] else { continue }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                crypto.imageData = data
                try modelContext.save()
            } catch {
                // Continue on individual failures but surface the error in logs.
                print("Failed to fetch/store image for \(crypto.id):", error)
            }
        }
    }

    // MARK: - Helpers

    private func fetchAllCryptos() throws -> [CryptoCurrency] {
        try modelContext.fetch(FetchDescriptor<CryptoCurrency>())
    }
}
