import SwiftData

@MainActor
final class AllRepository {
    
    private let modelContext: ModelContext
    private let cryptoRepo: CryptoRepository
    private let fiatRepo: FiatRepository

    init(modelContext: ModelContext, cryptoRepo: CryptoRepository, fiatRepo: FiatRepository) {
        self.modelContext = modelContext
        self.cryptoRepo = cryptoRepo
        self.fiatRepo = fiatRepo
    }

    private func executeTypedAction<T: CurrencyDTO>(
        withType type: T.Type,
        currencies: [T],
        cryptoAction: ([CryptocurrencyDTO]) async throws -> Void,
        fiatAction: ([FiatCurrencyDTO]) async throws -> Void
    ) async throws {
        switch type {
        case is CryptocurrencyDTO.Type:
            guard let cryptos = currencies as? [CryptocurrencyDTO] else {
                print("Type mismatch: Expected [CryptocurrencyDTO]")
                return
            }
            try await cryptoAction(cryptos)
            
        case is FiatCurrencyDTO.Type:
            guard let fiats = currencies as? [FiatCurrencyDTO] else {
                print("Type mismatch: Expected [FiatCurrencyDTO]")
                return
            }
            try await fiatAction(fiats)
            
        default:
            print("Unrecognized type: \(type)")
        }
    }
    
    func save<T: CurrencyDTO>(currencies: [T], withType type: T.Type) async throws {
        try await executeTypedAction(
            withType: type,
            currencies: currencies,
            cryptoAction: { try await cryptoRepo.saveCryptos(dtos: $0) },
            fiatAction: { try await fiatRepo.saveFiats(dtos: $0) }
        )
    }

    func addIfDontExist<T: CurrencyDTO>(withType type: T.Type, ids: Set<String>, currencies: [T]) async throws {
        try await executeTypedAction(
            withType: type,
            currencies: currencies,
            cryptoAction: { try cryptoRepo.addCryptosIfDontExist(ids: ids, dtos: $0) },
            fiatAction: { try fiatRepo.addFiatsIfDontExist(ids: ids, dtos: $0) }
        )
    }
    
    func updateAmounts<T: CurrencyDTO>(withType type: T.Type, currencies: [T]) async throws {
       try await executeTypedAction(
        withType: type,
        currencies: currencies,
        cryptoAction: { cryptoRepo.updateAmounts(incomingCryptos: $0) },
        fiatAction: { fiatRepo.updateAmounts(incomings: $0) }
       )
    }
    
    func addInitialFavourites() async throws {
		let cryptoFetchDescriptor = FetchDescriptor<Cryptocurrency>()
		let cryptocurrencies = (try? modelContext.fetch(cryptoFetchDescriptor)) ?? []
		let fiatFetchDescriptor = FetchDescriptor<FiatCurrency>()
		let fiatCurrencies = (try? modelContext.fetch(fiatFetchDescriptor)) ?? []

		let currencies = (cryptocurrencies as [any Currency]) + (fiatCurrencies as [any Currency])

        for currency in currencies {
            if currency.id == "BTC" || currency.id == "ETH" || currency.id == "USD" || currency.id == "EUR" {
                currency.sortOrder = currencies.getHighestOrder() + 1
                currency.favourite = true
            }
        }
        
        try modelContext.save()
        print("Initial favourites have been added")
    }
    
    func fetchAll<T: PersistentModel>(fromType type: T.Type) -> [T] {
        let descriptor = FetchDescriptor<T>()
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Couldn't fetch \(T.self). Error: \(error)")
            return []
        }
    }
    
    func fetchAllIDs<T: PersistentModel & Identifiable>(withType type: T.Type) -> Set<String> where T.ID == String {
        let descriptor = FetchDescriptor<T>()
        
        if let results = try? modelContext.fetch(descriptor) {
            return Set(results.map(\.id))
        } else {
            return []
        }
    }

}
