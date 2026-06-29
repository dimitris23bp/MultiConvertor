import Foundation
import SwiftData

@MainActor
final class FiatRepository {
	private let modelContext: ModelContext

	init(modelContext: ModelContext) {
		self.modelContext = modelContext
	}

	func fetchAllFiat() -> [FiatCurrency] {
		if let fiatCurrencies = try? modelContext.fetch(
			FetchDescriptor<FiatCurrency>()
		) {
			return fiatCurrencies
		} else {
			print(
				"Couldn't fetch fiat currencies. Returning an empty list instead."
			)
			return []
		}
	}

	func saveFiats(dtos: [FiatCurrencyDTO]) async throws {
		for dto in dtos {
			let fiat = FiatCurrency(dto: dto)
			print("Inserting fiat with ID: \(fiat.id)")
			modelContext.insert(fiat)
		}

		try modelContext.save()
	}

	func addFiatsIfDontExist(ids: Set<String>, dtos: [FiatCurrencyDTO]) throws {
		print("Adding remaining data")

		// Get a reference to the container (which is thread-safe)
		let container = modelContext.container

		// Create a background context
		let backgroundContext = ModelContext(container)

		for dto in dtos {
			let fiat = FiatCurrency(dto: dto)
			if !ids.contains(fiat.id) {
				print("Inserting fiat in remaining with ID: \(fiat.id)")
				backgroundContext.insert(fiat)
			}
		}
		try backgroundContext.save()
	}

	/// Updates existing crypto values and market caps from CloudKit's public Database.
	func updateAmounts(incomings: [FiatCurrencyDTO]) {
		let existingFiats = fetchAllFiat()
		// Map existing fiats to a dictionary by ID for O(1) lookup
		let existingDict = Dictionary(uniqueKeysWithValues: existingFiats.map { ($0.id, $0) })
		
		for incoming in incomings {
			if let match = existingDict[incoming.id] {
				match.value = incoming.value
			}
		}
	}

	func fetchAllFiatIDs() -> Set<String> {
		var descriptor = FetchDescriptor<FiatCurrency>()
		descriptor.propertiesToFetch = [\.id]

		if let fiats = try? modelContext.fetch(descriptor) {
			return Set(fiats.map(\.id))
		} else {
			return []
		}
	}
}
