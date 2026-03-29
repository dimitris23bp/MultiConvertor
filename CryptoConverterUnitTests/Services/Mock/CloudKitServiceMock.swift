//import Foundation
//@testable import CryptoConverter
//
//final class CloudKitServiceMock: CloudKitServiceProtocol, @unchecked Sendable {
//    var mockCryptocurrencies: [CryptocurrencyDTO] = []
//    var fetchAllCalled = false
//    var fetchWithAmountCalledCount = 0
//    var fetchWithAmountLastAmount = 0
//    var shouldThrowError = false
//
//    func fetchAllCryptocurrenciesFromCK() async -> [CryptocurrencyDTO] {
//        fetchAllCalled = true
//        return mockCryptocurrencies
//    }
//
//    func fetchCryptocurrenciesFromCK(amount: Int) async throws -> [CryptocurrencyDTO] {
//        fetchWithAmountCalledCount += 1
//        fetchWithAmountLastAmount = amount
//        if shouldThrowError {
//            throw NSError(domain: "MockError", code: 1, userInfo: nil)
//        }
//        return mockCryptocurrencies
//    }
//    
//    func fetchAllFiatCurrenciesFromCK() async -> [FiatCurrencyDTO] {
//        return []
//    }
//
//    func fetchFiatCurrenciesFromCK(amount: Int) async throws -> [FiatCurrencyDTO] {
//        return []
//    }
//    
//    var mockLastUpdateDate: Date?
//    func getLastUpdate(of type: String) async -> Date? {
//        return mockLastUpdateDate
//    }
//}
