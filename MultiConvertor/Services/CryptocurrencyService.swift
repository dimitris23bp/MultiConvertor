import CloudKit

protocol CryptocurrencyServiceProtocol: Sendable {
	func ensureInitialDataIfNeeded(minCount: Int) async throws
	func updateAmountOfCryptos() async
	func getLastUpdate() async -> String
}

actor CryptocurrencyService: CryptocurrencyServiceProtocol {

	private let repository: AllRepository
	private let cloudkitService: CloudKitServiceProtocol

	init(repository: AllRepository, cloudKitService: CloudKitServiceProtocol) {
		self.repository = repository
		self.cloudkitService = cloudKitService
	}

	/// Ensures initial data exists by inserting from the remote API when the store is nearly empty.
	/// - Parameter minCount: Minimum number of records considered "seeded".
	func ensureInitialDataIfNeeded(minCount: Int = 3) async throws {
		let current = await repository.fetchAllIDs(
			withType: Cryptocurrency.self
		)
		// If I have 3 or more, return
		guard current.count < minCount else { return }

		print("Fetching initial cryptocurrencies")
		let cryptocurrencyDTOs =
			try await cloudkitService.fetchCryptocurrenciesFromCK(
				amount: initialCryptosSize
			)

		await repository.save(
			currencies: cryptocurrencyDTOs,
			withType: CryptocurrencyDTO.self
		)

		print("Initial cryptocurrencies are saved")
	}

	// TODO: Can I skip entirely this function? I may not need to do it, and just keep this little logic in the CurrencyService or in the Repo
	func ensureRemainingData() async {
		print("Adding remaining data")

		let ids = await repository.fetchAllIDs(withType: Cryptocurrency.self)

		let cloudkitServiceSelf = self.cloudkitService

		// Perform work in a separate Task that isn't bound to the MainActor
		Task.detached(priority: .utility) { [repository] in
			let allCryptoDTOs =
				await cloudkitServiceSelf.fetchAllCryptocurrenciesFromCK()
			await repository.addIfDontExist(
				withType: CryptocurrencyDTO.self,
				ids: ids,
				currencies: allCryptoDTOs
			)
		}

		print("Remaining cryptos are saved")
	}

	func updateAmountOfCryptos() async {
		let incomingCryptos =
			await cloudkitService.fetchAllCryptocurrenciesFromCK()

		await repository.updateAmounts(
			withType: CryptocurrencyDTO.self,
			currencies: incomingCryptos
		)
	}

	func getLastUpdate() async -> String {
		if let lastUpdate = await cloudkitService.getLastUpdate(
			of: "Cryptocurrency"
		) {
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			formatter.timeStyle = .medium
			return formatter.string(from: lastUpdate)
		} else {
			return "NaN"
		}
	}
}
