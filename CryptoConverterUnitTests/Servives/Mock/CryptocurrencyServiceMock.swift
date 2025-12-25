import Foundation
@testable import CryptoConverter

@MainActor
final class CryptocurrencyServiceMock: CryptocurrencyServiceProtocol {
	var mockCryptocurrencies: [CryptocurrencyDTO] = []
	var fetchAllCalled = false
	var fetchWithAmountCalledCount = 0
	var fetchWithAmountLastAmount = 0
	var shouldThrowError = false

	func fetchAllCryptocurrenciesFromCK() async -> [CryptocurrencyDTO] {
		fetchAllCalled = true
		return mockCryptocurrencies
	}

	func fetchCryptocurrencies(amount: Int) async throws -> [CryptocurrencyDTO] {
		fetchWithAmountCalledCount += 1
		fetchWithAmountLastAmount = amount
		if shouldThrowError {
			throw NSError(domain: "MockError", code: 1, userInfo: nil)
		}
		return mockCryptocurrencies
	}
}
