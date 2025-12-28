import Foundation

protocol FiatCurrencyServiceProtocol: Sendable {
    func ensureInitialDataIfNeeded(minCount: Int) async throws
    func getLastUpdate() async -> String
}

//actor FiatCurrencyService : FiatCurrencyServiceProtocol {
//    
//    nonisolated let publicDatabase = CKContainer.default().publicCloudDatabase
//    private let cryptoRepository: CryptoRepository
//    private let cloudkitService: CloudKitServiceProtocol
//}
