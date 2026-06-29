import XCTest
import SwiftData
@testable import MultiConvertor

@MainActor
final class CurrencyServiceTest: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var cryptoRepository: CryptoRepository!
    var fiatRepository: FiatRepository!
    var allRepository: AllRepository!
    var mockCloudKitService: CloudKitServiceMock!
    var cryptoService: CryptocurrencyService!
    var fiatService: FiatCurrencyService!
    var service: CurrencyService!

    override func setUp() async throws {
        let schema = Schema([Cryptocurrency.self, FiatCurrency.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        modelContext = modelContainer.mainContext
        
        cryptoRepository = CryptoRepository(modelContext: modelContext)
        fiatRepository = FiatRepository(modelContext: modelContext)
        allRepository = AllRepository(modelContext: modelContext, cryptoRepo: cryptoRepository, fiatRepo: fiatRepository)
        
        mockCloudKitService = CloudKitServiceMock()
        
        cryptoService = CryptocurrencyService(repository: allRepository, cloudKitService: mockCloudKitService)
        fiatService = FiatCurrencyService(repository: allRepository, cloudkitService: mockCloudKitService)
        
        service = CurrencyService(
            fiatService: fiatService,
            cryptoService: cryptoService,
            currencyRepository: allRepository
        )
    }

    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        cryptoRepository = nil
        fiatRepository = nil
        allRepository = nil
        mockCloudKitService = nil
        cryptoService = nil
        fiatService = nil
        service = nil
    }

    func testGetLastUpdate_ReturnsCorrectValuesForBothTypes() async {
        // Arrange
        let cryptoDate = Date(timeIntervalSince1970: 1711920000) // 2024-03-31 21:20:00
        let fiatDate = Date(timeIntervalSince1970: 1711833600)   // 2024-03-30 21:20:00
        
        mockCloudKitService.mockLastUpdateDates = [
            "Cryptocurrency": cryptoDate,
            "FiatCurrency": fiatDate
        ]

        // Act
        async let cryptoUpdate = service.getLastUpdate(of: "Cryptocurrency")
        async let fiatUpdate = service.getLastUpdate(of: "FiatCurrency")

        let (crypto, fiat) = await (cryptoUpdate, fiatUpdate)

        // Assert
        XCTAssertNotEqual(crypto, "NaN")
        XCTAssertNotEqual(fiat, "NaN")
        XCTAssertNotEqual(crypto, fiat, "Crypto and Fiat updates should be different if dates are different")
        
        print("Crypto update string: \(crypto)")
        print("Fiat update string: \(fiat)")
    }

    func testGetLastUpdate_ReturnsNaNWhenCloudKitReturnsNil() async {
        // Arrange
        mockCloudKitService.mockLastUpdateDates = [
            "Cryptocurrency": nil,
            "FiatCurrency": nil
        ]

        // Act
        let crypto = await service.getLastUpdate(of: "Cryptocurrency")
        let fiat = await service.getLastUpdate(of: "FiatCurrency")

        // Assert
        XCTAssertEqual(crypto, "NaN")
        XCTAssertEqual(fiat, "NaN")
    }
}
