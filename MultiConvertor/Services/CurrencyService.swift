import SwiftUI

protocol CurrencyServiceProtocol: Sendable {
	func ensureInitialDataIfNeeded(minCount: Int) async throws
	func updateAmounts() async
	func getLastUpdate(of type: String) async -> String
}

actor CurrencyService: CurrencyServiceProtocol {
	private let fiatService: FiatCurrencyService
	private let cryptoService: CryptocurrencyService
	private let currencyRepository: AllRepository

	init(
		fiatService: FiatCurrencyService,
		cryptoService: CryptocurrencyService,
		currencyRepository: AllRepository
	) {
		self.fiatService = fiatService
		self.cryptoService = cryptoService
		self.currencyRepository = currencyRepository
	}

	func ensureInitialDataIfNeeded(minCount: Int = 3) async throws {
		async let fiatData: () = fiatService.ensureInitialDataIfNeeded(
			minCount: minCount
		)
		async let cryptoData: () = cryptoService.ensureInitialDataIfNeeded(
			minCount: minCount
		)

		_ = try await [fiatData, cryptoData]
	}

	func ensureRemainingData() async {
		async let fiatData: () = fiatService.ensureRemainingData()
		async let cryptoData: () = cryptoService.ensureRemainingData()

		_ = await [fiatData, cryptoData]
	}

	func updateAmounts() async {
		async let updateFiatData: () = fiatService.updateAmountOfFiats()
		async let updateCryptoData: () = cryptoService.updateAmountOfCryptos()

		_ = await [updateFiatData, updateCryptoData]
	}

	// This could be from either crypto of fiat. Since they are updated at the same time, I don't have to get a specific one.
	func getLastUpdate(of type: String) async -> String {
		if type == "Cryptocurrency" {
			return await cryptoService.getLastUpdate()
		} else {
			return await fiatService.getLastUpdate()
		}
	}

	func addInitialFavourites() async {
		do {
			try await currencyRepository.addInitialFavourites()
		} catch {
			print("Cannot add successfully all favourites.")
		}
	}
}

// MARK: - Environment Setup

struct CurrencyServiceKey: EnvironmentKey {
	// If it is not provided on the top level, return nil
	static let defaultValue: CurrencyService? = nil
}

extension EnvironmentValues {
	var currencyService: CurrencyService? {
		get { self[CurrencyServiceKey.self] }
		set { self[CurrencyServiceKey.self] = newValue }
	}
}
