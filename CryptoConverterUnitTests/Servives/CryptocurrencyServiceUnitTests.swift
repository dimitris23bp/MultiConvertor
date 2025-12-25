import XCTest
import SwiftData
@testable import CryptoConverter

final class CryptocurrencyServiceUnitTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var repository: CryptoRepository!
    var mockCloudKitService: CloudKitServiceMock!
    var service: CryptocurrencyService!

    @MainActor
    override func setUp() async throws {
        let schema = Schema([Cryptocurrency.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
        
        repository = CryptoRepository(modelContext: modelContext)
        mockCloudKitService = CloudKitServiceMock()
        service = CryptocurrencyService(repository: repository, cloudKitService: mockCloudKitService)
    }

    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        repository = nil
        mockCloudKitService = nil
        service = nil
    }

    func testEnsureInitialDataIfNeeded_WhenStoreIsEmpty_FetchesFromCloudKitAndSaves() async throws {
        // Arrange
        let dummyData = "preview".data(using: .utf8)
        let mockDTO = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, renderedLogoData: dummyData, favourite: false, sortOrder: nil)
        mockCloudKitService.mockCryptocurrencies = [mockDTO]

        // Act
        try await service.ensureInitialDataIfNeeded(minCount: 1)

        // Assert
        // Verify CloudKit fetch was called
        XCTAssertEqual(mockCloudKitService.fetchWithAmountCalledCount, 1)
        
        // Verify data was saved to repository (ModelContext)
        let savedCryptos = await repository.fetchAllCryptos()
        XCTAssertEqual(savedCryptos.count, 1)
        XCTAssertEqual(savedCryptos.first?.id, "BTC")
    }

    func testEnsureInitialDataIfNeeded_WhenStoreHasData_DoesNotFetch() async throws {
        // Arrange
        // Seed the repository directly
        let existingCrypto = Cryptocurrency(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, logoString: "preview")
        existingCrypto.renderedLogoData = Data() // Make sure it counts
        try await repository.saveCryptos(cryptocurrencies: [existingCrypto])
        
        mockCloudKitService.mockCryptocurrencies = []

        // Act
        try await service.ensureInitialDataIfNeeded(minCount: 1)

        // Assert
        XCTAssertEqual(mockCloudKitService.fetchWithAmountCalledCount, 0)
    }
}
