import Foundation
@testable import CryptoConverter

@MainActor
final class CryptocurrencyServiceMock: CryptocurrencyServiceProtocol {
    var ensureInitialDataCalled = false
    var ensureInitialDataMinCount = 0
    var shouldThrowError = false

    func ensureInitialDataIfNeeded(minCount: Int) async throws {
        ensureInitialDataCalled = true
        ensureInitialDataMinCount = minCount
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
    }
    
    var mockLastUpdateString: String = "NaN"
    func getLastUpdate() async -> String {
        return mockLastUpdateString
    }
}
