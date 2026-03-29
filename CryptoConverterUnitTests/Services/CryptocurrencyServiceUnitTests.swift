import XCTest
import SwiftData
@testable import CryptoConverter

@MainActor
final class CryptocurrencyServiceUnitTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var cryptoRepository: CryptoRepository!
    var fiatRepository: FiatRepository!
    var allRepository: AllRepository!
    var mockCloudKitService: CloudKitServiceMock!
    var service: CryptocurrencyService!

    override func setUp() async throws {
        let schema = Schema([Cryptocurrency.self, FiatCurrency.self, AppSettings.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
        
        cryptoRepository = CryptoRepository(modelContext: modelContext)
        fiatRepository = FiatRepository(modelContext: modelContext)
        allRepository = AllRepository(modelContext: modelContext, cryptoRepo: cryptoRepository, fiatRepo: fiatRepository)
        
        mockCloudKitService = CloudKitServiceMock()
        service = CryptocurrencyService(repository: allRepository, cloudKitService: mockCloudKitService)
    }

    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        cryptoRepository = nil
        fiatRepository = nil
        allRepository = nil
        mockCloudKitService = nil
        service = nil
    }

    func testEnsureInitialDataIfNeeded_WhenStoreIsEmpty_FetchesFromCloudKitAndSaves() async throws {
        // Arrange
        let mockDTO = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, iconData: nil)
        mockCloudKitService.mockCryptocurrencies = [mockDTO]

        // Act
        try await service.ensureInitialDataIfNeeded(minCount: 1)

        // Assert
        // Verify CloudKit fetch was called
        XCTAssertEqual(mockCloudKitService.fetchWithAmountCalledCount, 1)
        
        // Verify data was saved to repository (ModelContext)
        let savedCryptos = cryptoRepository.fetchAllCryptos()
        XCTAssertEqual(savedCryptos.count, 1)
        XCTAssertEqual(savedCryptos.first?.id, "BTC")
    }

    func testEnsureInitialDataIfNeeded_WhenStoreHasData_DoesNotFetch() async throws {
        // Arrange
        // Seed the repository using AllRepository's save to match service logic
        let dto = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, iconData: nil)
        await allRepository.save(currencies: [dto], withType: CryptocurrencyDTO.self)
        
        mockCloudKitService.mockCryptocurrencies = []

        // Act
        try await service.ensureInitialDataIfNeeded(minCount: 1)

        // Assert
        XCTAssertEqual(mockCloudKitService.fetchWithAmountCalledCount, 0)
    }
}
