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
        let schema = Schema([Cryptocurrency.self, FiatCurrency.self])
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
        XCTAssertEqual(savedCryptos.count, 1, "Should have saved 1 crypto")
        XCTAssertEqual(savedCryptos.first?.id, "BTC")
    }

    func testEnsureInitialDataIfNeeded_WhenStoreHasData_DoesNotFetch() async throws {
        // Arrange
        let dto = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, iconData: nil)
        await allRepository.save(currencies: [dto], withType: CryptocurrencyDTO.self)
        
        mockCloudKitService.mockCryptocurrencies = []

        // Act
        try await service.ensureInitialDataIfNeeded(minCount: 1)

        // Assert
        XCTAssertEqual(mockCloudKitService.fetchWithAmountCalledCount, 0, "Should NOT have fetched from CloudKit")
    }

    func testUpdateAmountOfCryptos_UpdatesRepository() async throws {
        // Arrange
        let initialDTO = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 40000.0, marketCap: 800000.0, iconData: nil)
        await allRepository.save(currencies: [initialDTO], withType: CryptocurrencyDTO.self)
        
        let updatedDTO = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, iconData: nil)
        mockCloudKitService.mockCryptocurrencies = [updatedDTO]

        // Act
        await service.updateAmountOfCryptos()

        // Assert
        let savedCryptos = cryptoRepository.fetchAllCryptos()
        XCTAssertEqual(savedCryptos.first?.value, 50000.0)
        XCTAssertEqual(savedCryptos.first?.marketCap, 1000000.0)
    }

    func testGetLastUpdate_ReturnsFormattedString() async {
        // Arrange
        let testDate = Date(timeIntervalSince1970: 1711920000) // Some fixed date
        mockCloudKitService.mockLastUpdateDates["Cryptocurrency"] = testDate

        // Act
        let lastUpdate = await service.getLastUpdate()

        // Assert
        XCTAssertNotEqual(lastUpdate, "NaN")
        XCTAssertFalse(lastUpdate.isEmpty)
    }

    func testEnsureRemainingData_AddsNewCryptos() async throws {
        // Arrange
        let existingCrypto = Cryptocurrency(id: "BTC", name: "Bitcoin", value: 1.0, marketCap: 1.0, iconData: nil)
        modelContext.insert(existingCrypto)
        try modelContext.save()
        
        let ethDTO = CryptocurrencyDTO(id: "ETH", name: "Ethereum", value: 2000.0, marketCap: 200000.0, iconData: nil)
        let btcDTO = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 1.0, marketCap: 1.0, iconData: nil)
        mockCloudKitService.mockCryptocurrencies = [btcDTO, ethDTO]

        // Act
        await service.ensureRemainingData()
        
        // Assert
        // Since ensureRemainingData uses Task.detached, we need to wait a bit
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let allCryptos = cryptoRepository.fetchAllCryptos()
        XCTAssertEqual(allCryptos.count, 2, "Should have added ETH to existing BTC")
        XCTAssertTrue(allCryptos.contains(where: { $0.id == "ETH" }))
    }
}
