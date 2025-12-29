import Foundation
import SwiftData

/// A repository responsible for fetching and updating crypto data in *local storage*.
/// keeping SwiftData mutations on the main actor.
@MainActor
final class CryptoRepository {
	private let modelContext: ModelContext

	init(modelContext: ModelContext) {
		self.modelContext = modelContext
	}

    func addInitialFavourites(cryptocurrencies: [Cryptocurrency]) async throws {
        for crypto in cryptocurrencies {
            if crypto.id == "BTC" || crypto.id == "ETH" {
                crypto.sortOrder = getHighestOrder() + 1
                crypto.favourite = true
            }
        }
        try modelContext.save()
        print("Initial favourites have been added")

    }
    
    func saveCryptos(dtos: [CryptocurrencyDTO]) async throws {
        for dto in dtos {
            let crypto = Cryptocurrency(dto: dto)
            print("Fetching crypto with ID: \(crypto.id)")
            if crypto.renderedLogoData != nil {
                print("Inserting crypto with ID: \(crypto.id)")
                modelContext.insert(crypto)
            }
        }
        
        try modelContext.save()
    }
    
    func addCryptosIfDontExist(ids: Set<String>, dtos: [CryptocurrencyDTO]) throws {
        print("Adding remaining data")
        
        // Get a reference to the container (which is thread-safe)
        let container = modelContext.container
        
        // Create a background context
        let backgroundContext = ModelContext(container)
        
        for dto in dtos {
            let crypto = Cryptocurrency(dto: dto)
            print("Fetching crypto in remaining with ID: \(crypto.id)")
            if !ids.contains(crypto.id) {
                if crypto.renderedLogoData != nil {
                    print("Inserting crypto in remaining with ID: \(crypto.id)")
                    backgroundContext.insert(crypto)
                }
            }
        }
        try backgroundContext.save()
    }

    /// Updates existing crypto values and market caps from CloudKit's public Database.
    func updateAmounts(incomingCryptos: [CryptocurrencyDTO]) {
        let existingCryptos = fetchAllCryptos()
        for incoming in incomingCryptos {
            if let match = existingCryptos.first(where: { $0.id == incoming.id }) {
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

    func fetchAllCryptos() -> [Cryptocurrency] {
        if let cryptos = try? modelContext.fetch(FetchDescriptor<Cryptocurrency>()) {
            return cryptos
        } else {
            print("Couldn't fetch cryptos. Returning an empty list instead.")
            return []
        }
    }
    
    func fetchAllCryptoIDs() -> Set<String> {
        if let cryptos = try? modelContext.fetch(FetchDescriptor<Cryptocurrency>()) {
            return Set(cryptos.map(\.id))
        } else {
            return []
        }
    }
}
