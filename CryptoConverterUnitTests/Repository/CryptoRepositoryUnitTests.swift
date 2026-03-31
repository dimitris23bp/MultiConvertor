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
        let dummyData = "preview".data(using: .utf8)
		// TODO: Add btc from assets to iconData
        let crypto = Cryptocurrency(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, iconData: nil)

        // Act
        try await repository.saveCryptos(cryptocurrencies: [crypto])

        // Assert
        let descriptor = FetchDescriptor<Cryptocurrency>()
        let savedCryptos = try modelContext.fetch(descriptor)
        
        XCTAssertEqual(savedCryptos.count, 1)
        XCTAssertEqual(savedCryptos.first?.id, "BTC")
    }

    func testAddInitialFavourites_UpdatesStatusAndSortOrder() async throws {
        // Arrange
        let btc = Cryptocurrency(id: "BTC", name: "Bitcoin", value: 1.0, marketCap: 1.0, iconData: nil)
        let eth = Cryptocurrency(id: "ETH", name: "Ethereum", value: 1.0, marketCap: 1.0, iconData: nil)
        let other = Cryptocurrency(id: "DOGE", name: "Dogecoin", value: 1.0, marketCap: 1.0, iconData: nil)

        modelContext.insert(btc)
        modelContext.insert(eth)
        modelContext.insert(other)
        
        let cryptos = [btc, eth, other]

        // Act
        try await repository.addInitialFavourites(cryptocurrencies: cryptos)

        // Assert
        XCTAssertTrue(btc.favourite)
        XCTAssertTrue(eth.favourite)
        XCTAssertFalse(other.favourite)
        
        XCTAssertGreaterThan(btc.popularity ?? 0, 0)
        XCTAssertGreaterThan(eth.popularity ?? 0, 0)
    }
}
