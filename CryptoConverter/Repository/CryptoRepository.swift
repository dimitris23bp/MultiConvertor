//
//  CryptoRepository.swift
//  CryptoConverter
//
//  Created by Assistant on 10/3/25.
//

import Foundation
import SwiftData
import SwiftUI

/// A repository responsible for fetching and updating crypto data,
/// keeping SwiftData mutations on the main actor.
@MainActor
final class CryptoRepository {
    private let modelContext: ModelContext
    private let cryptoService: CryptoService

    /// Convenience initializer that constructs default services on the main actor to avoid
    /// evaluating default arguments in a nonisolated context.
    convenience init(modelContext: ModelContext) {
        self.init(modelContext: modelContext,
                  cryptoService: CryptoService())
    }

    init(modelContext: ModelContext,
         cryptoService: CryptoService) {
        self.modelContext = modelContext
        self.cryptoService = cryptoService
    }

    // MARK: - Public API

    /// Ensures initial data exists by inserting from the remote API when the store is nearly empty.
    /// - Parameter minCount: Minimum number of records considered "seeded".
    func ensureInitialDataIfNeeded(minCount: Int = 3) async throws {
        let current = fetchAllCryptos()
        guard current.count < minCount else { return }

        let tickers = try await cryptoService.fetchTickers()
        for ticker in tickers {
			if UIImage(named: ticker.symbol.lowercased()) != nil {
				if let crypto = CryptoCurrency(ticker: ticker) {
					if crypto.id == "BTC" || crypto.id == "ETH" {
						crypto.sortOrder = getHighestOrder() + 1
						crypto.favourite = true
					}
					modelContext.insert(crypto)
				}
			} else {
				print("\(ticker.symbol) doesn't have an image")
			}
        }

        try modelContext.save()
    }

    /// Updates existing crypto values and market caps from the remote API.
    func updateTickerValues() async throws {
        let tickers = try await cryptoService.fetchTickers()
        let existing = fetchAllCryptos()

        for ticker in tickers {
            if let incoming = CryptoCurrency(ticker: ticker),
               let match = existing.first(where: { $0.id == incoming.id }) {
                match.value = incoming.value
                match.marketCap = incoming.marketCap
            }
        }
    }

	func getHighestOrder() -> Int {
		var highest = 0
		let cryptocurrencies = fetchAllCryptos()

		cryptocurrencies.filter(\.favourite).forEach { cryptocurrency in
			guard let sortOrder = cryptocurrency.sortOrder else {
				print("SortOrder is nil for \(cryptocurrency.id) while is it favourite: \(cryptocurrency.favourite).")
				return
			}
			if sortOrder > highest {
				highest = sortOrder
			}
		}
		return highest
	}


    // MARK: - Helpers

    private func fetchAllCryptos() -> [CryptoCurrency] {
        if let cryptos = try? modelContext.fetch(FetchDescriptor<CryptoCurrency>()) {
            return cryptos
        } else {
            print("Couldn't fetch cryptos. Returning an empty list instead.")
            return []
        }
    }
}
