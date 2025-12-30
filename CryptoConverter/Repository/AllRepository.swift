import SwiftData

@MainActor
final class AllRepository {
    
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addInitialFavourites(currencies: [Currency]) async throws {
        for currency in currencies {
            if currency.id == "BTC" || currency.id == "ETH" || currency.id == "USD" || currency.id == "EUR" {
                currency.sortOrder = getHighestOrder(currencies: currencies) + 1
                currency.favourite = true
            }
        }
        
        try modelContext.save()
        print("Initial favourites have been added")
    }
    
    /// Get the new highest order.
    /// This is used when a new crypto is added to favourites and it needs a new value in sortOrder.
    func getHighestOrder(currencies: [Currency]) -> Int {
        var highest = 0

        currencies.filter(\.favourite).forEach { currency in
            guard let sortOrder = currency.sortOrder else {
                print("SortOrder is nil for \(currency.id) while is it favourite: \(currency.favourite).")
                return
            }
            if sortOrder > highest {
                highest = sortOrder
            }
        }
        return highest
    }
}
