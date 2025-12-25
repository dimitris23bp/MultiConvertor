import XCTest
import SwiftData
@testable import CryptoConverter

@MainActor
final class CryptoRepositoryUnitTests: XCTestCase {
	var modelContainer: ModelContainer!
	var modelContext: ModelContext!
	var mockService: CryptocurrencyServiceMock!
	var repository: CryptoRepository!

	override func setUp() async throws {
		let schema = Schema([Cryptocurrency.self])
		let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
		modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
		modelContext = modelContainer.mainContext
		mockService = CryptocurrencyServiceMock()
		repository = CryptoRepository(modelContext: modelContext, cryptocurrencyService: mockService)
	}

	override func tearDown() {
		modelContainer = nil
		modelContext = nil
		mockService = nil
		repository = nil
	}

	func testEnsureInitialDataIfNeeded_WhenStoreIsEmpty_FetchesAndSaves() async throws {
		// Arrange
        let dummyData = "preview".data(using: .utf8)
		let mockDTO = CryptocurrencyDTO(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, renderedLogoData: dummyData, favourite: false, sortOrder: nil)
		mockService.mockCryptocurrencies = [mockDTO]

		// Act
		try await repository.ensureInitialDataIfNeeded(minCount: 1)

		// Assert
		let descriptor = FetchDescriptor<Cryptocurrency>()
		let savedCryptos = try modelContext.fetch(descriptor)
		
		XCTAssertEqual(savedCryptos.count, 1)
		XCTAssertEqual(savedCryptos.first?.id, "BTC")
		XCTAssertEqual(mockService.fetchWithAmountCalledCount, 1)
	}

	func testEnsureInitialDataIfNeeded_WhenStoreHasEnoughData_DoesNotFetch() async throws {
		// Arrange
		let existingCrypto = Cryptocurrency(id: "BTC", name: "Bitcoin", value: 50000.0, marketCap: 1000000.0, logoString: "preview")
		modelContext.insert(existingCrypto)
		try modelContext.save()
		
		mockService.mockCryptocurrencies = []

		// Act
		try await repository.ensureInitialDataIfNeeded(minCount: 1)

		// Assert
		XCTAssertEqual(mockService.fetchWithAmountCalledCount, 0)
	}
}
