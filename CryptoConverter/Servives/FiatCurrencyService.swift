import CloudKit

protocol FiatCurrencyServiceProtocol: Sendable {
    func ensureInitialDataIfNeeded(minCount: Int) async throws
    func updateAmountOfFiats() async
}

actor FiatCurrencyService : FiatCurrencyServiceProtocol {
    
    nonisolated let publicDatabase = CKContainer.default().publicCloudDatabase
    private let repository: AllRepository
    private let cloudkitService: CloudKitServiceProtocol
    
    init(repository: AllRepository, cloudkitService: CloudKitServiceProtocol) {
        self.repository = repository
        self.cloudkitService = cloudkitService
    }
    
    /// Ensures initial data exists by inserting from the remote API when the store is nearly empty.
    /// - Parameter minCount: Minimum number of records considered "seeded".
    func ensureInitialDataIfNeeded(minCount: Int = 3) async throws {
		let current = await repository.fetchAllIDs(withType: FiatCurrency.self)
        // If I have 3 or more, return
        guard current.count < minCount else { return }

        print("Fetching initial fiat currencies")
        let fiatDTOs = try await cloudkitService.fetchFiatCurrenciesFromCK(amount: 20)

		try await repository.save(currencies: fiatDTOs, withType: FiatCurrencyDTO.self)
        print("Initial fiatCurrencies are saved")

		// TODO: This shouldn't be here. Logically doesn't make sense and it's hard to track it down
        // Remaining data will be saved asynchronously to not wait for them in the first install of the app
        await ensureRemainingData()
    }
    
    func updateAmountOfFiats() async {
        let incomingFiats = await cloudkitService.fetchAllFiatCurrenciesFromCK()
		try? await repository.updateAmounts(withType: FiatCurrencyDTO.self, currencies: incomingFiats)
   }
    
    private func ensureRemainingData() async {
        print("Adding remaining data")
        
		let ids = await repository.fetchAllIDs(withType: FiatCurrency.self)

        let cloudkitServiceSelf = self.cloudkitService
        
        // Perform work in a separate Task that isn't bound to the MainActor
        Task.detached(priority: .utility) { [repository] in
            let allFiatDTOs = await cloudkitServiceSelf.fetchAllFiatCurrenciesFromCK()
			try? await repository.addIfDontExist(withType: FiatCurrencyDTO.self, ids: ids, currencies: allFiatDTOs)
        }
        
        print("Remaining fiats are saved")
    }
}
