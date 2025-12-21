import Foundation
import SwiftData
import SwiftUI

/// A repository responsible for fetching and updating crypto data in *local storage*.
/// keeping SwiftData mutations on the main actor.
@MainActor
final class CryptoRepository {
    private let modelContext: ModelContext
    private let cryptocurrencyService: CryptocurrencyService

    /// Convenience initializer that constructs default services on the main actor to avoid
    /// evaluating default arguments in a nonisolated context.
    convenience init(modelContext: ModelContext) {
        self.init(modelContext: modelContext,
                  cryptocurrencyService: CryptocurrencyService())
    }

    init(modelContext: ModelContext,
         cryptocurrencyService: CryptocurrencyService) {
        self.modelContext = modelContext
        self.cryptocurrencyService = cryptocurrencyService
    }

    // MARK: - Public API

    /// Ensures initial data exists by inserting from the remote API when the store is nearly empty.
    /// - Parameter minCount: Minimum number of records considered "seeded".
    func ensureInitialDataIfNeeded(minCount: Int = 3) async throws {
        let current = fetchAllCryptos()
        // If I have 3 or more, return
        guard current.count < minCount else { return }

        print("Fetching initial cryptocurrencies")
        let cryptocurrencies = try await cryptocurrencyService.fetchCryptocurrencies()
        for crypto in cryptocurrencies {
            print("Fetching crypto with ID: \(crypto.id)")
            if crypto.logo != nil {
                if crypto.id == "BTC" || crypto.id == "ETH" {
                    crypto.sortOrder = getHighestOrder() + 1
                    crypto.favourite = true
                }
                print("Inserting crypto with ID: \(crypto.id)")
                modelContext.insert(crypto)
			}
        }

        try modelContext.save()
        print("Initial cryptocurrencies are saved")
    }

    /// Updates existing crypto values and market caps from CloudKit's public Database.
    func updateAmounts() async throws {
        let cryptocurrenciesInCK = try await cryptocurrencyService.fetchCryptocurrencies()
        let existing = fetchAllCryptos()

        for incoming in cryptocurrenciesInCK {
            if let match = existing.first(where: { $0.id == incoming.id }) {
                match.value = incoming.value
                match.marketCap = incoming.marketCap
            }
        }
    }

    /// Get the new highest order.
    /// This is used when a new crypto is added to favourites and it needs a new value in sortOrder.
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

    private func fetchAllCryptos() -> [Cryptocurrency] {
        if let cryptos = try? modelContext.fetch(FetchDescriptor<Cryptocurrency>()) {
            return cryptos
        } else {
            print("Couldn't fetch cryptos. Returning an empty list instead.")
            return []
        }
    }
}
