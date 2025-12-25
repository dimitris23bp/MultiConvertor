import CloudKit
import SVGKit

protocol CryptocurrencyServiceProtocol: Sendable {
    func ensureInitialDataIfNeeded(minCount: Int) async throws
}

actor CryptocurrencyService: CryptocurrencyServiceProtocol {
    
    nonisolated let publicDatabase = CKContainer.default().publicCloudDatabase
    private let cryptoRepository = CryptoRepository()
    private let cloudkitService = CloudKitService()

    /// Ensures initial data exists by inserting from the remote API when the store is nearly empty.
    /// - Parameter minCount: Minimum number of records considered "seeded".
    func ensureInitialDataIfNeeded(minCount: Int = 3) async throws {
        // TODO: Fetch only the IDs
        let current = cryptoRepository.fetchAllCryptos()
        // If I have 3 or more, return
        guard current.count < minCount else { return }

        print("Fetching initial cryptocurrencies")
        let cryptocurrencyDTOs = try await cloudkitService.fetchCryptocurrenciesFromCK(amount: 50)
        let cryptocurrencies = cryptocurrencyDTOs.map { Cryptocurrency(dto: $0) }
        
        cryptoRepository.saveCryptos(cryptocurrencies)
        
        print("Initial cryptocurrencies are saved")
        
        // Remaining data will be saved asynchronously to not wait for them in the first install of the app
        await ensureRemainingData()
    }
    
    private func ensureRemainingData() async {
        print("Adding remaining data")
        
        // TODO: Fetch only the IDs
        let current: [Cryptocurrency] = cryptoRepository.fetchAllCryptos()
        let ids = Set(current.map(\.id))

        // Perform work in a separate Task that isn't bound to the MainActor
        Task.detached(priority: .utility) {
            let allCryptoDTOs = await cloudkitService.fetchAllCryptocurrenciesFromCK()
            let allCryptos = allCryptoDTOs.map { Cryptocurrency(dto: $0) }
            cryptoRepository.addCryptosIfDontExist(ids: ids, allCryptos: allCryptos)
        }
        
        print("Remaining cryptos are saved")
    }
    
    func updateAmountOfCryptos() async {
        let incomingCryptos = await cloudkitService.fetchAllCryptocurrenciesFromCK()
        let existingCryptos = cryptoRepository.fetchAllCryptos()

        cryptoRepository.updateAmountOfCryptos(incoming: incomingCryptos, existing: existingCryptos)
    }
}
