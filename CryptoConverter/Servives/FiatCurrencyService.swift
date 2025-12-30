import CloudKit

protocol FiatCurrencyServiceProtocol: Sendable {
    func ensureInitialDataIfNeeded(minCount: Int) async throws
    func updateAmountOfFiats() async
}

actor FiatCurrencyService : FiatCurrencyServiceProtocol {
    
    nonisolated let publicDatabase = CKContainer.default().publicCloudDatabase
    private let fiatRepository: FiatRepository
    private let cloudkitService: CloudKitServiceProtocol
    
    init(fiatRepository: FiatRepository, cloudkitService: CloudKitServiceProtocol) {
        self.fiatRepository = fiatRepository
        self.cloudkitService = cloudkitService
    }
    
    /// Ensures initial data exists by inserting from the remote API when the store is nearly empty.
    /// - Parameter minCount: Minimum number of records considered "seeded".
    func ensureInitialDataIfNeeded(minCount: Int = 3) async throws {
        // TODO: Fetch only the IDs
        let current = await fiatRepository.fetchAllFiat()
        // If I have 3 or more, return
        guard current.count < minCount else { return }

        print("Fetching initial fiat currencies")
        let fiatDTOs = try await cloudkitService.fetchFiatCurrenciesFromCK(amount: 20)

        try await fiatRepository.saveFiats(dtos: fiatDTOs)
        
        print("Initial fiatCurrencies are saved")
        
        // Remaining data will be saved asynchronously to not wait for them in the first install of the app
        await ensureRemainingData()
    }
    
    func updateAmountOfFiats() async {
        let incomingFiats = await cloudkitService.fetchAllFiatCurrenciesFromCK()
        await fiatRepository.updateAmounts(incomings: incomingFiats)
   }
    
    private func ensureRemainingData() async {
        print("Adding remaining data")
        
        let ids = await fiatRepository.fetchAllFiatIDs()

        let cloudkitServiceSelf = self.cloudkitService
        
        // Perform work in a separate Task that isn't bound to the MainActor
        Task.detached(priority: .utility) { [weak fiatRepository] in
            let allFiatDTOs = await cloudkitServiceSelf.fetchAllFiatCurrenciesFromCK()
            try? await fiatRepository?.addFiatsIfDontExist(ids: ids, dtos: allFiatDTOs)
        }
        
        print("Remaining fiats are saved")
    }
}
