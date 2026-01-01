import CloudKit
import SVGKit

protocol CryptocurrencyServiceProtocol: Sendable {
    func ensureInitialDataIfNeeded(minCount: Int) async throws
	func getLastUpdate() async -> String
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
        let current = await cryptoRepository.fetchAllCryptoIDs()
        // If I have 3 or more, return
        guard current.count < minCount else { return }

        print("Fetching initial cryptocurrencies")
        let cryptocurrencyDTOs = try await cloudkitService.fetchCryptocurrenciesFromCK(amount: 50)
        
        try await cryptoRepository.saveCryptos(dtos: cryptocurrencyDTOs)
        
        print("Initial cryptocurrencies are saved")
        
        // Remaining data will be saved asynchronously to not wait for them in the first install of the app
        await ensureRemainingData()
    }
    
    private func ensureRemainingData() async {
        print("Adding remaining data")
        
        let ids = await cryptoRepository.fetchAllCryptoIDs()

        let cloudkitServiceSelf = self.cloudkitService
        
        // Perform work in a separate Task that isn't bound to the MainActor
        Task.detached(priority: .utility) { [weak cryptoRepository] in
            let allCryptoDTOs = await cloudkitServiceSelf.fetchAllCryptocurrenciesFromCK()
            try? await cryptoRepository?.addCryptosIfDontExist(ids: ids, dtos: allCryptoDTOs)
        }
        
        print("Remaining cryptos are saved")
    }
    
    func updateAmountOfCryptos() async {
        let incomingCryptos = await cloudkitService.fetchAllCryptocurrenciesFromCK()

        await cryptoRepository.updateAmounts(incomingCryptos: incomingCryptos)
   }

	func getLastUpdate() async -> String {
        if let lastUpdate = await cloudkitService.getLastUpdate() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            return formatter.string(from: lastUpdate)
        } else {
            return "NaN"
        }
	}
}
