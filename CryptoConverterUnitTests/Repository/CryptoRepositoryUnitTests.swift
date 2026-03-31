import XCTest
import SwiftData
@testable import CryptoConverter

@MainActor
final class CryptoRepositoryUnitTests: XCTestCase {
	var modelContainer: ModelContainer!
	var modelContext: ModelContext!
	var repository: CryptoRepository!

	override func setUp() async throws {
		let schema = Schema([Cryptocurrency.self])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
		modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
		modelContext = modelContainer.mainContext
		repository = CryptoRepository(modelContext: modelContext)
	}

	override func tearDown() {
		modelContainer = nil
		modelContext = nil
		repository = nil
	}

    func testSaveCryptos_PersistsData() async throws {
        // Arrange
        let dto = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, iconData: nil)

        // Act
        try await repository.saveCryptos(dtos: [dto])

        // Assert
        let descriptor = FetchDescriptor<Cryptocurrency>()
        let savedCryptos = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(savedCryptos.count, 1)
        XCTAssertEqual(savedCryptos.first?.id, "BTC")
    }

    func testAddCryptosIfDontExist_AddsOnlyNew() async throws {
        // Arrange
        let btc = Cryptocurrency(id: "BTC", name: "Bitcoin", value: 1.0, marketCap: 1.0, iconData: nil)
        modelContext.insert(btc)
        try modelContext.save()
        
        let existingIDs: Set<String> = ["BTC"]
        let dtos = [
            CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 1.0, marketCap: 1.0, iconData: nil),
            CryptocurrencyDTO(id: "ETH", name: "Ethereum", value: 2000.0, marketCap: 200000.0, iconData: nil)
        ]

        // Act
        try repository.addCryptosIfDontExist(ids: existingIDs, dtos: dtos)

        // Assert
        let descriptor = FetchDescriptor<Cryptocurrency>()
        let savedCryptos = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(savedCryptos.count, 2)
        XCTAssertTrue(savedCryptos.contains(where: { $0.id == "BTC" }))
        XCTAssertTrue(savedCryptos.contains(where: { $0.id == "ETH" }))
    }

    func testUpdateAmounts_UpdatesExistingData() async throws {
        // Arrange
        let btc = Cryptocurrency(id: "BTC", name: "Bitcoin", value: 40000.0, marketCap: 800000.0, iconData: nil)
        modelContext.insert(btc)
        try modelContext.save()
        
        let updateDTO = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, iconData: nil)

        // Act
        repository.updateAmounts(incomingCryptos: [updateDTO])

        // Assert
        XCTAssertEqual(btc.value, 50000.0)
        XCTAssertEqual(btc.marketCap, 1000000.0)
    }

    func testFetchAllCryptoIDs_ReturnsCorrectIDs() async throws {
        // Arrange
        let btc = Cryptocurrency(id: "BTC", name: "Bitcoin", value: 1.0, marketCap: 1.0, iconData: nil)
        let eth = Cryptocurrency(id: "ETH", name: "Ethereum", value: 1.0, marketCap: 1.0, iconData: nil)
        modelContext.insert(btc)
        modelContext.insert(eth)
        try modelContext.save()

        // Act
        let ids = repository.fetchAllCryptoIDs()

        // Assert
        XCTAssertEqual(ids.count, 2)
        XCTAssertTrue(ids.contains("BTC"))
        XCTAssertTrue(ids.contains("ETH"))
    }
}
