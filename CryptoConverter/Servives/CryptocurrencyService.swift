import CloudKit
import SVGKit

protocol CryptocurrencyServiceProtocol: Sendable {
    func ensureInitialDataIfNeeded(minCount: Int) async throws
}

actor CryptocurrencyService: CryptocurrencyServiceProtocol {
    
    nonisolated let publicDatabase = CKContainer.default().publicCloudDatabase
    private let cryptoRepository: CryptoRepository
    private let cloudkitService: CloudKitServiceProtocol
    
    init(repository: CryptoRepository, cloudKitService: CloudKitServiceProtocol) {
        self.cryptoRepository = repository
        self.cloudkitService = cloudKitService
    }

    /// Ensures initial data exists by inserting from the remote API when the store is nearly empty.
    /// - Parameter minCount: Minimum number of records considered "seeded".
    func ensureInitialDataIfNeeded(minCount: Int = 3) async throws {
        // TODO: Fetch only the IDs
        let current = await cryptoRepository.fetchAllCryptos()
        // If I have 3 or more, return
        guard current.count < minCount else { return }

        print("Fetching initial cryptocurrencies")
        let cryptocurrencyDTOs = try await cloudkitService.fetchCryptocurrenciesFromCK(amount: 50)
        let cryptocurrencies = cryptocurrencyDTOs.map { Cryptocurrency(dto: $0) }
        
        try await cryptoRepository.saveCryptos(cryptocurrencies: cryptocurrencies)
        
        print("Initial cryptocurrencies are saved")
        
        // Remaining data will be saved asynchronously to not wait for them in the first install of the app
        await ensureRemainingData()
    }
    
    private func ensureRemainingData() async {
        print("Adding remaining data")
        
        // TODO: Fetch only the IDs
        let current: [Cryptocurrency] = await cryptoRepository.fetchAllCryptos()
        let ids = Set(current.map(\.id))

        let cloudkitServiceSelf = self.cloudkitService
        
        // Perform work in a separate Task that isn't bound to the MainActor
        Task.detached(priority: .utility) { [weak cryptoRepository] in
            let allCryptoDTOs = await cloudkitServiceSelf.fetchAllCryptocurrenciesFromCK()
            let allCryptos = allCryptoDTOs.map { Cryptocurrency(dto: $0) }
            try? await cryptoRepository?.addCryptosIfDontExist(ids: ids, allCryptos: allCryptos)
        }
        
        print("Remaining cryptos are saved")
    }
    
    func updateAmountOfCryptos() async {
        let incomingCryptos = await cloudkitService.fetchAllCryptocurrenciesFromCK()
        let existingCryptos = await cryptoRepository.fetchAllCryptos()

        await cryptoRepository.updateAmounts(incomingCryptos: incomingCryptos, existingCryptos: existingCryptos)
    }
}
